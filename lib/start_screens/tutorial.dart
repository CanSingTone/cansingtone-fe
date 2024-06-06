import 'package:cansingtone_front/playlist/playlistpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../mainpage.dart';
import '../userdata.dart';
import 'package:provider/provider.dart';

import '../bottombar.dart';
import '../getuserdata.dart';

class User {
  final String userId;
  final String nickname;
  final int gender;
  final int ages;
  final int prefGenre1;
  final int prefGenre2;
  final int prefGenre3;

  User({
    required this.userId,
    required this.nickname,
    required this.gender,
    required this.ages,
    required this.prefGenre1,
    required this.prefGenre2,
    required this.prefGenre3,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      nickname: json['nickname'],
      gender: json['gender'],
      ages: json['ages'],
      prefGenre1: json['pref_genre1'],
      prefGenre2: json['pref_genre2'],
      prefGenre3: json['pref_genre3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'gender': gender,
      'ages': ages,
      'pref_genre1': prefGenre1,
      'pref_genre2': prefGenre2,
      'pref_genre3': prefGenre3,
    };
  }
}

Future<http.Response> createUser(User user) async {
  final Map<String, dynamic> queryParams = {
    'user_id': user.userId,
    'nickname': user.nickname,
    'gender': user.gender.toString(),
    'ages': user.ages.toString(),
    'pref_genre1': user.prefGenre1.toString(),
    'pref_genre2': user.prefGenre2.toString(),
    'pref_genre3': user.prefGenre3.toString(),
  };

  final Uri uri = Uri.http('13.125.27.204:8080', '/users', queryParams);

  print('Request URL: $uri');

  final response = await http.post(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create user');
  }
}

Future<bool> checkUserIdAvailability(int userId) async {
  final response = await http.get(
    Uri.http(
        '13.125.27.204:8080', '/users/exists', {'user_id': userId.toString()}),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final bool isAvailable = data['result'];
    return isAvailable;
  } else {
    // 다른 오류가 발생한 경우
    throw Exception('Failed to check user ID availability');
  }
}

Future<List<Playlist>> fetchPlaylists() async {
  String? userId = await UserDataShare.getUserId(); // userId를 상태 클래스 내에 정의합니다.
  final response = await http
      .get(Uri.parse('http://13.125.27.204:8080/playlists/${userId}'));
  if (response.statusCode == 200) {
    final List<dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes))['result'];
    return data.map((json) => Playlist.fromJson(json)).toList();
  } else {
    throw Exception('플레이리스트를 불러오는데 실패했습니다.');
  }
}

