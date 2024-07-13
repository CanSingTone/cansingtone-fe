import 'dart:convert';

import 'package:cansingtone_front/service/addplaylist.dart';
import 'package:cansingtone_front/recommendation_screens/timbre_management_screen.dart';
import 'package:cansingtone_front/userdata.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cansingtone_front/song_detail_screen.dart';
import 'package:cansingtone_front/test_screens/timbretest.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../server_addr.dart';
import '../service/timbre_recom_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../service/timbre_api.dart';

Future<String?> getLikePlaylistId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('likeplaylistId');
}

class TimbreBasedRecomScreen extends StatefulWidget {
  const TimbreBasedRecomScreen({Key? key});

  @override
  State<TimbreBasedRecomScreen> createState() => _TimbreBasedRecomScreenState();
}

class _TimbreBasedRecomScreenState extends State<TimbreBasedRecomScreen> {
  int? selectedTimbreId;

  @override
  void initState() {
    super.initState();
    _initializeSelectedTimbre();
  }

  Future<void> _initializeSelectedTimbre() async {
    final userData = Provider.of<UserData>(context, listen: false);
    List<dynamic> timbres = await timbreApi.fetchTimbres(userData.userId);
    if (timbres.isNotEmpty) {
      setState(() {
        selectedTimbreId = timbres.first['timbreId'];
      });
    }
  }

  void _showLoadingDialog(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: height * 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitWave(
                  color: Color(0xffAA83E2),
                  size: 50.0,
                ),
                SizedBox(height: 20),
                Text("추천곡을 받아오는 중입니다...", style: TextStyle(fontSize: 17)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 로딩 다이얼로그를 닫는 함수
  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.of(context).pop(); // 뒤로가기 버튼이 클릭되었을 때의 동작
          },
        ),
        centerTitle: true,
        title: Row(
          children: [
            Text(
              '음색 기반 추천 ',
              style: TextStyle(
                color: Colors.black,
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
            SizedBox(width: 10),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width,
            height: height * 0.05,
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: timbreApi.fetchTimbres(userData.userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<dynamic> timbres = snapshot.data!;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: timbres.length,
                          itemBuilder: (context, index) {
                            var timbre = timbres[index];
                            bool isSelected =
                                timbre['timbreId'] == selectedTimbreId;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTimbreId = timbre['timbreId'];
                                });
                              },
                              child: Container(
                                height: 30,
                                margin: EdgeInsets.only(left: 10),
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xffAA83E2)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    timbre['timbreName'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black54),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimbreManagementScreen()),
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[200],
            height: height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10),
              SizedBox(
                width: width * 0.45,
                child: ElevatedButton(
                  onPressed: () async {
                    _showLoadingDialog(context); // 로딩 다이얼로그 표시
                    try {
                      await timbreRecomApi.requestTimbreBasedRecommendation(
                          userData.userId, selectedTimbreId!);
                      setState(() {});
                    } finally {
                      _hideLoadingDialog(context); // 로딩 다이얼로그 닫기
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    side: BorderSide(
                      color: Color(0xFF1A0C0C),
                      width: 1.0,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 9.0,
                      horizontal: width * 0.05,
                    ),
                  ),
                  child: Text(
                    '추천 새로 받기',
                    style: TextStyle(
                      color: Color(0xFF1A0C0C),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
              // SizedBox(width: 10),
              // SizedBox(
              //   width: width * 0.45,
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0),
              //       ),
              //       padding: EdgeInsets.symmetric(
              //         horizontal: width * 0.05,
              //       ),
              //     ),
              //     child: Text(
              //       '음색 테스트 다시 하기',
              //       style: TextStyle(
              //         color: Color(0xFF1A0C0C),
              //         fontSize: 15.0,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: selectedTimbreId == null
                  ? null
                  : timbreRecomApi.getTimbreBasedRecommendation(
                      userData.userId, selectedTimbreId!),
              builder: (context, snapshot) {
                if (selectedTimbreId == null) {
                  return SizedBox();
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
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
                                      builder: (context) =>
                                          SongDetailScreen(songInfo: songInfo),
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
      String url = 'http://$SERVER_ADDR/like?user_id=$userId&song_id=$songId';

      // Dio 인스턴스를 생성하여 HTTP GET 요청을 보냅니다.
      Dio dio = Dio();
      Response response = await dio.post(url);

      // 서버 응답 처리
      if (response.statusCode == 200) {
        //  print('Like request sent successfully');
        // print(url);
      } else {
        //  print('Failed to send like request: ${response.statusCode}');
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
      String url = 'http://$SERVER_ADDR/like?user_id=$userId&song_id=$songId';

      // Dio 인스턴스를 생성하여 HTTP GET 요청을 보냅니다.
      Dio dio = Dio();
      Response response = await dio.get(url);
      //print(url);
      // 서버 응답 처리
      if (response.statusCode == 200) {
        // 좋아요 ID를 저장합니다.
        dynamic data = response.data;
        if (data != null &&
            data['result'] != null &&
            data['result']['likeId'] != null) {
          likeId = data['result']['likeId'];
          //print(likeId);
          _deleteLikeRequest(likeId!);
        } else {
          //    print('Failed to get likeId');
        }
      } else {
        //  print('Failed to get likeId: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting likeId: $e');
    }
  }

  // 좋아요 취소 요청을 보내는 함수
  Future<void> _deleteLikeRequest(int likeId) async {
    try {
      // 서버 URL을 구성합니다.
      String url = 'http://$SERVER_ADDR/like?like_id=$likeId';
      //print(url);
      // Dio 인스턴스를 생성하여 HTTP DELETE 요청을 보냅니다.
      Dio dio = Dio();
      Response response = await dio.delete(url);

      // 서버 응답 처리
      if (response.statusCode == 200) {
        // print('Delete like request sent successfully');
      } else {
        // print('Failed to send delete like request: ${response.statusCode}');
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
      String url = 'http://$SERVER_ADDR/like?user_id=$userId&song_id=$songId';

      // Dio 인스턴스를 생성하여 HTTP GET 요청을 보냅니다.
      Dio dio = Dio();
      Response response = await dio.get(url);
      //print(response);
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
          // print('업데이트완료');
        } else {
          //print('Failed to get like status: ${response.data['message']}');
          if (isLiked == true) {
            setState(() {
              isLiked = false;
            });
          }
        }
      } else {
        //print('Failed to get like status: ${response.statusCode}');
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
