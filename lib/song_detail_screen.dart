import 'dart:convert';
import 'dart:ui';

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

  void _showKeyRecommendationDialog(BuildContext context, int songLow, int songHigh, int userLow, int userHigh) {
    String message;
    if ((songHigh - songLow) > (userHigh - userLow)) {
      message = '부르기 힘든 곡입니다 ㅠㅠ';
    } else {
      int lowkeyDifference = songLow - userLow;
      int highkeyDifference = songHigh - userHigh;
      message = '나의 음역대와 노래의 음역대의 가장 낮은 음의 차이: ${lowkeyDifference} 키\n 나의 음역대와 노래의 음역대의 가장 높은 음의 차이: ${highkeyDifference} 키';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('키 추천'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final userData = Provider.of<UserData>(context);
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0), // 양쪽 끝에 여유 공간 추가
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.songInfo['songTitle'],
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0), // 텍스트 사이의 간격
                              Text(
                                '노래의 음역대 : ${midiNumberToNoteName(widget.songInfo['lowestNote'])}~${midiNumberToNoteName(widget.songInfo['highestNote'])}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0), // 양쪽 끝에 여유 공간 추가
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${widget.songInfo['artist']}',
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 16.0), // 텍스트 사이의 간격
                              ElevatedButton(
                                onPressed: () {
                                  _showKeyRecommendationDialog(
                                    context,
                                    widget.songInfo['lowestNote'],
                                    widget.songInfo['highestNote'],
                                    userData.vocalRangeLow,
                                    userData.vocalRangeHigh,
                                  );
                                },
                                child: Text(
                                  '키 추천',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue, // 버튼 색상
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0), // 양쪽 끝에 여유 공간 추가
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '노래방 번호: ${widget.songInfo['karaokeNum'] ?? ''}',
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 16.0), // 텍스트 사이의 간격
                              Text(
                                '나의 음역대 : ${midiNumberToNoteName(userData.vocalRangeLow)}~${midiNumberToNoteName(userData.vocalRangeHigh)}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                        ),

                      ],
                    )
                    ,

                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Text(
                          "음원 영상",
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ],
                    ),
                    if (_isPlayerVisible &&
                        widget.songInfo['songVidUrl'] != null)
                      SizedBox(
                        height: 250,
                        child: YoutubePlayer(
                          controller: _songController,
                        ),
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
                              Text('연습하러 가기 ',
                                  style: TextStyle(
                                      fontSize: 17.0, color: Colors.black)),
                              Image.asset(
                                'assets/images/emoji/mic.png',
                                width: 25,
                                height: 25,
                              )
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
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