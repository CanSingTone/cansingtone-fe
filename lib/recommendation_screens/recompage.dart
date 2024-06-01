import 'package:cansingtone_front/recommendation_screens/song_detail_screen.dart';
import 'package:cansingtone_front/recommendation_screens/timbre_based_recom_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../models/recommendation.dart';
import '../models/song.dart';
import '../service/recom_api.dart';
import 'vocalrangetest.dart';
import 'timbretest.dart';
import '../usercard.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';

class recompage extends StatelessWidget {
  const recompage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final userData = Provider.of<UserData>(context);
    String userId = '7';
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
      body: ListView(padding: EdgeInsets.all(16.0), children: [
        UserCard(
          userData: userData,
          onEditPressed: () {},
          isEditing: false,
        ),
        SizedBox(height: height * 0.01),
        Card(
          elevation: 5.0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimbreBasedRecomScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/recommendation/to_timbre_based.png',
                    height: height * 0.03,
                  ),
                ),
                SizedBox(height: 16.0),
                Column(
                  children: <Widget>[
                    FutureBuilder<List<dynamic>>(
                      future: recomApi
                          .getTimbreBasedRecommendation(userData.userId),
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
                              var recommendation = recommendations[index];
                              var songInfo = recommendation['songInfo'];
                              return GestureDetector(
                                onTap: () {
                                  // 곡 상세 정보 페이지로 이동하는 코드 추가
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SongDetailScreen(songInfo: songInfo),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 1.0),
                                  leading: songInfo['albumImage'] != null
                                      ? Image.network(songInfo['albumImage'])
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
              ],
            ),
          ),
        ),
        SizedBox(height: height * 0.01),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  'assets/images/recommendation/to_range_based.png',
                  height: height * 0.03,
                ),
                SizedBox(height: height * 0.05),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
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
                        fontSize: 14.0,
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
                              fontSize: 16.0,
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
