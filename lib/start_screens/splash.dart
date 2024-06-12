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
  late Animation<double> _note3Animation;
  late Animation<double> _note2Animation;
  late Animation<double> _note1Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _note3Animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _note2Animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 0.75, curve: Curves.easeIn),
    ));

    _note1Animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.75, 1.0, curve: Curves.easeIn),
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
            SizedBox(height: 50.0),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: width, // 원하는 너비 설정
                  height: height * 0.66, // 원하는 높이 설정
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.asset('assets/images/start/splash.png'),
                    ),
                  ),
                ),
                Positioned(
                    top: -height * 0.2,
                    left: width * 0.6,
                    child: FadeTransition(
                      opacity: _note1Animation,
                      child: Image.asset(
                        'assets/images/start/note1.png',
                        width: width * 0.4,
                        height: height * 0.4,
                      ),
                    )),
                Positioned(
                    top: height * 0.01,
                    left: width * 0.03,
                    child: FadeTransition(
                      opacity: _note2Animation,
                      child: Image.asset(
                        'assets/images/start/note2.png',
                        width: width * 0.25,
                        height: height * 0.25,
                      ),
                    )),
                Positioned(
                    top: height * 0.4,
                    left: width * 0.7,
                    child: FadeTransition(
                      opacity: _note3Animation,
                      child: Image.asset(
                        'assets/images/start/note3.png',
                        width: width * 0.17,
                        height: height * 0.17,
                      ),
                    )),
              ],
            ),
            SizedBox(height: height * 0.1),
          ],
        ),
      ),
    );
  }
}
