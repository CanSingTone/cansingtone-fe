import 'package:cansingtone_front/service/playlist_api.dart';
import 'package:cansingtone_front/userdata.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../playlist/likeplaylistinfo.dart';
import '../playlist/playlistinfo.dart';
import '../service/chart_api.dart';
import '../song_detail_screen.dart';
import 'karaoke_top_chart_screen.dart';
import 'mypage.dart';
import 'package:flutter/material.dart';
import '../songinfopage.dart';
import '../search_screens/detailsearch.dart';

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

  Future<List<Song>> fetchSongs(int playlistId) async {
    final response = await http.get(
        Uri.parse('http://13.125.27.204:8080/songs-in-playlist/${playlistId}'));
    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes))['result'];
      return data.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('플레이리스트의 곡을 불러오는데 실패했습니다.');
    }
  }

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
          SliverToBoxAdapter(
            child: SizedBox(
              height: 30,
            ),
          ),
          SliverToBoxAdapter(
            child: KaraokeTopChartPanel(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Text(
                            '${(userData.ages ~/ 10) * 10}대 ${userData.gender == 1 ? '남자' : '여자'}가 즐겨부르는 곡 ',
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
                  SizedBox(height: 5),
                  FutureBuilder<List<dynamic>>(
                    future: chartApi.fetchPersonalizedChart(
                        (userData.ages ~/ 10) * 10, userData.gender),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                            height: height * 0.47,
                            child: Center(child: CircularProgressIndicator()));
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
                                                          SongDetailScreen(
                                                        songInfo: song,
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
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '음역대 비슷한 사람들의 플리 ',
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
                    SizedBox(height: 10),
                    if (userData.vocalRangeHigh == 0 &&
                        userData.vocalRangeLow == 0)
                      Container(
                        height: height * 0.15,
                        child: Center(
                          child: Text(
                            '음역대 정보가 없어 플레이리스트를 제공할 수 없습니다',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    FutureBuilder<List<dynamic>>(
                      future: playlistApi.fetchPlaylistWithSimilarVocalRange(
                          userData.userId,
                          userData.vocalRangeHigh,
                          userData.vocalRangeLow),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Container(
                            height: height * 0.15,
                            child: Center(
                                child: Text('플레이리스트를 찾지 못했습니다.',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16))),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          );
                        } else {
                          final playlists = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: playlists.map((playlist) {
                                return SizedBox(
                                  height: height * 0.2,
                                  width: height * 0.2,
                                  child: PlaylistItem(
                                    title: playlist['playlistName'],
                                    playlistId: playlist['playlistId'],
                                    playlistName: playlist['playlistName'],
                                    isPublic: playlist['isPublic'],
                                    fetchSongs: fetchSongs,
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KaraokeTopChartPanel extends StatefulWidget {
  const KaraokeTopChartPanel({super.key});

  @override
  State<KaraokeTopChartPanel> createState() => _KaraokeTopChartPanelState();
}

class _KaraokeTopChartPanelState extends State<KaraokeTopChartPanel> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final int songsPerPage = 4;
    final int pageCount = (20 / songsPerPage).ceil();

    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  Text(
                    '노래방 TOP50 ',
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
                  SizedBox(width: 10),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KaraokeTopChartScreen(),
                          ),
                        );
                      },
                      child:
                          Text("전체 보기", style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          FutureBuilder<List<dynamic>>(
            future: chartApi.fetchKaraokeTopChart(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: height * 0.47,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final songs = snapshot.data!;
                return Align(
                  child: Container(
                    height: height * 0.47,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.98),
                      itemCount: pageCount,
                      itemBuilder: (context, pageIndex) {
                        final startIndex = pageIndex * songsPerPage;
                        final endIndex =
                            (startIndex + songsPerPage < songs.length)
                                ? startIndex + songsPerPage
                                : songs.length;

                        final pageSongs = songs.sublist(startIndex, endIndex);

                        return Container(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: pageSongs.length,
                                  itemBuilder: (context, songIndex) {
                                    var song = pageSongs[songIndex];
                                    var overallIndex =
                                        startIndex + songIndex + 1; // 전체 순위 계산

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
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
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                                                    fontWeight: FontWeight.bold,
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
                                                        song['songTitle'],
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        song['artist'],
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow
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
    );
  }
}

class Song {
  final String albumImageUrl;

  Song({
    required this.albumImageUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      albumImageUrl: json['songInfo']['albumImage'],
    );
  }
}

class PlaylistItem extends StatelessWidget {
  final String title;
  final int playlistId;
  final String playlistName;
  final int isPublic;
  final Future<List<Song>> Function(int) fetchSongs;

  const PlaylistItem({
    Key? key,
    required this.title,
    required this.playlistId,
    required this.playlistName,
    required this.isPublic,
    required this.fetchSongs,
  }) : super(key: key);

  Future<String?> _getAlbumImageUrl() async {
    List<Song> songs = await fetchSongs(playlistId);
    if (songs.isNotEmpty) {
      return songs[0].albumImageUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        if (playlistName == "좋아요 표시한 음악")
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LikePlaylistInfoPage(
                playlistId: playlistId,
                playlistName: playlistName,
                isPublic: isPublic,
              ),
            ),
          );
        else
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistInfoPage(
                playlistId: playlistId,
                playlistName: playlistName,
                isPublic: isPublic,
              ),
            ),
          );
      },
      child: FutureBuilder<String?>(
        future: _getAlbumImageUrl(),
        builder: (context, snapshot) {
          Widget displayWidget;
          if (snapshot.connectionState == ConnectionState.waiting) {
            displayWidget = CircularProgressIndicator();
          } else if (playlistName == "좋아요 표시한 음악") {
            displayWidget = Image.asset(
              'assets/images/liked_list.png',
              height: height * 0.12,
            );
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            displayWidget = Image.asset(
              'assets/images/playlist.png',
              height: height * 0.12,
            );
          } else {
            displayWidget = ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(snapshot.data!, fit: BoxFit.cover));
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              //border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: displayWidget)),
                SizedBox(height: 10.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
