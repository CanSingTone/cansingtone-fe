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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFF241D27),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
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
                '${widget.songInfo['artist']}',
                style: TextStyle(fontSize: 17.0),
              ),
              SizedBox(height: 8.0),
              Text(
                '노래방 번호: ${widget.songInfo['karaokeNum'] ?? '노래방 번호'}',
                style: TextStyle(fontSize: 17.0),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text(
                    "음원 영상",
                    style: TextStyle(fontSize: 17.0),
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
                    style: TextStyle(fontSize: 17.0),
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
