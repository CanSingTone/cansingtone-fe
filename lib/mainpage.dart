import 'package:cansingtone_front/service/playlist_api.dart';
import 'package:cansingtone_front/userdata.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

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
  final List<List<dynamic>> imagePaths = [
    ['assets/images/home/banner/gang.png', 6197],
    ['assets/images/home/banner/bubblegum.png', 6199],
    ['assets/images/home/banner/lovewinsall.png', 6198],
  ];

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);
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
              height: height * 0.16,
              child: PageView.builder(
                  controller: PageController(viewportFraction: 0.95),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongInfoPage(
                              songId: imagePaths[index][1] as int,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        height: height * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage(imagePaths[index][0] as String),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: 20),
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
                            height: height * 0.47,
                            child: PageView.builder(
                              controller:
                                  PageController(viewportFraction: 0.98),
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
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              child: GestureDetector(
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
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            song['albumImage'],
                                                            fit: BoxFit.cover,
                                                            width: 50,
                                                            height: 50,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          '$overallIndex',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                song[
                                                                    'songTitle'],
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              SizedBox(
                                                                  height: 5),
                                                              Text(
                                                                song['artist'],
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 13,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
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
                            height: height * 0.47,
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
                                            var overallIndex =
                                                startIndex + songIndex + 1;
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
                                                    Image.network(
                                                      song['albumImage'],
                                                      fit: BoxFit
                                                          .cover, // 이미지 채우기 옵션
                                                      width: 50, // 이미지 너비
                                                      height: 50, // 이미지 높이
                                                    ),
                                                    SizedBox(width: 15),
                                                    Text(
                                                      '$overallIndex',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
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
                  if (userData.vocalRangeHigh == 0 &&
                      userData.vocalRangeLow == 0)
                    Center(
                      child: Text(
                        '음역대를 설정해주세요',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  FutureBuilder<List<dynamic>>(
                    future: playlistApi.fetchPlaylistWithSimilarVocalRange(
                        userData.userId,
                        userData.vocalRangeHigh,
                        userData.vocalRangeLow),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No playlists found'));
                      } else {
                        final playlists = snapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: playlists.map((playlist) {
                              return Container(
                                width: 100,
                                height: 100,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/playlist.png',
                                        height: 70,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        playlist['playlistName'],
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }
                    },
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
