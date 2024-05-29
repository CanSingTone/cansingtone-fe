import '../main.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  _startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, _navigateToHome);
  }

  _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/title.png'),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
