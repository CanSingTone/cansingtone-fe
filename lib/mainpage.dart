import './mypage.dart';
import 'package:flutter/material.dart';
import './songinfopage.dart';
import './detailsearch.dart';

class mainpage extends StatelessWidget {
  // const mainpage({Key? key}) : super(key: key);

  final List<String> imagePaths = [
    'assets/images/home/banner/gang.png',
    'assets/images/home/banner/bubblegum.png',
    'assets/images/home/banner/lovewinsall.png',
    'assets/bom.png',
    'assets/bom.png',
  ];
  final List<String> chartNames = [
    '노래방 TOP10',
    '20대 남성 TOP10',
    '차트 3',
    '차트 4',
    '차트 5',
    '차트 6',
    '차트 7',
    '차트 8',
    '차트 9',
    '차트 10',
  ];
  final List<List<Map<String, String>>> songLists = List.generate(10, (index) {
    return List.generate(10, (songIndex) {
      return {
        'title': '노래 제목 $songIndex',
        'artist': '가수 이름 $songIndex',
      };
    });
  });
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Image.asset(
              'assets/cansingtone.png',
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            backgroundColor: Color(0xFF241D27),
            floating: true,
            snap: true,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailSearchPage()),
                    );
                  },
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: 10),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: height * 0.18,
              child: PageView.builder(
                  controller: PageController(viewportFraction: 0.95),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      height: height * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(imagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: 30),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: height * 0.5,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.95),
                itemCount: chartNames.length,
                itemBuilder: (context, pageIndex) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFC9D99B)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            chartNames[pageIndex],
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        /*                     Expanded(
                          child: ListView.builder(
                            itemCount: songLists[pageIndex].length,
                            itemBuilder: (context, songIndex) {
                              var song = songLists[pageIndex][songIndex];
                              return ListTile(
                                leading:
                                    Icon(Icons.music_note, color: Colors.black),
                                title: Text(
                                  song['title']!,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                subtitle: Text(
                                  song['artist']!,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SongInfoPage(
                                            songId: songIndex + 4)),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        */
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SongDetailPage extends StatelessWidget {
  final String title;
  final String artist;

  SongDetailPage({required this.title, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '노래 정보',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '제목: $title',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '가수: $artist',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
