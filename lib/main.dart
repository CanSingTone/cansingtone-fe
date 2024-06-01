import 'package:cansingtone_front/recommendation_screens/recompage.dart';
import 'package:cansingtone_front/start/login_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'mainpage.dart';
import 'start/splash.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import './bottombar.dart';
import 'start/tutorial.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './userdata.dart';
import 'package:provider/provider.dart';

void main() {
  KakaoSdk.init(nativeAppKey: 'eec662ba5e2f988d504a0da199dabf89');
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NanumBarunGothic',
      ),
      home: TutorialPage(
        onComplete: () {},
      ),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/tutorial': (context) => TutorialPage(
              onComplete: () {},
            ),
        '/home': (context) => AnimatedBarExample(),
      },
    );
  }
}

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool _showTutorial = true; // 튜토리얼 페이지를 보여줄지 여부를 결정하는 변수

  @override
  void initState() {
    super.initState();
    // 여기에 SharedPreferences 등을 사용해 실제로 튜토리얼 페이지를 보여줄지 여부를 결정할 수 있습니다.
    // 예를 들어, 처음 실행인지 여부를 체크하여 튜토리얼 페이지를 보여줄지 결정할 수 있습니다.
  }

  void _completeTutorial() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AnimatedBarExample()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showTutorial
        ? TutorialPage(onComplete: _completeTutorial)
        : AnimatedBarExample();
  }
}
