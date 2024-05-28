import 'package:flutter/material.dart';
import './userdata.dart';

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
    'A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#'
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


  const UserCard({
    required this.userData,
    required this.onEditPressed,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.only(bottom: 16.0),
      color: Color(0xff453D48),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${userData.nickname}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData.ages}세' + '${userData.gender}',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: isEditing ? Icon(Icons.save) : Icon(Icons.edit),
                  onPressed: onEditPressed,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      '선호 장르',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      '|',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    if (userData.prefGenre1 != 0)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          padding: EdgeInsets.all(8),
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
                          padding: EdgeInsets.all(8),
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
                          padding: EdgeInsets.all(8),
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
                SizedBox(height: 16),
                Row(
                    children: [
                    SizedBox(width: 18.0),
                    Text(
                      '음역대',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '|',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      showVocalRange(userData.vocalRangeLow) + ' - ' + showVocalRange(userData.vocalRangeHigh),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15.0,
                      ),
                    ),
                    Tooltip(
                      message: '낮은 라 ~ 높은 파',
                      child: IconButton(
                        icon: Icon(Icons.help_outline),
                        onPressed: () {},
                        color: Colors.white,
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
