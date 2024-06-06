import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import './userdata.dart';
import './edituserdata.dart';

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

class UserCard extends StatelessWidget {
  final UserData userData;
  final Function() onEditPressed;
  final bool isEditing;

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

  const UserCard({
    required this.userData,
    required this.onEditPressed,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          margin: EdgeInsets.only(top: height * 0.04, left: 3.0, right: 3.0),
          elevation: 5.0,
          color: Color(0xffAA83E2),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
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
                              fontSize: 23.0,
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
                    IconButton(
                      icon: isEditing ? Icon(Icons.save) : Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditUserData()),
                        );
                      },
                      color: Colors.black,
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),
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
                              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
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
                              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
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
                              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
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
                                        Text("남자 평균 음역대",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        CustomPaint(
                                          size: Size(300, 30),
                                          painter: VocalRangePainter(
                                              lowNote: 45,
                                              highNote: 66,
                                              rangeColor: Colors.blue),
                                        ),
                                        SizedBox(height: 50),
                                        Text("여자 평균 음역대",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        CustomPaint(
                                          size: Size(300, 30),
                                          painter: VocalRangePainter(
                                              lowNote: 52,
                                              highNote: 72,
                                              rangeColor: Colors.pink),
                                        ),
                                        SizedBox(height: 50),
                                        Text("당신의 음역대",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        CustomPaint(
                                          size: Size(300, 30),
                                          painter: VocalRangePainter(
                                              lowNote: userData.vocalRangeLow,
                                              highNote: userData.vocalRangeHigh,
                                              rangeColor: Color(0xffE365CF)),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('닫기'),
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
            height: height * 0.19,
          ),
        ),
      ],
    );
  }
}

class VocalRangePainter extends CustomPainter {
  final int lowNote;
  final int highNote;
  final Color lineColor;
  final Color rangeColor;

  VocalRangePainter({
    required this.lowNote,
    required this.highNote,
    this.lineColor = Colors.white,
    this.rangeColor = const Color(0xffE365CF),
  });

  String getMidiNoteName(int midiNote) {
    final noteNames = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B'
    ];
    int octave = (midiNote / 12).floor() - 1;
    int noteIndex = (midiNote % 12).floor();
    return '${noteNames[noteIndex]}$octave';
  }

  @override
  void paint(Canvas canvas, Size size) {
    double totalRange = 108 - 21; // MIDI notes range from 21 to 108
    double lowPosition = (lowNote - 21) / totalRange * size.width;
    double highPosition = (highNote - 21) / totalRange * size.width;

    Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    Paint rangePaint = Paint()
      ..color = rangeColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawLine(Offset(3, size.height / 2 + 3),
        Offset(size.width + 3, size.height / 2 + 3), shadowPaint);

    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), linePaint);

    canvas.drawLine(Offset(lowPosition, size.height / 2),
        Offset(highPosition, size.height / 2), rangePaint);

    // 시작점과 끝점에 동그라미 그리기
    Paint circlePaint = Paint()
      ..color = rangeColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(lowPosition, size.height / 2), 10, circlePaint);
    canvas.drawCircle(Offset(highPosition, size.height / 2), 10, circlePaint);

    // 동그라미에 하이라이트 효과 추가
    Paint circleHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 노트 값 텍스트 그리기
    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    String lowNoteText = getMidiNoteName(lowNote);
    String highNoteText = getMidiNoteName(highNote);

    textPainter.text = TextSpan(
      text: lowNoteText,
      style: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(lowPosition - textPainter.width / 2, size.height / 2 + 16));

    textPainter.text = TextSpan(
      text: highNoteText,
      style: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(highPosition - textPainter.width / 2, size.height / 2 + 16));
  }

  @override
  bool shouldRepaint(VocalRangePainter oldDelegate) {
    return oldDelegate.lowNote != lowNote ||
        oldDelegate.highNote != highNote ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.rangeColor != rangeColor;
  }
}
