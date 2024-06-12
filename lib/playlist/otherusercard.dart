import 'dart:convert';
import 'package:cansingtone_front/widgets/vocal_range_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

String mapGenre(int genre) {
  switch (genre) {
    case 1:
      return '발라드';
    case 2:
      return '댄스';
    case 3:
      return 'R&B';
    case 4:
      return '힙합';
    case 5:
      return '락';
    case 6:
      return '성인가요';
    default:
      return '';
  }
}

String showVocalRange(int range) {
  return midiNumberToNoteName(range);
}

String midiNumberToNoteName(int midiNumber) {
  if (midiNumber < 21 || midiNumber > 108) {
    return '  ';
  }

  List<String> notes = [
    'A',
    'A#',
    'B',
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#'
  ];

  int octave = (midiNumber - 12) ~/ 12;
  int noteIndex = (midiNumber - 21) % 12;

  String noteName = notes[noteIndex] + octave.toString();
  return noteName;
}

class UserData {
  final String userId;
  final String nickname;
  final int gender;
  final int ages;
  final int prefGenre1;
  final int prefGenre2;
  final int prefGenre3;
  final int vocalRangeHigh;
  final int vocalRangeLow;

  UserData({
    required this.userId,
    required this.nickname,
    required this.gender,
    required this.ages,
    required this.prefGenre1,
    required this.prefGenre2,
    required this.prefGenre3,
    required this.vocalRangeHigh,
    required this.vocalRangeLow,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'],
      nickname: json['nickname'],
      gender: json['gender'],
      ages: json['ages'],
      prefGenre1: json['pref_genre1'],
      prefGenre2: json['pref_genre2'],
      prefGenre3: json['pref_genre3'],
      vocalRangeHigh: json['vocal_range_high'],
      vocalRangeLow: json['vocal_range_low'],
    );
  }
}

class OtherUserCard extends StatefulWidget {
  final String userId;
  final Function() onEditPressed;
  final bool isEditing;

  const OtherUserCard({
    required this.userId,
    required this.onEditPressed,
    required this.isEditing,
  });

  @override
  _OtherUserCardState createState() => _OtherUserCardState();
}

class _OtherUserCardState extends State<OtherUserCard> {
  late Future<UserData> futureUserData;

  @override
  void initState() {
    super.initState();
    futureUserData = fetchUserData(widget.userId);
  }

  Future<UserData> fetchUserData(String userId) async {
    final response =
        await http.get(Uri.parse('http://13.125.27.204:8080/users/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes))['result'];
      return UserData.fromJson(data);
    } else {
      throw Exception('사용자 정보를 불러오는데 실패했습니다.');
    }
  }

  String getGenderText(int gender) {
    switch (gender) {
      case 1:
        return "남성";
      case 2:
        return "여성";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return FutureBuilder<UserData>(
      future: futureUserData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('사용자 정보를 불러오는데 실패했습니다.'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('사용자 정보가 없습니다.'));
        } else {
          final userData = snapshot.data!;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffAA83E2),
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
                margin:
                    EdgeInsets.only(top: height * 0.05, left: 3.0, right: 3.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: width * 0.32,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@${userData.nickname}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${userData.ages}세 ' +
                                      getGenderText(userData.gender),
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 1,
                        color: Colors.black,
                        margin: EdgeInsets.only(top: 15, bottom: 15),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '선호 장르',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              if (userData.prefGenre1 != 0)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                    color: Colors.black,
                                    child: Center(
                                      child: Text(
                                        mapGenre(userData.prefGenre1),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(width: 8),
                              if (userData.prefGenre2 != 0)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                    color: Colors.black,
                                    child: Center(
                                      child: Text(
                                        mapGenre(userData.prefGenre2),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(width: 8),
                              if (userData.prefGenre3 != 0)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                    color: Colors.black,
                                    child: Center(
                                      child: Text(
                                        mapGenre(userData.prefGenre3),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 18.0),
                              Text(
                                '음역대',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                children: [
                                  if (userData.vocalRangeLow != 0 &&
                                      userData.vocalRangeHigh != 0)
                                    CustomPaint(
                                      size: Size(200, 20),
                                      painter: VocalRangePainter(
                                        lowNote: userData.vocalRangeLow,
                                        highNote: userData.vocalRangeHigh,
                                        rangeColor: Color(0xffE365CF),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: 5),
                              Tooltip(
                                message: '음역대 정보',
                                child: IconButton(
                                  icon: Icon(Icons.help_outline),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Color(0xFF241D27),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 10),
                                              Text("남자 평균 음역대",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              CustomPaint(
                                                size: Size(300, 30),
                                                painter: VocalRangePainter(
                                                    lowNote: 45,
                                                    highNote: 66,
                                                    rangeColor: Colors.blue),
                                              ),
                                              SizedBox(height: 50),
                                              Text("여자 평균 음역대",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              CustomPaint(
                                                size: Size(300, 30),
                                                painter: VocalRangePainter(
                                                    lowNote: 52,
                                                    highNote: 72,
                                                    rangeColor: Colors.pink),
                                              ),
                                              SizedBox(height: 50),
                                              Text("${userData.nickname}님의 음역대",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              if (userData.vocalRangeLow != 0 &&
                                                  userData.vocalRangeHigh != 0)
                                                CustomPaint(
                                                  size: Size(300, 30),
                                                  painter: VocalRangePainter(
                                                      lowNote: userData
                                                          .vocalRangeLow,
                                                      highNote: userData
                                                          .vocalRangeHigh,
                                                      rangeColor:
                                                          Color(0xffE365CF)),
                                                )
                                              else
                                                Text(
                                                  "미측정",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                '닫기',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          // Text(
                          //   showVocalRange(userData.vocalRangeLow) +
                          //       ' - ' +
                          //       showVocalRange(userData.vocalRangeHigh),
                          //   style: TextStyle(
                          //     color: Colors.black,
                          //     fontSize: 17.0,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: width * 0.04,
                top: -20,
                child: Image.asset(
                  'assets/images/usercard/girl.png',
                  height: height * 0.18,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
