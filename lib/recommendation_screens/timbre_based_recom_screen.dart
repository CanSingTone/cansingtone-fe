import 'package:cansingtone_front/recommendation_screens/song_detail_screen.dart';
import 'package:cansingtone_front/recommendation_screens/timbretest.dart';
import 'package:flutter/material.dart';
import '../service/recom_api.dart'; // 예시에 맞게 서비스 임포트

class TimbreBasedRecomScreen extends StatefulWidget {
  const TimbreBasedRecomScreen({Key? key});

  @override
  State<TimbreBasedRecomScreen> createState() => _TimbreBasedRecomScreenState();
}

class _TimbreBasedRecomScreenState extends State<TimbreBasedRecomScreen> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/recommendation/timbre_based.png',
            height: height * 0.03),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimbreTestPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // 버튼의 모서리를 둥글게 만듦
                        side:
                            BorderSide(color: Colors.black), // 버튼의 테두리 색상 및 너비
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 9.0,
                        horizontal: width * 0.05,
                      ), // 버튼의 내부 패딩
                    ),
                    child: Text(
                      '음색 테스트 다시 하기',
                      style: TextStyle(
                        color: Color(0xFF1A0C0C), // 버튼 텍스트 색상
                        fontSize: 16.0, // 버튼 텍스트 크기
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: recomApi.getTimbreBasedRecommendation('userId'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류 발생: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<dynamic> recommendations = snapshot.data!;

                    // recommendation_date를 기준으로 곡들을 그룹화
                    Map<String, List<dynamic>> groupedRecommendations = {};
                    recommendations.forEach((recommendation) {
                      String recommendationDate =
                          recommendation['recommendationDate'];
                      if (!groupedRecommendations
                          .containsKey(recommendationDate)) {
                        groupedRecommendations[recommendationDate] = [];
                      }
                      groupedRecommendations[recommendationDate]!
                          .add(recommendation);
                    });

                    return ListView(
                      shrinkWrap: true,
                      children: groupedRecommendations.keys.map((date) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 16.0),
                              child: Text(
                                date, // recommendation_date 표시
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: groupedRecommendations[date]!.length,
                              itemBuilder: (context, index) {
                                var recommendation =
                                    groupedRecommendations[date]![index];
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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
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
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  } else {
                    return Center(child: Text('데이터 없음'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
