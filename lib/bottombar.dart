import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import './mainpage.dart';
import './mypage.dart';
import './playlist.dart';
import './recompage.dart';

class AnimatedBarExample extends StatefulWidget {
  const AnimatedBarExample({Key? key}) : super(key: key);

  @override
  State<AnimatedBarExample> createState() => _AnimatedBarExampleState();
}

class _AnimatedBarExampleState extends State<AnimatedBarExample> {
  int selected = 0;
  bool heart = false;
  bool recommend = false;

  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, //to make floating action button notch transparent

      //to avoid the floating action button overlapping behavior,
      // when a soft keyboard is displayed
      // resizeToAvoidBottomInset: false,

      bottomNavigationBar: StylishBottomBar(
        option: DotBarOptions(
          dotStyle: DotStyle.tile,
          gradient: const LinearGradient(
            colors: [
              Colors.deepPurple,
              Colors.pink,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        items: [
          BottomBarItem(
            icon: const Icon(
              Icons.house_outlined,
            ),
            selectedIcon: const Icon(Icons.house_rounded),
            selectedColor: Colors.teal,
            unSelectedColor: Colors.grey,
            title: const Text('홈'),
          ),
          BottomBarItem(
            icon: const Icon(Icons.queue_music),
            selectedIcon: const Icon(Icons.queue_music),
            selectedColor: Colors.red,
            title: const Text('플레이리스트'),
          ),
          BottomBarItem(
            icon: const Icon(
              Icons.person,
            ),
            selectedIcon: const Icon(
              Icons.person,
            ),
            selectedColor: Colors.deepOrangeAccent,
            title: const Text('마이페이지'),
          ),
          BottomBarItem(
            icon: Icon(
              recommend ? Icons.recommend_rounded : Icons.recommend,
            ),
            selectedColor: Colors.deepPurple,
            title: const Text('추천'),
          ),
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.end,
        currentIndex: selected,
        notchStyle: NotchStyle.square,
        onTap: (index) {
          if (index == selected) return;
          setState(() {
            selected = index;
          });
        },
      ),
     // floatingActionButton:
     //      FloatingActionButton(
     //   onPressed: () {
     //     setState(() {
     //       selected = 3;
     //     });
     //   },
    //    backgroundColor: Colors.white,
     //   child: Icon(
    //      heart ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
    //      color: Colors.red,
     //   ),
     // )
     //     ,
     // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: SafeArea(
        child: _getBody(selected),
      ),
    );
  }

  Widget _getBody(int selected) {
    switch (selected) {
      case 0:
        return mainpage();
      case 1:
        return playlist();
      case 2:
        return mypage();
      case 3:
        return recompage();
      default:
        return Container();
    }
  }
}
