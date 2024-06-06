import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cansingtone_front/playlist/playlistpage.dart';
import 'package:cansingtone_front/userdata.dart';
import 'package:flutter/material.dart';
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
  bool _isSongPlayerReady = false;
  bool _isMrPlayerReady = false;
  late PlayerState _songPlayerState;
  late PlayerState _mrPlayerState;
  late YoutubeMetaData _songVideoMetaData;
  late YoutubeMetaData _mrVideoMetaData;

  @override
  void initState() {
    super.initState();
    String? songVidUrl = widget.songInfo['songVidUrl'];
    String? mrVidUrl = widget.songInfo['mrVidUrl'];

    if (songVidUrl != null) {
      _songController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(songVidUrl)!,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      )..addListener(() => _listener(_songController, 'song'));
      _songVideoMetaData = const YoutubeMetaData();
      _songPlayerState = PlayerState.unknown;
    }

    if (mrVidUrl != null) {
      _mrController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(mrVidUrl)!,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      )..addListener(() => _listener(_mrController, 'mr'));
      _mrVideoMetaData = const YoutubeMetaData();
      _mrPlayerState = PlayerState.unknown;
    }
  }

  void _listener(YoutubePlayerController controller, String type) {
    if ((type == 'song' && _isSongPlayerReady) ||
        (type == 'mr' && _isMrPlayerReady)) {
      setState(() {
        if (type == 'song') {
          _songPlayerState = controller.value.playerState;
          _songVideoMetaData = controller.metadata;
        } else {
          _mrPlayerState = controller.value.playerState;
          _mrVideoMetaData = controller.metadata;
        }
      });
    }
  }

  @override
  void dispose() {
    _songController.dispose();
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

  // 플레이리스트 선택 다이얼로그 표시 함수
  Future<void> _showPlaylistDialog() async {
    try {
      // Fetch playlists using the fetchPlaylists function
      List<Playlist> playlists = await fetchPlaylists();

      String? selectedPlaylist = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('플레이리스트 선택'),
            content: SingleChildScrollView(
              child: ListBody(
                children: playlists.where((playlist) => playlist.playlistName != "좋아요 표시한 음악").map((playlist) {
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
        // 선택된 플레이리스트에 곡을 추가하는 로직
        print('선택된 플레이리스트: $selectedPlaylist');
        // 곡을 플레이리스트에 추가하는 API 호출
        String songId = widget.songInfo['songId'].toString();
        final response = await http.post(
          Uri.parse(
              'http://13.125.27.204:8080/songs-in-playlist?playlist_id=$selectedPlaylist&song_id=$songId'),
        );
        final Map<String, dynamic> responseBody =
            jsonDecode(utf8.decode(response.bodyBytes));
        if (responseBody['isSuccess'] == true) {
          // 추가 성공 메시지
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
          // 추가 실패 메시지
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
                      Navigator.of(context).pop(); // Close the dialog
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
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add, color: Colors.white),
            onPressed: _showPlaylistDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.songInfo['albumImage'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        widget.songInfo['albumImage'],
                        width: width * 0.6,
                        height: width * 0.6,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(),
              SizedBox(height: 8.0),
              Text(
                widget.songInfo['songTitle'],
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '${widget.songInfo['artist']}',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              SizedBox(height: 8.0),
              Text(
                '노래방 번호: ${widget.songInfo['karaokeNum'] ?? ''}',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text(
                    "음원 영상",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              if (widget.songInfo['songVidUrl'] != null)
                SizedBox(
                  height: 250,
                  child: YoutubePlayer(
                    controller: _songController,
                    onReady: () {
                      print('Song Player is ready.');
                      setState(() {
                        _isSongPlayerReady = true;
                      });
                    },
                  ),
                ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text(
                    "MR 영상",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              if (widget.songInfo['mrVidUrl'] != null)
                SizedBox(
                  height: 250,
                  child: YoutubePlayer(
                    controller: _mrController,
                    onReady: () {
                      print('MR Player is ready.');
                      setState(() {
                        _isMrPlayerReady = true;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
