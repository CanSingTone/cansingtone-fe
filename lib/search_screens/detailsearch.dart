import 'package:cansingtone_front/search_screens/searchresultpage.dart';
import 'package:cansingtone_front/songinfopage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../server_addr.dart';

class DetailSearchPage extends StatefulWidget {
  @override
  _DetailSearchPageState createState() => _DetailSearchPageState();
}

class _DetailSearchPageState extends State<DetailSearchPage> {
  String? selectedCategory;
  List<String> selectedGenres = [];
  RangeValues selectedRange = RangeValues(21, 108);
  TextEditingController _searchController = TextEditingController();

  bool isGenreEnabled = false;
  bool isRangeEnabled = false;

  List<dynamic> searchResults = [];

  void _search() async {
    List<int> genreIds = selectedGenres.map((genre) {
      switch (genre) {
        case '발라드':
          return 1;
        case '댄스':
          return 2;
        case 'R&B':
          return 3;
        case '힙합':
          return 4;
        case '락':
          return 5;
        case '성인가요':
          return 6;
        default:
          return 0;
      }
    }).toList();

    String genresQuery = genreIds.map((id) => 'genres=$id').join('&');

    String keyword = _searchController.text;

    int lowestNote = isRangeEnabled ? selectedRange.start.round() : -1;
    int highestNote = isRangeEnabled ? selectedRange.end.round() : -1;

    String url = 'http://$SERVER_ADDR/songs/search?'
        '$genresQuery&'
        'highest_note=$highestNote&'
        'lowest_note=$lowestNote&'
        'keyword=$keyword';

    try {
      final response =
          await http.get(Uri.parse(url), headers: {"Accept-Charset": "utf-8"});
      if (response.statusCode == 200) {
        final responseData =
            jsonDecode(utf8.decode(response.bodyBytes)); //한글 해결
        if (responseData['result'] is List) {
          setState(() {
            searchResults = responseData['result'] ?? [];
          });
        } else if (responseData['result'] is Map) {
          setState(() {
            searchResults = [responseData['result']];
          });
        } else {
          setState(() {
            searchResults = [];
          });
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SearchResultsPage(searchResults: searchResults),
          ),
        );
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '상세 검색',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Color(0xFF241D27),
      ),
      resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면 크기 조절
      body: Container(
        color: Color(0xFF241D27), // 전체 배경색 설정
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  100, // Adjust height as needed
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '검색 조건',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('제목 또는 가수',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.0)),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[800],
                          hintText: '검색어 입력',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('장르',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.0)),
                      Checkbox(
                        value: isGenreEnabled,
                        onChanged: (bool? value) {
                          setState(() {
                            isGenreEnabled = value ?? false;
                            if (!isGenreEnabled) {
                              selectedGenres.clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (isGenreEnabled)
                    Wrap(
                      spacing: 8.0,
                      children: _buildGenreToggleButtons(),
                    ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('음역대',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.0)),
                      Checkbox(
                        value: isRangeEnabled,
                        onChanged: (bool? value) {
                          setState(() {
                            isRangeEnabled = value ?? false;
                            if (!isRangeEnabled) {
                              selectedRange = RangeValues(21, 108);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (isRangeEnabled)
                    RangeSlider(
                      values: selectedRange,
                      onChanged: (RangeValues values) {
                        if (values.start < 21)
                          values = RangeValues(21, values.end);
                        if (values.end > 108)
                          values = RangeValues(values.start, 108);
                        setState(() {
                          selectedRange = values;
                        });
                      },
                      min: 21,
                      max: 108,
                      divisions: 87,
                      labels: RangeLabels(
                        midiNumberToNoteName(selectedRange.start.round()),
                        midiNumberToNoteName(selectedRange.end.round()),
                      ),
                    ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _search,
                    child: Text('검색',
                        style: TextStyle(color: Colors.white, fontSize: 17.0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffAA83E2),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  Expanded(child: Container()), // 빈 공간을 채우기 위한 위젯
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGenreToggleButtons() {
    List<String> genres = ['발라드', '댄스', 'R&B', '힙합', '락', '성인가요'];
    return List.generate(2, (index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: genres.sublist(index * 3, index * 3 + 3).map((genre) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(genre, style: TextStyle(color: Colors.black)),
              selected: selectedGenres.contains(genre),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedGenres.add(genre);
                  } else {
                    selectedGenres.remove(genre);
                  }
                });
              },
              selectedColor: Colors.lightGreen,
              checkmarkColor: Colors.white,
            ),
          );
        }).toList(),
      );
    }).toList();
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
}
