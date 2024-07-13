import 'package:cansingtone_front/search_screens/detailsearch.dart';
import 'package:cansingtone_front/recommendation_screens/recompage.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../main_screens/mainpage.dart';
import '../main_screens/mypage.dart';
import '../playlist/playlistpage.dart';

class AnimatedBarExample extends StatefulWidget {
  final int initialSelectedTab;

  const AnimatedBarExample({Key? key, this.initialSelectedTab = 0})
      : super(key: key);

  @override
  State<AnimatedBarExample> createState() => _AnimatedBarExampleState();
}

class _AnimatedBarExampleState extends State<AnimatedBarExample> {
  late int selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialSelectedTab;
  }

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
      extendBody: true,
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
                    });
                  },
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/images/micro.png',
                    width: 40,
                  )),
            ),
          ),
        ],
      ),
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
