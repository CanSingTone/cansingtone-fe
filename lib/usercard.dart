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
          margin: EdgeInsets.only(top: height * 0.09, left: 3.0, right: 3.0),
          elevation: 5.0,
          color: Color(0xffAA83E2),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 15.0),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.028),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              '@${userData.nickname}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 23.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              '${userData.ages}세 ' +
                                  getGenderText(userData.gender),
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
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
                SizedBox(height: 10.0),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '선호 장르',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
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
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          children: [
                            CustomPaint(
                              size: Size(200, 20),
                              painter: VocalRangePainter(
                                lowNote: 53,
                                highNote: 72,
                              ),
                            ),
                          ],
                        ),
                        Tooltip(
                          message: '낮은 라 ~ 높은 파',
                          child: IconButton(
                            icon: Icon(Icons.help_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('음역대 정보'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomPaint(
                                          size: Size(300, 30),
                                          painter: VocalRangePainter(
                                              lowNote: 41, highNote: 65),
                                        ),
                                        CustomPaint(
                                          size: Size(300, 50),
                                          painter: VocalRangePainter(
                                              lowNote: 53, highNote: 77),
                                        ),
                                        CustomPaint(
                                          size: Size(300, 30),
                                          painter: VocalRangePainter(
                                              lowNote: 50, highNote: 72),
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
                    Text(
                      showVocalRange(userData.vocalRangeLow) +
                          ' - ' +
                          showVocalRange(userData.vocalRangeHigh),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: width * 0.31,
          top: -19,
          child: Image.asset(
            'assets/images/usercard/girl.png',
            height: height * 0.18,
          ),
        ),
      ],
    );
  }
}

class VocalRangePainter extends CustomPainter {
  final int lowNote;
  final int highNote;

  VocalRangePainter({required this.lowNote, required this.highNote});

  @override
  void paint(Canvas canvas, Size size) {
    double totalRange = 108 - 21; // MIDI notes range from 21 to 108
    double lowPosition = (lowNote - 21) / totalRange * size.width;
    double highPosition = (highNote - 21) / totalRange * size.width;

    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10.0;

    Paint rangePaint = Paint()
      ..color = Colors.pink
      ..strokeWidth = 10.0;

    // Draw horizontal line
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), linePaint);

    // Draw vocal range
    canvas.drawLine(Offset(lowPosition, size.height / 2),
        Offset(highPosition, size.height / 2), rangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
