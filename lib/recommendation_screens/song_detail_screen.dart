import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SongDetailScreen extends StatefulWidget {
  final Map<String, dynamic> songInfo;

  const SongDetailScreen({Key? key, required this.songInfo}) : super(key: key);

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late YoutubePlayerController _controller;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    String? songVidUrl = widget.songInfo['songVidUrl'];

    if (songVidUrl != null) {
      _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(songVidUrl)!,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      )..addListener(listener);
      _videoMetaData = const YoutubeMetaData();
      _playerState = PlayerState.unknown;
    }
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // String? videoId =
    //     YoutubePlayer.convertUrlToId(widget.songInfo['songVidUrl']);

    return Scaffold(
      appBar: AppBar(
        title: Text('곡 상세 정보'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.songInfo['albumImage'] != null
                    ? Image.network(
                        widget.songInfo['albumImage'],
                        width: 200, // 이미지 너비 조절 가능
                        height: 200, // 이미지 높이 조절 가능
                        fit: BoxFit.cover, // 이미지 채우기 옵션
                      )
                    : Container(), // 앨범 이미지가 없는 경우 빈 컨테이너를 표시
                SizedBox(height: 8.0),
                Text(
                  widget.songInfo['songTitle'],
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '아티스트: ${widget.songInfo['artist']}',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  '노래 번호: ${widget.songInfo['karaokeNum'] ?? '정보 없음'}',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  height: 250,
                  child: YoutubePlayer(
                    controller: _controller,
                    onReady: () {
                      print('Player is ready.');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
