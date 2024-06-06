import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import './mypage.dart';
import 'package:flutter/material.dart';
import './songinfopage.dart';
import 'search_screens/detailsearch.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchSongs(start) async {
  final List<dynamic> songs = [];
  final Dio _dio = Dio();

  try {
    for (int i = start; i <= start + 20; i++) {
      Response response = await _dio.get('http://13.125.27.204:8080/songs/$i');

      if (response.statusCode == 200) {
        songs.add(response.data['result']);
      } else {
        throw Exception('Failed to load song with ID: $i');
      }
    }
  } catch (e) {
    throw Exception('Failed to fetch songs: $e');
  }

  return songs;
}

class mainpage extends StatefulWidget {
  @override
  State<mainpage> createState() => _mainpageState();
}

class _mainpageState extends State<mainpage> {
  late Future<List<dynamic>> _futureSongs;

  @override
  void initState() {
    super.initState();
    _futureSongs = fetchSongs(30);
  }

  // const mainpage({Key? key}) : super(key: key);
  final List<String> imagePaths = [
    'assets/images/home/banner/gang.png',
    'assets/images/home/banner/bubblegum.png',
    'assets/images/home/banner/lovewinsall.png',
    'assets/bom.png',
    'assets/bom.png',
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final int songsPerPage = 4;
    final int pageCount = (20 / songsPerPage).ceil();
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
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => mypage()),
                    );
                  },
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: 5),
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
            padding: EdgeInsets.only(top: 25),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Text(
                            '노래방 TOP100 ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            'assets/images/emoji/fire.png',
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: _futureSongs,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final songs = snapshot.data!;
                        return Align(
                          child: Container(
                            height: height * 0.5,
                            child: PageView.builder(
                              controller:
                                  PageController(viewportFraction: 0.92),
                              itemCount: pageCount,
                              itemBuilder: (context, pageIndex) {
                                final startIndex = pageIndex * songsPerPage;
                                final endIndex =
                                    (startIndex + songsPerPage < songs.length)
                                        ? startIndex + songsPerPage
                                        : songs.length;

                                final pageSongs =
                                    songs.sublist(startIndex, endIndex);

                                return Container(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: pageSongs.length,
                                          itemBuilder: (context, songIndex) {
                                            var song = pageSongs[songIndex];
                                            var overallIndex = startIndex +
                                                songIndex +
                                                1; // 전체 순위 계산

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: ListTile(
                                                contentPadding:
                                                    EdgeInsets.only(left: 10),
                                                tileColor: Colors.grey
                                                    .withOpacity(0.2),
                                                leading: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '$overallIndex',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Image.network(
                                                      song['albumImage'],
                                                      fit: BoxFit
                                                          .cover, // 이미지 채우기 옵션
                                                      width: 50, // 이미지 너비
                                                      height: 50, // 이미지 높이
                                                    ),
                                                  ],
                                                ),
                                                title: Text(
                                                  song['songTitle'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17),
                                                ),
                                                subtitle: Text(
                                                  song['artist'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SongInfoPage(
                                                        songId: song['songId'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Text(
                            '20대 여자가 즐겨부르는 댄스곡 ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            'assets/images/emoji/mirrorball.png',
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: fetchSongs(5),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final songs = snapshot.data!;
                        return Align(
                          child: Container(
                            height: height * 0.5,
                            child: PageView.builder(
                              controller:
                                  PageController(viewportFraction: 0.93),
                              itemCount: pageCount,
                              itemBuilder: (context, pageIndex) {
                                final startIndex = pageIndex * songsPerPage;
                                final endIndex =
                                    (startIndex + songsPerPage < songs.length)
                                        ? startIndex + songsPerPage
                                        : songs.length;

                                final pageSongs =
                                    songs.sublist(startIndex, endIndex);

                                return Container(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: pageSongs.length,
                                          itemBuilder: (context, songIndex) {
                                            var song = pageSongs[songIndex];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: ListTile(
                                                contentPadding:
                                                    EdgeInsets.only(left: 10),
                                                tileColor: Colors.grey
                                                    .withOpacity(0.2),
                                                leading: Image.network(
                                                  song['albumImage'],

                                                  fit: BoxFit
                                                      .cover, // 이미지 채우기 옵션
                                                ),
                                                title: Text(
                                                  song['songTitle'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17),
                                                ),
                                                subtitle: Text(
                                                  song['artist'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SongInfoPage(
                                                        songId: song['songId'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Text(
                            '나와 음역대 비슷한 사람들의 플리 ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            'assets/images/emoji/headphone.png',
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Image.asset(
                              'assets/images/playlist.png',
                              height: 70,
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Image.asset(
                              'assets/images/playlist.png',
                              height: 70,
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Image.asset(
                              'assets/images/playlist.png',
                              height: 70,
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Image.asset(
                              'assets/images/playlist.png',
                              height: 70,
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Image.asset(
                              'assets/images/playlist.png',
                              height: 70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