Future<void> createFirstPlaylist(String userId) async {
  final response = await http.post(
    Uri.parse('http://13.125.27.204:8080/playlists'),
    body: {
      'user_id': userId,
      'playlist_name': "좋아요 표시한 음악",
      'is_public': '1',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final int likeplaylistId = data['result'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
  } else {
    throw Exception('플레이리스트 생성에 실패했습니다.');
  }
}

class TutorialPage extends StatefulWidget {
  final VoidCallback onComplete;
  final String? userId;
  TutorialPage({required this.onComplete, this.userId});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _agesController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  List<String> _selectedChoices = [];
  final List<String> _choices = ['발라드', '댄스', 'R&B', '힙합', '락', '성인가요'];

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<void> _fetchAndSaveUserData(int userId) async {
    try {
      final response = await http.get(
        Uri.http('13.125.27.204:8080', '/users/$userId'),
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final String responseBody = response.body;
        if (responseBody.isNotEmpty) {
          final Map<String, dynamic> userDataMap = jsonDecode(responseBody);
          context.read<UserData>().updateFromJson(userDataMap);
          print(
              'User ID: ${Provider.of<UserData>(context, listen: false).userId}');
          print(
              'Nickname: ${Provider.of<UserData>(context, listen: false).nickname}');
          print(
              'Gender: ${Provider.of<UserData>(context, listen: false).gender}');
          print('Ages: ${Provider.of<UserData>(context, listen: false).ages}');
          print(
              'Preferred Genre 1: ${Provider.of<UserData>(context, listen: false).prefGenre1}');
          print(
              'Preferred Genre 2: ${Provider.of<UserData>(context, listen: false).prefGenre2}');
          print(
              'Preferred Genre 3: ${Provider.of<UserData>(context, listen: false).prefGenre3}');
          print(
              'Vocal Range High: ${Provider.of<UserData>(context, listen: false).vocalRangeHigh}');
          print(
              'Vocal Range Low: ${Provider.of<UserData>(context, listen: false).vocalRangeLow}');
        } else {
          throw Exception('Empty response received');
        }
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _submitData() async {
    final String nickname = _nameController.text;
    final String gender = _genderController.text;
    final int ages = int.tryParse(_agesController.text) ?? 0;
//
    final String userId = Provider.of<UserData>(context, listen: false).userId;

    print(userId + 'as');

    UserDataService.fetchAndSaveUserDataS(context, userId);
    if (nickname.isEmpty || gender.isEmpty || ages == 0) {
      return;
    }

    int prefGenre1 = 0;
    int prefGenre2 = 0;
    int prefGenre3 = 0;

    if (_selectedChoices.isNotEmpty) {
      prefGenre1 = _choices.indexOf(_selectedChoices[0]) + 1;
      if (_selectedChoices.length > 1)
        prefGenre2 = _choices.indexOf(_selectedChoices[1]) + 1;
      if (_selectedChoices.length > 2)
        prefGenre3 = _choices.indexOf(_selectedChoices[2]) + 1;
    }

    User newUser = User(
      userId: userId,
      nickname: nickname,
      gender: gender == '남성' ? 1 : (gender == '여성' ? 2 : 3),
      ages: ages,
      prefGenre1: prefGenre1,
      prefGenre2: prefGenre2,
      prefGenre3: prefGenre3,
    );

    try {
      final response = await createUser(newUser);
      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created successfully!')),
        );
        widget.onComplete();
        Provider.of<UserData>(context, listen: false).updateNickname(nickname);
        Provider.of<UserData>(context, listen: false)
            .updateGender(gender == '남성' ? 1 : (gender == '여성' ? 2 : 3));
        Provider.of<UserData>(context, listen: false).updateAges(ages);
        Provider.of<UserData>(context, listen: false)
            .updatePrefGenres(prefGenre1, prefGenre2, prefGenre3);
        createFirstPlaylist(userId);
        // 페이지 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimatedBarExample()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _genderController.dispose();
    _agesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildNamePage(),
            _buildGenderPage(),
            _buildAgePage(),
            _buildChoicesPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      color: Color(0xFF241D27),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '닉네임을 입력해주세요.',
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _nameController,
            onChanged: (value) {
              setState(() {});
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(150, 50),
              backgroundColor: Colors.white, // 버튼의 배경색을 검정으로
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(45), // 모서리를 둥글게
              ),
            ),
            onPressed: _nameController.text.isNotEmpty ? _nextPage : null,
            child: Text('다음',
                style: TextStyle(
                  color: Color(0xFF241D27),
                  fontSize: 18,
                )),
          ),
        ],
      ),
    );
  }

  // Widget _buildGenderPage() {
  //   return Container(
  //     color: Color(0xFF241D27),
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Text(
  //           '성별을 선택해주세요.',
  //           style: TextStyle(fontSize: 24, color: Colors.white),
  //           textAlign: TextAlign.center,
  //         ),
  //         SizedBox(height: 16),
  //         DropdownButtonFormField<String>(
  //           style: TextStyle(color: Color(0xFF241D27), fontSize: 18),
  //           value: _genderController.text.isNotEmpty
  //               ? _genderController.text
  //               : null,
  //           onChanged: (value) {
  //             setState(() {
  //               _genderController.text = value!;
  //             });
  //           },
  //           items: ['남성', '여성']
  //               .map((gender) =>
  //                   DropdownMenuItem(value: gender, child: Text(gender)))
  //               .toList(),
  //           decoration: InputDecoration(
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         SizedBox(height: 16),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             ElevatedButton(
  //               onPressed: _prevPage,
  //               child: Text('이전',
  //                   style: TextStyle(
  //                     color: Colors.black,
  //                     fontSize: 18,
  //                   )),
  //             ),
  //             ElevatedButton(
  //               onPressed: _genderController.text.isNotEmpty ? _nextPage : null,
  //               child: Text('다음',
  //                   style: TextStyle(
  //                     color: Color(0xFF241D27),
  //                     fontSize: 18,
  //                   )),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGenderPage() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      color: Color(0xFF241D27),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '성별을 선택해주세요.',
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _genderController.text = '남성';
                    });
                  },
                  child: Container(
                    height: height * 0.25,
                    // padding: EdgeInsets.all(16),
                    // margin: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: _genderController.text == '남성'
                          ? Color(0xFFC0B4C6)
                          : Color(0xFF403645),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                              height: height * 0.15,
                              child: Image.asset(
                                  'assets/images/usercard/boy.png')),
                        ),
                        Text(
                          '남성',
                          style: TextStyle(
                            color: _genderController.text == '남성'
                                ? Colors.black
                                : Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _genderController.text = '여성';
                    });
                  },
                  child: Container(
                    height: height * 0.25,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: _genderController.text == '여성'
                          ? Color(0xFFC0B4C6)
                          : Color(0xFF403645),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                              height: height * 0.15,
                              child: Image.asset(
                                  'assets/images/usercard/girl.png')),
                        ),
                        Text(
                          '여성',
                          style: TextStyle(
                            color: _genderController.text == '여성'
                                ? Colors.black
                                : Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _prevPage,
                child: Text('이전',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
              ElevatedButton(
                onPressed: _genderController.text.isNotEmpty ? _nextPage : null,
                child: Text('다음',
                    style: TextStyle(
                      color: Color(0xFF241D27),
                      fontSize: 18,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return Container(
      color: Color(0xFF241D27),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '나이를 입력해주세요',
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          TextField(
            style: TextStyle(color: Colors.white),
            controller: _agesController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: '나이',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _prevPage,
                child: Text('이전',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
              ElevatedButton(
                onPressed: _agesController.text.isNotEmpty ? _nextPage : null,
                child: Text('다음',
                    style: TextStyle(
                      color: Color(0xFF241D27),
                      fontSize: 18,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoicesPage() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    List<String> image = [
      'assets/images/tutorial/ballad.png',
      'assets/images/tutorial/dance.png',
      'assets/images/tutorial/rnb.png',
      'assets/images/tutorial/hiphop.png',
      'assets/images/tutorial/rock.png',
      'assets/images/tutorial/trot.png'
    ];

    return Container(
      color: Color(0xFF241D27),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 100),
          Text(
            '노래방에서 부를 때 선호하는 장르를 \n선택해주세요! (최대 3개)',
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          SizedBox(
            height: height * 0.45,
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: _choices.map((choice) {
                bool isSelected = _selectedChoices.contains(choice);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedChoices.remove(choice);
                      } else {
                        if (_selectedChoices.length < 3) {
                          _selectedChoices.add(choice);
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    height: 10,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFC0B4C6) : Color(0xFF403645),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(image[_choices.indexOf(choice)],
                                width: 50, height: 50),
                          ),
                          Text(
                            choice,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _prevPage,
                child: Text('이전',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
              ElevatedButton(
                onPressed: _selectedChoices.isNotEmpty ? _submitData : null,
                child: Text('완료',
                    style: TextStyle(
                      color: Color(0xFF241D27),
                      fontSize: 18,
                    )),
              ),
            ],
          ),
          SizedBox(height: height * 0.05),
        ],
      ),
    );
  }
}
