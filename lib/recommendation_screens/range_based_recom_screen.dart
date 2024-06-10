import 'dart:convert';

import 'package:cansingtone_front/userdata.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cansingtone_front/song_detail_screen.dart';
import 'package:cansingtone_front/test_screens/timbretest.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../service/range_recom_api.dart';
import '../service/timbre_recom_api.dart';
import '../test_screens/vocalrangetest.dart';
import 'package:http/http.dart' as http;

class RangeBasedRecomScreen extends StatefulWidget {
  const RangeBasedRecomScreen({super.key});

  @override
  State<RangeBasedRecomScreen> createState() => _RangeBasedRecomScreenState();
}

Future<String> recomeSong(
    String userId, int vocal_range_high, int vocal_range_low) async {
  final response = await http.post(Uri.parse(
      'http://13.125.27.204:8080/range-based-recommendations?user_id=$userId&vocal_range_high=$vocal_range_high&vocal_range_low=$vocal_range_low'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final bool isSuccess = data['isSuccess'];
    final String message = data['message'];

    if (isSuccess) {
      return message;
    } else {
      throw Exception('요청에 실패했습니다: $message');
    }
  } else {
    throw Exception('서버 요청 중 오류가 발생했습니다: ${response.statusCode}');
  }
}

class _RangeBasedRecomScreenState extends State<RangeBasedRecomScreen> {
  List<dynamic>? recommendations;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            Text(
              '음역대 기반 추천 ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Image.asset(
                'assets/images/emoji/updown.png',
                height: 20,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width * 0.45,
                  child: ElevatedButton(
                    onPressed: () async {
                      await recomeSong(userData.userId, userData.vocalRangeHigh,
                          userData.vocalRangeLow);
                      setState(() {}); // 화면을 새로 고침
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 버튼의 모서리를 둥글게 만듦
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                      ), // 버튼의 내부 패딩
                    ),
                    child: Text(
                      '추천 새로 받기',
                      style: TextStyle(
                        color: Color(0xFF1A0C0C), // 버튼 텍스트 색상
                        fontSize: 15.0, // 버튼 텍스트 크기
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.02),
                SizedBox(
                  width: width * 0.45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VocalRangeTestPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 버튼의 모서리를 둥글게 만듦
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                      ), // 버튼의 내부 패딩
                    ),
                    child: Text(
                      '음역대 테스트 다시 하기',
                      style: TextStyle(
                        color: Color(0xFF1A0C0C), // 버튼 텍스트 색상
                        fontSize: 15.0, // 버튼 텍스트 크기
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: rangeRecomApi.getRangeBasedRecommendation(
                  userData.userId,
                ),
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
  int? likeId;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    //_checkLikeStatus(widget.songInfo['songId']);
    print(widget.songInfo['songId']);
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
    //print(likeId);
  }

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
        print(url);
      } else {
        print('Failed to send like request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending like request: $e');
    }
  }

  Future<void> _getLikeId(int songId) async {
    try {
      // UserData 인스턴스에서 userId를 가져옵니다.
      String userId = Provider.of<UserData>(context, listen: false).getUserId();

      // 서버 URL을 구성합니다.
      String url =
          'http://13.125.27.204:8080/like?user_id=$userId&song_id=$songId';

      // Dio 인스턴스를 생성하여 HTTP GET 요청을 보냅니다.
      Dio dio = Dio();
      Response response = await dio.get(url);
      print(url);
      // 서버 응답 처리
      if (response.statusCode == 200) {
        // 좋아요 ID를 저장합니다.
        dynamic data = response.data;
        if (data != null &&
            data['result'] != null &&
            data['result']['likeId'] != null) {
          likeId = data['result']['likeId'];
          print(likeId);
          _deleteLikeRequest(likeId!);
        } else {
          print('Failed to get likeId');
        }
      } else {
        print('Failed to get likeId: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting likeId: $e');
    }
  }

  // 좋아요 취소 요청을 보내는 함수
  Future<void> _deleteLikeRequest(int likeId) async {
    try {
      // 서버 URL을 구성합니다.
      String url = 'http://13.125.27.204:8080/like?like_id=$likeId';
      print(url);
      // Dio 인스턴스를 생성하여 HTTP DELETE 요청을 보냅니다.
      Dio dio = Dio();
      Response response = await dio.delete(url);

      // 서버 응답 처리
      if (response.statusCode == 200) {
        print('Delete like request sent successfully');
      } else {
        print('Failed to send delete like request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending delete like request: $e');
    }
  }

  Future<void> _checkLikeStatus(int songId) async {
    try {
      // UserData 인스턴스에서 userId를 가져옵니다.
      String userId = Provider.of<UserData>(context, listen: false).getUserId();

      // 서버 URL을 구성합니다.
      String url =
          'http://13.125.27.204:8080/like?user_id=$userId&song_id=$songId';

      // Dio 인스턴스를 생성하여 HTTP GET 요청을 보냅니다.
      Dio dio = Dio();
      Response response = await dio.get(url);
      print(response);
      // 서버 응답 처리
      if (response.statusCode == 200) {
        // isSuccess 값이 true일 때만 좋아요 상태를 업데이트합니다.
        if (response.data['isSuccess']) {
          // 가져온 좋아요 상태를 확인합니다.
          if (isLiked == false) {
            setState(() {
              isLiked = true;
            });
          }
          print('업데이트완료');
        } else {
          print('Failed to get like status: ${response.data['message']}');
          if (isLiked == true) {
            setState(() {
              isLiked = false;
            });
          }
        }
      } else {
        print('Failed to get like status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting like status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var songInfo = widget.songInfo;
    _checkLikeStatus(songInfo['songId']);
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
                if (isLiked) {
                  _sendLikeRequest(songInfo['songId']);
                } else {
                  _getLikeId(songInfo['songId']);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
