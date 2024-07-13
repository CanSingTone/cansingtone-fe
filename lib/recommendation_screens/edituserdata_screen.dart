import 'package:flutter/material.dart';
import '../server_addr.dart';
import '../userdata.dart';
import 'package:provider/provider.dart';
import '../service/getuserdata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditUserData extends StatefulWidget {
  @override
  _EditUserDataState createState() => _EditUserDataState();
}

class _EditUserDataState extends State<EditUserData> {
  List<String> _selectedGenres = [];
  List<String> _genres = [
    '발라드',
    '댄스',
    'R&B',
    '힙합',
    '락',
    '성인가요',
    // Add more genres as needed
  ];

  void _goBack() {
    Navigator.of(context).pop();
  }

  int prefGenre1 = 0;
  int prefGenre2 = 0;
  int prefGenre3 = 0;

  Future<void> _changeData() async {
    final userId = Provider.of<UserData>(context, listen: false).userId;
    final nickname = Provider.of<UserData>(context, listen: false).nickname;
    final ages = Provider.of<UserData>(context, listen: false).ages;

    if (_selectedGenres.isNotEmpty) {
      prefGenre1 = _genres.indexOf(_selectedGenres[0]) + 1;
      if (_selectedGenres.length > 1)
        prefGenre2 = _genres.indexOf(_selectedGenres[1]) + 1;
      if (_selectedGenres.length > 2)
        prefGenre3 = _genres.indexOf(_selectedGenres[2]) + 1;
    }

    Provider.of<UserData>(context, listen: false)
        .updatePrefGenres(prefGenre1, prefGenre2, prefGenre3);

    final url = Uri.parse(
        'http://$SERVER_ADDR/users/$userId?nickname=$nickname&ages=$ages&pref_genre1=$prefGenre1&pref_genre2=$prefGenre2&pref_genre3=$prefGenre3');

    final response = await http.patch(url);
    UserDataService.fetchAndSaveUserDataS(context, userId);
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    } else {
      // Handle the error
      print('Failed to update data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
        ),
        title: Text(
          '선호 장르 수정',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF241D27),
      ),
      body: Container(
        color: Color(0xFF241D27),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 100),
              Text(
                '노래방에서 부를 때 선호하는 장르를 다시 선택해주세요! (최대 3개)',
                style: TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  children: _genres.map((genre) {
                    bool isSelected = _selectedGenres.contains(genre);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedGenres.remove(genre);
                          } else {
                            if (_selectedGenres.length < 3) {
                              _selectedGenres.add(genre);
                            }
                          }
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFFC9D99B)
                              : Colors.transparent,
                          border: Border.all(color: Color(0xFFC9D99B)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            genre,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.black : Color(0xFFC9D99B),
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _selectedGenres.isNotEmpty ? _changeData : null,
                    child: Text('완료'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
