import 'dart:convert';

import 'package:cansingtone_front/recommendation_screens/range_based_recom_screen.dart';
import 'package:cansingtone_front/song_detail_screen.dart';
import 'package:cansingtone_front/recommendation_screens/timbre_based_recom_screen.dart';
import 'package:cansingtone_front/test_screens/timbretest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/combined_recom_api.dart';
import '../service/range_recom_api.dart';
import '../service/timbre_api.dart';
import '../service/timbre_recom_api.dart';
import '../test_screens/vocalrangetest.dart';
import 'usercard.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';

import 'package:http/http.dart' as http;

import 'combined_recom_screen.dart';

class RecompageState {
  static const String _isFirstKey = 'isFirst';

  bool _isFirst = true;

  bool get isFirst => _isFirst;

  Future<void> loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirst = prefs.getBool(_isFirstKey) ?? true;
  }

  Future<void> setFirstFalse() async {
    _isFirst = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstKey, false);
  }
}

class recompage extends StatefulWidget {
  const recompage({Key? key}) : super(key: key);

  @override
  _recompageState createState() => _recompageState();
}

class _recompageState extends State<recompage> {
  bool isfirst = true;
  bool isLoading = false;
  List<int> timbreIds = []; // 리스트 선언
  int? firstTimbreId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<bool> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userData = Provider.of<UserData>(context, listen: false);
      final String userId = userData.userId;
      List<dynamic> timbres = await timbreApi.fetchTimbres(userData.userId);
      if (timbres.isNotEmpty) {
        setState(() {
          firstTimbreId = timbres.first['timbreId'];
        });
      }

      final response = await http
          .get(Uri.parse('http://13.125.27.204:8080/timbre?user_id=$userId'));
      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      if (timbres != []) {
        // result 배열에서 각 timbreId를 추출하여 리스트에 추가
        final List<dynamic> result = data['result'];

        for (var item in result) {
          timbreIds.add(item['timbreId']);
        }
        setState(() {
          isfirst = false;
        });
        print(isfirst);
      } else {
        print(isfirst);
        setState(() {
          isfirst = true;
        });
      }

      setState(() {
        isLoading = false;
      });

