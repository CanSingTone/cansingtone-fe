import 'dart:convert';
import 'dart:ui';

import 'package:cansingtone_front/recommendation_screens/usercard.dart';
import 'package:cansingtone_front/widgets/vocal_range_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:cansingtone_front/playlist/playlistpage.dart';
import 'package:cansingtone_front/userdata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SongDetailScreen extends StatefulWidget {
  final Map<String, dynamic> songInfo;

  const SongDetailScreen({Key? key, required this.songInfo}) : super(key: key);

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late YoutubePlayerController _songController;
  late YoutubePlayerController _mrController;
  bool _isPlayerVisible = true;

  @override
  void initState() {
    super.initState();
    String? songVidUrl = widget.songInfo['songVidUrl'];

    if (songVidUrl != null) {
      _songController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(songVidUrl)!,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: false,
          loop: false,
          enableCaption: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    setState(() {
      _isPlayerVisible = false;
    });
    _songController.pause();
    _songController.dispose();
    _mrController.pause();
    _mrController.dispose();
    super.dispose();
  }

  Future<List<Playlist>> fetchPlaylists() async {
    String? userId = await UserDataShare.getUserId();
    final response = await http
        .get(Uri.parse('http://13.125.27.204:8080/playlists/${userId}'));
    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes))['result'];
      return data.map((json) => Playlist.fromJson(json)).toList();
    } else {
      throw Exception('플레이리스트를 불러오는데 실패했습니다.');
    }
  }

  Future<void> _showPlaylistDialog() async {
    try {
      List<Playlist> playlists = await fetchPlaylists();

      String? selectedPlaylist = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('플레이리스트 선택'),
            content: SingleChildScrollView(
              child: ListBody(
                children: playlists
                    .where((playlist) => playlist.playlistName != "좋아요 표시한 음악")
                    .map((playlist) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(playlist.playlistId.toString());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(playlist.playlistName),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );

      if (selectedPlaylist != null) {
        String songId = widget.songInfo['songId'].toString();
        final response = await http.post(
          Uri.parse(
              'http://13.125.27.204:8080/songs-in-playlist?playlist_id=$selectedPlaylist&song_id=$songId'),
        );
        final Map<String, dynamic> responseBody =
            jsonDecode(utf8.decode(response.bodyBytes));
        if (responseBody['isSuccess'] == true) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('추가 완료!'),
                content: const Text('곡이 플레이리스트에 성공적으로 추가되었습니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('확인'),
                  ),
                ],
              );
            },
          );
        } else {
          final Map<String, dynamic> responseBody =
              jsonDecode(utf8.decode(response.bodyBytes));
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('추가 실패'),
                content: Text(responseBody['message'] ?? '알 수 없는 오류가 발생했습니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('확인'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('플레이리스트를 불러오는데 실패했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final userData = Provider.of<UserData>(context);

    String _getKeyAdjustmentAdvice() {
      int lowestNoteGap =
          widget.songInfo['lowestNote'] - userData.vocalRangeLow;
      int highestNoteGap =
          widget.songInfo['highestNote'] - userData.vocalRangeHigh;

      if (lowestNoteGap < 0 && highestNoteGap > 0) {
        // 노래 음역대가 사용자 음역대보다 전체적으로 높은 경우
        return '노래 키를 낮춰야 합니다.';
      } else if (lowestNoteGap > 0 && highestNoteGap < 0) {
        // 노래 음역대가 사용자 음역대보다 전체적으로 낮은 경우
        return '노래 키를 높여야 합니다.';
      } else {
        // 그 외의 경우에는 최고음과 최저음 중 더 큰 간격을 기준으로 조언
        int largerGap = lowestNoteGap.abs() > highestNoteGap.abs()
            ? lowestNoteGap
            : highestNoteGap;
        if (largerGap > 0) {
          return '노래 키를 높여야 합니다.';
        } else {
          return '노래 키를 낮춰야 합니다.';
        }
      }
    }

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _isPlayerVisible = false;
        });
        _songController.pause();
        _songController.dispose();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF241D27),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              setState(() {
                _isPlayerVisible = false;
              });
              _songController.pause();
              _songController.dispose();
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.playlist_add, color: Colors.white),
              onPressed: _showPlaylistDialog,
            ),
          ],
        ),
        body: Stack(
          children: [
            if (widget.songInfo['albumImage'] != null)
              Positioned.fill(
                child: Image.network(
                  widget.songInfo['albumImage'],
                  fit: BoxFit.cover,
                ),
              ),
            if (widget.songInfo['albumImage'] != null)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.1),
                    Row(
                      children: [
                        SizedBox(width: width * 0.09),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: height * 0.02),
                              child: Image.asset(
                                'assets/images/record.png',
                                width: width * 0.47,
                                height: width * 0.47,
                              ),
                            ),
                            widget.songInfo['albumImage'] != null
                                ? Positioned(
                                    left: width * 0.19,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        widget.songInfo['albumImage'],
                                        width: width * 0.55,
                                        height: width * 0.55,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.05),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0), // 양쪽 끝에 여유 공간 추가
                          child: Expanded(
                            child: Text(
                              widget.songInfo['songTitle'],
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0), // 양쪽 끝에 여유 공간 추가
                          child: Expanded(
                            child: Text(
                              '${widget.songInfo['artist']}',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0), // 양쪽 끝에 여유 공간 추가
                          child: Expanded(
                            child: Text(
                              '노래방 번호: ${widget.songInfo['karaoke_num']}',
                              style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.05),
                    Row(
                      children: [
                        Text(
                          "음원 영상 ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Image.asset(
                            'assets/images/emoji/cd.png',
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    if (_isPlayerVisible &&
                        widget.songInfo['songVidUrl'] != null)
                      SizedBox(
                        height: 250,
                        child: YoutubePlayer(
                          controller: _songController,
                        ),
                      ),
                    SizedBox(height: height * 0.04),
                    KeyAdjustmentGuide(
                      songInfo: widget.songInfo,
                      userData: userData,
                    ),
                    SizedBox(height: height * 0.04),
                    if (widget.songInfo['mrVidUrl'] != null)
                      SizedBox(
                        width: width * 0.95,
                        height: height * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            Uri uri =
                                Uri.parse(widget.songInfo['mrVidUrl'] ?? '');
                            _launchVideo(uri);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('연습하러 가기  ',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.white,
                                  )),
                              Image.asset(
                                'assets/images/emoji/mic.png',
                                width: 25,
                                height: 25,
                              )
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}

String midiNumberToNoteName(int midiNumber) {
  if (midiNumber < 21 || midiNumber > 108) {
    return '  ';
  }

  List<String> notes = [
    'A',
    'A#',
    'B',
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#'
  ];

  int octave = (midiNumber - 12) ~/ 12;
  int noteIndex = (midiNumber - 21) % 12;

  String noteName = notes[noteIndex] + octave.toString();
  return noteName;
}

class KeyAdjustmentGuide extends StatelessWidget {
  const KeyAdjustmentGuide({
    super.key,
    required this.songInfo,
    required this.userData,
  });

  final Map<String, dynamic> songInfo;
  final UserData userData;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    int lowestNoteGap = songInfo['lowestNote'] - userData.vocalRangeLow;
    int highestNoteGap = songInfo['highestNote'] - userData.vocalRangeHigh;

    String low_description = '';
    String high_description = '';
    String guide = '';
    if (highestNoteGap == 0) {
      high_description += '곡의 최고음이 음역대와 일치합니다.';
    } else if (highestNoteGap > 0) {
      high_description += '곡의 최고음이 음역대보다 ${highestNoteGap}키 높습니다.';
    } else if (highestNoteGap < 0) {
      high_description += '곡의 최고음이 음역대보다 ${-highestNoteGap}키 낮습니다.';
    }

    if (lowestNoteGap == 0) {
      low_description += '곡의 최저음이 음역대와 일치합니다.';
    } else if (lowestNoteGap > 0) {
      low_description += '곡의 최저음이 음역대보다 ${lowestNoteGap}키 높습니다.';
    } else if (lowestNoteGap < 0) {
      low_description += '곡의 최저음이 음역대보다 ${-lowestNoteGap}키 낮습니다.';
    }

    if (highestNoteGap <= 0 && lowestNoteGap >= 0) {
      // 노래의 고음이 사용자의 고음보다 낮고 노래의 저음이 사용자의 저음보다 높은 경우. 즉 곡의 음역대가 사용자의 음역대 안에 있는 경우
      guide = '${userData.nickname}님의 음역대에 잘 맞는 곡입니다. \n한 번 불러보세요!';
    } else if (highestNoteGap > 0 &&
        (userData.vocalRangeLow <=
            songInfo['lowestNote'] - highestNoteGap.abs())) {
      // 사용자의 고음보다 곡의 고음이 높으면 조정. 단, 조정 후 곡의 최저음이 사용자의 최저음보다 높아야 함
      guide =
          '${highestNoteGap.abs()}~${highestNoteGap.abs() + 1}키 낮추는 것을 추천합니다.';
    } else if (lowestNoteGap < 0 &&
        (userData.vocalRangeHigh >=
            songInfo['highestNote'] + lowestNoteGap.abs())) {
      // 사용자의 저음보다 곡의 저음이 낮으면 조정. 단, 조정 후 곡의 최고음이 사용자의 최고음보다 낮아야 함
      guide =
          '${lowestNoteGap.abs() - 1}~${lowestNoteGap.abs()}키 높이는 것을 추천합니다.';
    } else {
      guide = '음역대 조정이 어려운 노래입니다';
    }

    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.black54.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Text(
            '노래의 음역대',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.0), // 텍스트 사이의 간격
          CustomPaint(
            size: Size(width, 50),
            painter: VocalRangePainter(
              lowNote: songInfo['lowestNote'],
              highNote: songInfo['highestNote'],
              lineColor: Colors.white,
              rangeColor: Colors.blue,
            ),
          ),
          SizedBox(height: height * 0.05),
          Text(
            '나의 음역대',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
          CustomPaint(
            size: Size(width, 50),
            painter: VocalRangePainter(
              lowNote: userData.vocalRangeLow,
              highNote: userData.vocalRangeHigh,
              lineColor: Colors.white,
              rangeColor: Color(0xffE365CF),
            ),
          ),
          SizedBox(height: height * 0.06),
          Text(
            high_description,
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          Text(
            low_description,
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          SizedBox(
            height: height * 0.03,
          ),
          guide == '음역대 조정이 어려운 노래입니다'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      guide,
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                    SizedBox(width: 2.0),
                    Image.asset(
                      'assets/images/emoji/cry.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
                )
              : Text(
                  guide,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
          SizedBox(
            height: height * 0.01,
          )
        ],
      ),
    );
  }
}
