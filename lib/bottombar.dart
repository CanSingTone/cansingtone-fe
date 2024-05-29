import 'package:cansingtone_front/recommendation_screens/recompage.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import './mainpage.dart';
import './mypage.dart';
import './playlist.dart';

class AnimatedBarExample extends StatefulWidget {
  const AnimatedBarExample({Key? key}) : super(key: key);

  @override
  State<AnimatedBarExample> createState() => _AnimatedBarExampleState();
}

class _AnimatedBarExampleState extends State<AnimatedBarExample> {
  int selectedIndex = 0;
  int pageIndex = 0; // Separate state for PageView index
  bool heart = false;

  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // to make floating action button notch transparent

      // to avoid the floating action button overlapping behavior,
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
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.end,
        currentIndex: selectedIndex >= 0
            ? selectedIndex
            : 0, // Ensure currentIndex is valid
        notchStyle: NotchStyle.square,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            pageIndex = index;
            controller
                .jumpToPage(index); // Update to navigate using PageController
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            selectedIndex = -1; // Clear selection
            pageIndex = 3; // Only update PageView index
            controller.jumpToPage(3); // Navigate to the recompage tab
          });
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.recommend,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: SafeArea(
        child: PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() {
              pageIndex = index;
              if (index < 3) {
                // Update bottom bar only for valid indices
                selectedIndex = index;
              } else {
                selectedIndex = -1; // Clear selection for invalid indices
              }
            });
          },
          children: [
            mainpage(),
            playlist(),
            mypage(),
            recompage(),
          ],
        ),
      ),
    );
  }
}
