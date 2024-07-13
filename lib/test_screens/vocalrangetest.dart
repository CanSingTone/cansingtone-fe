import 'dart:io';

import 'package:cansingtone_front/recommendation_screens/range_based_recom_screen.dart';
import 'package:cansingtone_front/recommendation_screens/usercard.dart';
import 'package:cansingtone_front/userdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/bottombar.dart';
import '../service/uploader.dart';
import '../start_screens/tutorial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import '../service/getuserdata.dart';

import 'dart:math' as math show sin, pi, sqrt;

import '../widgets/vocal_range_painter.dart';

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

  void showLoadingDialog(BuildContext context, Widget spinner, String message,
      int duration, VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                spinner,
                SizedBox(height: 16),
                Text(message, style: TextStyle(fontSize: 17)),
                SizedBox(height: 16),
                Text(
                  "분석에는 40-50초 정도 소용됩니다. ",
                  style: TextStyle(fontSize: 13),
                )
              ],
            ),
          ),
        );
      },
    );

    // Dismiss the dialog after the specified duration
    Future.delayed(Duration(seconds: duration), () {
      Navigator.pop(context);
      onComplete();
    });
  }

  void showSequentialLoadingDialogs(BuildContext context) {
    showLoadingDialog(
      context,
      SpinKitThreeInOut(
        color: Colors.red,
        size: 50.0,
      ),
      "데이터 전송중... ",
      10,
      () {
        showLoadingDialog(
          context,
          SpinKitWave(
            color: Colors.blue,
            size: 50.0,
          ),
          "데이터 처리중...",
          10,
          () {
            showLoadingDialog(
              context,
              SpinKitHourGlass(
                color: Colors.yellow,
                size: 50.0,
              ),
              "결과 생성중...",
              100,
              () {
                showCompleteDialog(context);
              },
            );
          },
        );
      },
    );
  }

  void showCompleteDialog(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF241D27),
          title: Text(
            "측정완료!",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text("남자 평균 음역대",
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              CustomPaint(
                size: Size(300, 30),
                painter: VocalRangePainter(
                  lowNote: 41,
                  highNote: 65,
                  rangeColor: Colors.blue,
                ),
              ),
              SizedBox(height: 50),
              Text("여자 평균 음역대",
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              CustomPaint(
                size: Size(300, 30),
                painter: VocalRangePainter(
                  lowNote: 53,
                  highNote: 77,
                  rangeColor: Colors.pink,
                ),
              ),
              SizedBox(height: 50),
              Text("당신의 음역대",
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              CustomPaint(
                size: Size(300, 30),
                painter: VocalRangePainter(
                  lowNote: userData.vocalRangeLow,
                  highNote: userData.vocalRangeHigh,
                  rangeColor: Color(0xffE365CF),
                ),
              ),
            ],
          ),
          // 돌아가기 버튼의 코드
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AnimatedBarExample(initialSelectedTab: 3)),
                );
              },
              child: Text(
                "돌아가기",
                style: TextStyle(color: Colors.white),
              ),
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
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final userId = Provider.of<UserData>(context).getUserId();
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
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.info_outline),
        //     onPressed: () {
        //       showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return AlertDialog(
        //             title: Text('주의사항'),
        //             content: Text(
        //                 '1. 조용한 환경에서 진행해주세요.\n2. 녹음 시간은 15초를 넘지 않게 해주세요.\n   처리 시간이 길어집니다.'),
        //             actions: [
        //               TextButton(
        //                 onPressed: () {
        //                   Navigator.of(context).pop();
        //                 },
        //                 child: Text('확인'),
        //               ),
        //             ],
        //           );
        //         },
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
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
                            color: Color(0xFFE542AE),
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
            if (_hasShownInitialMessage) ...[
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  children: [
                    Text(
                      '마이크를 클릭하고 편안하게 낼 수 있는\n 최저음과 최고음을 내주세요.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.0),
                    Text(
                      '1. 조용한 환경에서 진행해주세요.\n2. 녹음 시간은 15초를 넘지 않게 해주세요.\n     처리 시간이 길어집니다.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 16.0),
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
              Container(
                child: Column(
                  children: [
                    Text(
                        _isRecording
                            ? ''
                            : '다시 측정하고 싶으시다면 \n마이크를 다시 한 번 터치해주세요.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center),
                    SizedBox(height: 20.0),
                    _isRecording
                        ? Row()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _playRecordedAudio,
                                child: Text('들어보기',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16.0)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30), // 모서리를 조절해요
                                  ),
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.3,
                                      50),
                                ),
                              ),
                              SizedBox(width: 20.0),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_filePath.isNotEmpty) {
                                    showSequentialLoadingDialogs(context);
                                    File file = File(_filePath);
                                    AudioUploader audioUploader =
                                        AudioUploader(context);
                                    await audioUploader.uploadAudioFile(file);
                                    UserDataService.fetchAndSaveUserDataS(
                                        context, userId);
                                    await Future.delayed(Duration(seconds: 2));
                                    Navigator.of(context)
                                        .pop(); // Close the loading dialog
                                    showCompleteDialog(
                                        context); // Show the complete dialog
                                  } else {
                                    print('No recorded file found');
                                  }
                                },
                                child: Text('이대로 보내기',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16.0)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30), // 모서리를 조절해요
                                  ),
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.3,
                                      50),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WaveAnimation extends StatefulWidget {
  final double size;
  final Color color;

  const WaveAnimation({
    this.size = 80.0,
    this.color = Colors.white,
    Key? key,
  }) : super(key: key);

  @override
  WaveAnimationState createState() => WaveAnimationState();
}

class WaveAnimationState extends State<WaveAnimation>
    with TickerProviderStateMixin {
  late AnimationController animCtr;

  @override
  void initState() {
    super.initState();
    animCtr = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  Widget getAnimatedWidget() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size),
          gradient: RadialGradient(
            colors: [
              widget.color,
              Color.lerp(widget.color, Colors.black, .05)!
            ],
          ),
        ),
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: animCtr,
              curve: CurveWave(),
            ),
          ),
          child: Container(
            width: widget.size * 0.5,
            height: widget.size * 0.5,
            margin: const EdgeInsets.all(6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(context) {
    return CustomPaint(
      painter: CirclePainter(animCtr, color: widget.color),
      child: SizedBox(
        width: widget.size * 1.6,
        height: widget.size * 1.6,
        child: getAnimatedWidget(),
      ),
    );
  }

  @override
  void dispose() {
    animCtr.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;

  CirclePainter(
    this.animation, {
    required this.color,
  }) : super(repaint: animation);

  void circle(Canvas canvas, Rect rect, double value) {
    final double opacity = (0.9 - (value / 4.0)).clamp(0.0, 1.0);
    final Color rippleColor = color.withOpacity(opacity);
    final double size = rect.width / 2;
    final double area = size * size;
    final double radius = math.sqrt(area * value / 4);
    final Paint paint = Paint()..color = rippleColor;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + animation.value);
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;
}

class CurveWave extends Curve {
  @override
  double transform(double t) {
    if (t == 0 || t == 1) {
      return 0.01;
    }
    return math.sin(t * math.pi);
  }
}