      return true;
    } catch (e) {
      print('Error: $e');

      setState(() {
        isLoading = false;
      });

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        title: Text(
          '추천',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF241D27),
      ),
      body: ListView(padding: EdgeInsets.all(15.0), children: [
        UserCard(
          userData: userData,
          onEditPressed: () {},
          isEditing: false,
        ),
        SizedBox(height: height * 0.02),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (isfirst == true ||
                    (userData.vocalRangeLow == 0 &&
                        userData.vocalRangeHigh == 0))
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * 0.05),
                      Text(
                        '종합 추천은 음역대/음색 테스트를\n모두 완료해야 제공합니다.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '음역대/음색 테스트를 진행해주세요',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 17.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.05),
                    ],
                  )
                else
                  Column(
                    children: [
                      SizedBox(height: 5),
                      FutureBuilder<List<dynamic>>(
                        future: combinedRecomApi
                            .getCombinedRecommendation(userData.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                                height: height * 0.4,
                                child:
                                    Center(child: CircularProgressIndicator()));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('오류 발생: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<dynamic> recommendations = snapshot.data!;
                            if (recommendations.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  child: Column(
                                    children: [
                                      Text('이제 종합 추천을 받을 수 있습니다.',
                                          style: TextStyle(fontSize: 19.0)),
                                      SizedBox(height: 15.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 48.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              combinedRecomApi
                                                  .requestCombinedRecommendation(
                                                      userData.userId);

                                              setState(() {});
                                            },
                                            child: Text(
                                              '추천 받기',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFB290E4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 16.0),
                                              minimumSize: Size(0, 48),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '종합 추천 ',
                                      style: TextStyle(
                                        color: Color(0xFF241D27),
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Image.asset(
                                        'assets/images/emoji/notes.png',
                                        height: 20,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CombinedRecomScreen()),
                                        );
                                      },
                                      child: Text(
                                        '    상세 보기',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: 4,
                                  itemBuilder: (context, index) {
                                    var recommendation =
                                        recommendations[index]['songInfo'];
                                    return GestureDetector(
                                      onTap: () {
                                        // 곡 상세 정보 페이지로 이동하는 코드 추가
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SongDetailScreen(
                                                    songInfo: recommendation),
                                          ),
                                        );
                                      },
                                      child: ListTile(
                                        visualDensity: VisualDensity.compact,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 5.0, vertical: 1.0),
                                        leading: recommendation['albumImage'] !=
                                                null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image.network(
                                                    recommendation[
                                                        'albumImage']))
                                            : Icon(Icons.music_note),
                                        title:
                                            Text(recommendation['songTitle']),
                                        subtitle:
                                            Text(recommendation['artist']),
                                        trailing: recommendation[
                                                    'karaokeNum'] !=
                                                null
                                            ? Text(recommendation['karaokeNum'])
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          } else {
                            return Center(child: Text('데이터 없음'));
                          }
                        },
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: <Widget>[
                if (isfirst == true)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * 0.05),
                      Text(
                        '음색 추천 기능이 처음이시군요?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '음색 측정 테스트를 진행해주세요',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 17.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final isSuccess = await fetchData();
                              setState(() {
                                isfirst = !isSuccess;
                              });
                              if (isfirst) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TimbreTestPage(
                                          cameFrom: 'recompage')),
                                );
                              }
                            },
                            child: Text(
                              '테스트하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFB290E4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              minimumSize: Size(0, 48),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                    ],
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '음색 기반 추천 ',
                            style: TextStyle(
                              color: Color(0xFF241D27),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Image.asset(
                              'assets/images/emoji/voice.png',
                              height: 25,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TimbreBasedRecomScreen()),
                              );
                            },
                            child: Text(
                              '   상세 보기',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      FutureBuilder<List<dynamic>>(
                        future: firstTimbreId == null
                            ? Future.value([]) // null 대신 빈 리스트를 반환하도록 처리
                            : timbreRecomApi.getTimbreBasedRecommendation(
                                userData.userId, firstTimbreId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                                height: height * 0.4,
                                child:
                                    Center(child: CircularProgressIndicator()));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('오류 발생: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<dynamic> recommendations = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                var recommendation = recommendations[index];
                                var songInfo = recommendation['songInfo'];
                                return GestureDetector(
                                  onTap: () {
                                    // 곡 상세 정보 페이지로 이동하는 코드 추가
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SongDetailScreen(
                                            songInfo: songInfo),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 1.0),
                                    leading: songInfo['albumImage'] != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Image.network(
                                                songInfo['albumImage']))
                                        : Icon(Icons.music_note),
                                    title: Text(songInfo['songTitle']),
                                    subtitle: Text(songInfo['artist']),
                                    trailing: songInfo['karaokeNum'] != null
                                        ? Text(songInfo['karaokeNum'])
                                        : null,
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(child: Text('데이터 없음'));
                          }
                        },
                      ),
                    ],
                  ),
              ]),
            )),
        SizedBox(height: height * 0.02),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (userData.vocalRangeLow != 0 && userData.vocalRangeHigh != 0)
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '음역대 기반 추천 ',
                            style: TextStyle(
                              color: Color(0xFF241D27),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Image.asset(
                              'assets/images/emoji/updown.png',
                              height: 20,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RangeBasedRecomScreen()),
                              );
                            },
                            child: Text(
                              '    상세 보기',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      FutureBuilder<List<dynamic>>(
                        future: rangeRecomApi
                            .getRangeBasedRecommendation(userData.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('오류 발생: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<dynamic> recommendations = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                var recommendation =
                                    recommendations[index]['songInfo'];
                                return GestureDetector(
                                  onTap: () {
                                    // 곡 상세 정보 페이지로 이동하는 코드 추가
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SongDetailScreen(
                                            songInfo: recommendation),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 1.0),
                                    leading: recommendation['albumImage'] !=
                                            null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Image.network(
                                                recommendation['albumImage']))
                                        : Icon(Icons.music_note),
                                    title: Text(recommendation['songTitle']),
                                    subtitle: Text(recommendation['artist']),
                                    trailing:
                                        recommendation['karaokeNum'] != null
                                            ? Text(recommendation['karaokeNum'])
                                            : null,
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(child: Text('데이터 없음'));
                          }
                        },
                      ),
                    ],
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * 0.05),
                      Text(
                        '음역대 추천 기능이 처음이시군요?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '음역대 측정 테스트를 진행해주세요',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 17.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VocalRangeTestPage()),
                              );
                            },
                            child: Text(
                              '테스트하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFB290E4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              minimumSize: Size(0, 48),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class TimbreBasedCard extends StatefulWidget {
  const TimbreBasedCard({super.key});

  @override
  State<TimbreBasedCard> createState() => _TimbreBasedCardState();
}

class _TimbreBasedCardState extends State<TimbreBasedCard> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
