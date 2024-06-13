import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../userdata.dart';

class mypage extends StatefulWidget {
  const mypage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<mypage> {
  int _currentIndex = 0;

  bool _isEditing = false;
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _agesController = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    try {

      await UserApi.instance.logout();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // SharedPreferences 초기화
      Provider.of<UserData>(context, listen: false)
          .updateVocalRange(0, 0);

      print('로그아웃 성공');
      // 로그아웃 후 로그인 페이지로 이동
      Navigator.of(context).pushReplacementNamed('/login');

    } catch (error) {
      print('로그아웃 실패 $error');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("로그아웃"),
          content: Text("정말 로그아웃하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? '설정'
              : _currentIndex == 1
              ? '앱 정보'
              : '앱 설정',
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF241D27),
        leading: _currentIndex != 0
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _navigateToPage(0);
          },
        )
            : IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildPageContent(),
    );
  }

  Widget _buildPageContent() {
    switch (_currentIndex) {
      case 0:
        return _buildMyPageContent();
      case 1:
        return AppInfoPage();
      case 2:
        return AppSettingsPage();
      case 3:
        return RecomRecordPage();
      default:
        return Container();
    }
  }

  Widget _buildMyPageContent() {
    final userData = Provider.of<UserData>(context);
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text(
            '앱 정보',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
          onTap: () {
            _navigateToPage(1);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(
            '앱 설정',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
          onTap: () {
            _navigateToPage(2);
          },
        ),
  /*      Divider(),
        ListTile(
          leading: Icon(Icons.receipt_outlined),
          title: Text(
            '추천 기록',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
          onTap: () {
            _navigateToPage(3);
          },
        ),
  */      Divider(),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text(
            '로그아웃',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
          onTap: () {
            _showLogoutDialog();
          },
        ),
        Divider(),
        Center(
          child: Text(
            'Icons by Icons8',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF241D27),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱 버전 : 1.0.0',
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF241D27),
      child: Center(
        child: Text(
          '앱 설정 내용',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
    );
  }
}

class RecomRecordPage extends StatelessWidget {
  const RecomRecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF241D27),
      child: Center(
        child: Text(
          '추천 기록들',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
    );
  }
}
