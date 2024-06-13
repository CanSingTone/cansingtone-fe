import 'package:cansingtone_front/search_screens/detailsearch.dart';
import 'package:cansingtone_front/recommendation_screens/recompage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'main_screens/mainpage.dart';
import 'main_screens/mypage.dart';
import 'playlist/playlistpage.dart';

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
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBody: true, //to make floating action button notch transparent

      //to avoid the floating action button overlapping behavior,
      // when a soft keyboard is displayed
      // resizeToAvoidBottomInset: false,

      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          StylishBottomBar(
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
                icon: const Icon(
                  Icons.search,
                ),
                selectedIcon: const Icon(
                  Icons.search,
                ),
                selectedColor: Colors.deepOrangeAccent,
                title: const Text('검색'),
              ),
              BottomBarItem(
                icon: const Icon(Icons.queue_music),
                selectedIcon: const Icon(Icons.queue_music),
                selectedColor: Colors.red,
                title: const Text('플레이리스트'),
              ),
              BottomBarItem(
                icon: SizedBox(),
                selectedColor: Colors.deepPurple,
                title: const Text(''),
              ),
            ],
            hasNotch: true,
            //fabLocation: StylishBarFabLocation.end,
            currentIndex: selected,
            notchStyle: NotchStyle.square,
            onTap: (index) {
              if (index == selected) return;
              setState(() {
                selected = index;
              });
            },
          ),
          Positioned(
            bottom: height * 0.04,
            left: width * 0.79,
            child: SizedBox(
              height: 55,
              width: 55,
              child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      selected = 3;
                      //heart = !heart;
                    });
                  },
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/images/micro.png',
                    width: 40,
                  )

                  // Icon(
                  //   heart ? CupertinoIcons.heart_fill : CupertinoIcons.heart_fill,
                  //   color: Colors.purple,
                  // ),
                  ),
            ),
          ),
        ],
      ),
      // floatingActionButton: Positioned(
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       setState(() {
      //         selected = 3;
      //       });
      //     },
      //     backgroundColor: Colors.white,
      //     child: Icon(
      //       heart ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
      //       color: Colors.red,
      //     ),
      //   ),
      // ),
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
        return DetailSearchPage();
      case 2:
        return PlaylistPage();
      case 3:
        return recompage();
      default:
        return Container();
    }
  }
}
