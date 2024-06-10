import 'dart:io';

import 'package:cansingtone_front/userdata.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../bottombar.dart';
import '../service/uploadert.dart';
import '../start_screens/tutorial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import '../service/getuserdata.dart';
import '../widgets/wave_animation.dart';

class TutorialTimbreTestPage extends StatefulWidget {
  @override
  _TutorialTimbreTestPage createState() => _TutorialTimbreTestPage();
}

class _TutorialTimbreTestPage extends State<TutorialTimbreTestPage> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  String _filePath = '';
  bool _isRecording = false;
  bool _isRecordingComplete = false;
  bool _hasShownInitialMessage = true;

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("측정중...  잠시만 기다려주세요..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("측정완료!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("돌아가기"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      final tempDir = await getTemporaryDirectory();
      _filePath = '${tempDir.path}/flutter_sound_timbre.aac';
      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );
      setState(() {
        _isRecording = true;
        _hasShownInitialMessage = false;
      });
      print('Recording started...');
    } else {
      print('Microphone permission denied');
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _isRecordingComplete = true;
    });
    print('Recording stopped');
    print('File saved at: $_filePath');
  }

  void _playRecordedAudio() async {
    if (_filePath.isNotEmpty) {
      await _player.openPlayer();
      await _player.startPlayer(
        fromURI: _filePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          print('Playback finished');
          _player.closePlayer();
        },
      );
      print('Playing recorded audio');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final userId = Provider.of<UserData>(context).getUserId();
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        title: Text(
          '음색 측정',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF241D27),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('주의사항'),
                    content: Text(
                        '1. 조용한 환경에서 진행해주세요.\n2. 녹음 시간은 30초를 넘지 않게 해주세요.\n   처리 시간이 길어집니다.'),
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
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (!_isRecording) {
                  _startRecording();
                } else {
                  _stopRecording();
                }
              },
              child: _isRecording
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: height * 0.13, bottom: height * 0.02),
                      child: Stack(
                        children: [
                          WaveAnimation(
                            size: 200,
                            color: Color(0xFFC9D99B),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 0,
                            child: Image.asset(
                              'assets/mic.png',
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                          top: height * 0.25, bottom: height * 0.05),
                      child: Image.asset(
                        'assets/mic.png',
                      ),
                    ),
            ),
            SizedBox(height: 20.0),
            if (_hasShownInitialMessage) ...[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Column(
                  children: [
                    Text(
                      '마이크를 클릭하고 아무 노래나 불러주세요.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.0),
                    Text(
                      '1. 조용한 환경에서 진행해주세요.\n2. 녹음 시간은 30초를 넘지 않게 해주세요.\n   처리 시간이 길어집니다.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 16.0),
                    ),
                    SizedBox(height: height * 0.05),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnimatedBarExample()),
                        );
                      },
                      child: Text("나중에 하기 >",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16.0)),
                    ),
                  ],
                ),
              ),
            ],
            Text(_isRecording ? '완료되었다면 \n마이크를 다시 한 번 터치해주세요.' : '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center),
            if (_isRecordingComplete) ...[
              Text(_isRecording ? '' : '다시 측정하고 싶으시다면 \n마이크를 다시 한 번 터치해주세요.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center),
              SizedBox(height: height * 0.03),
              _isRecording
                  ? Row()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _playRecordedAudio,
                          child: Text('들어보기',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // 모서리를 조절해요
                            ),
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.3, 50),
                          ),
                        ),
                        SizedBox(width: 20.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (_filePath.isNotEmpty) {
                              showLoadingDialog(context);
                              File file = File(_filePath);
                              AudioUploaderT audioUploader =
                                  AudioUploaderT(context);
                              await audioUploader.uploadAudioFileT(file);
                              UserDataService.fetchAndSaveUserDataS(
                                  context, userId);
                              Navigator.of(context).pop();
                              showCompleteDialog(context);
                            } else {
                              print('No recorded file found');
                            }
                          },
                          child: Text('이대로 보내기',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // 모서리를 조절해요
                            ),
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.3, 50),
                          ),
                        ),
                      ],
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
