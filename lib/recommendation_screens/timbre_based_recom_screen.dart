import 'package:cansingtone_front/userdata.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cansingtone_front/song_detail_screen.dart';
import 'package:cansingtone_front/test_screens/timbretest.dart';
import 'package:provider/provider.dart';
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimbreTestPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // 버튼의 모서리를 둥글게 만듦
                      side: BorderSide(color: Colors.black), // 버튼의 테두리 색상 및 너비
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 9.0,
                      horizontal: width * 0.05,
                    ), // 버튼의 내부 패딩
                  ),
                  child: Text(
                    '추천 새로 받기',
                    style: TextStyle(
                      color: Color(0xFF1A0C0C), // 버튼 텍스트 색상
                      fontSize: 16.0, // 버튼 텍스트 크기
                    ),
                  ),
                ),
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
                            BorderRadius.circular(10.0), // 버튼의 모서리를 둥글게 만듦
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
                                  child: SongListTile(songInfo: songInfo),
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

class SongListTile extends StatefulWidget {
  final dynamic songInfo;

  const SongListTile({Key? key, required this.songInfo}) : super(key: key);

  @override
  _SongListTileState createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile> {
  bool isLiked = false;

  void _sendLikeRequest(int songId) async {
    try {
      // UserData 인스턴스에서 userId를 가져옵니다.
      String userId = Provider.of<UserData>(context, listen: false).getUserId();

      // 서버 URL을 구성합니다.
      String url =
          'http://13.125.27.204:8080/like?user_id=$userId&song_id=$songId';

      // Dio 인스턴스를 생성하여 HTTP GET 요청을 보냅니다.
      Dio dio = Dio();
      Response response = await dio.post(url);

      // 서버 응답 처리
      if (response.statusCode == 200) {
        print('Like request sent successfully');
      } else {
        print('Failed to send like request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending like request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var songInfo = widget.songInfo;
    return ListTile(
      visualDensity: VisualDensity(vertical: 0, horizontal: 0),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
      leading: songInfo['albumImage'] != null
          ? Image.network(songInfo['albumImage'])
          : Icon(Icons.music_note),
      title: Text(songInfo['songTitle'],
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(songInfo['artist']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (songInfo['karaokeNum'] != null) Text(songInfo['karaokeNum']),
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                isLiked = !isLiked;
                _sendLikeRequest(songInfo['songId']);
                //좋아요 전송
              });
            },
          ),
        ],
      ),
    );
  }
}
