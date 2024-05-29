import 'dart:io';

import 'package:cansingtone_front/userdata.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../uploader.dart';
import '../start/tutorial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import '../getuserdata.dart';

class VocalRangeTestPage extends StatefulWidget {
  @override
  _VocalRangeTestPageState createState() => _VocalRangeTestPageState();
}

class _VocalRangeTestPageState extends State<VocalRangeTestPage> {
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
      _filePath = '${tempDir.path}/flutter_sound_example.aac';
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
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        title: Text(
          '음역대 측정',
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
          mainAxisAlignment: MainAxisAlignment.center,
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
                  ? Image.asset(
                      'assets/pinkmic.png',
                    )
                  : Image.asset(
                      'assets/mic.png',
                    ),
            ),
            SizedBox(height: 20.0),
            if (_hasShownInitialMessage) ...[
              SizedBox(height: 20.0),
              Text(
                '마이크를 클릭하고 편안하게 낼 수 있는\n 최저음과 최고음을 내주세요.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
              SizedBox(height: 10.0),
              _isRecording
                  ? Row()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _playRecordedAudio,
                          child: Text('들어보기'),
                        ),
                        SizedBox(width: 20.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (_filePath.isNotEmpty) {
                              showLoadingDialog(context);
                              File file = File(_filePath);
                              AudioUploader audioUploader = AudioUploader();
                              await audioUploader.uploadAudioFile(file);
                              UserDataService.fetchAndSaveUserData(context, 8);
                              Navigator.of(context).pop();
                              showCompleteDialog(context);
                            } else {
                              print('No recorded file found');
                            }
                          },
                          child: Text('이대로 보내기'),
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