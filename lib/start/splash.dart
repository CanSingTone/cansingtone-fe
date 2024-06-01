import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    _startSplashScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, _navigateToHome);
  }

  _navigateToHome() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => LoginScreen(),
      transitionDuration: Duration.zero, // No transition duration
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child; // No transition animation
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: width, // 원하는 너비 설정
              height: height * 0.75, // 원하는 높이 설정
              child: ClipRect(
                child: FadeTransition(
                  opacity: _animation,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.asset('assets/images/start/splash.png'),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.1),
          ],
        ),
      ),
    );
  }
}
