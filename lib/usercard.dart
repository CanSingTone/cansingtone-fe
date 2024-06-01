import 'package:flutter/material.dart';
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
    return Card(
      elevation: 5.0,
      color: Color(0xffB290E4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 10, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 프로필 사진용 하얀 동그라미 추가
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.grey, size: 30.0),
                  // 여기에 `backgroundImage`를 추가하여 프로필 사진을 설정할 수 있습니다.
                  // backgroundImage: NetworkImage('프로필 이미지 URL'),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${userData.nickname}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '${userData.ages}세 ' + getGenderText(userData.gender),
                        style: TextStyle(
                          color: Colors.black,
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
                      MaterialPageRoute(builder: (context) => EditUserData()),
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
                      '선호 장르  |',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 15.0),
                    if (userData.prefGenre1 != 0)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
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
                        borderRadius: BorderRadius.circular(30),
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
                        borderRadius: BorderRadius.circular(30),
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
                    SizedBox(width: 8),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 18.0),
                    Text(
                      '음역대  |',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      showVocalRange(userData.vocalRangeLow) +
                          ' - ' +
                          showVocalRange(userData.vocalRangeHigh),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                    Tooltip(
                      message: '낮은 라 ~ 높은 파',
                      child: IconButton(
                        icon: Icon(Icons.help_outline),
                        onPressed: () {},
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
