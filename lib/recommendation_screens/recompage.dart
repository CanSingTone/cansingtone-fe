import 'package:cansingtone_front/recommendation_screens/timbre_based_recom_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'vocalrangetest.dart';
import 'timbretest.dart';
import '../usercard.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';

class recompage extends StatelessWidget {
  const recompage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        title: Text(
          '추천',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF241D27),
      ),
      body: ListView(padding: EdgeInsets.all(16.0), children: [
        UserCard(
          userData: userData,
          onEditPressed: () {},
          isEditing: false,
        ),
        SizedBox(height: height * 0.01),
        Card(
          elevation: 5.0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimbreBasedRecomScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/recommendation/timbre_based.png',
                    height: height * 0.03,
                  ),
                ),
                SizedBox(height: 16.0),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          print(await KakaoSdk.origin);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFa03de7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Center(
                          child: Text(
                            '추천 내역 확인',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFa03de7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Center(
                          child: Text(
                            '추천 새로 받기',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: height * 0.01),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  'assets/images/recommendation/range_based.png',
                  height: height * 0.03,
                ),
                SizedBox(height: 20.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '음역대 추천 기능이 처음이시군요?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '음역대 측정 테스트를 진행해주세요',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VocalRangeTestPage()),
                            );
                          },
                          child: Text(
                            '테스트하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB290E4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            minimumSize: Size(0, 48),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class TestSelectionPage extends StatelessWidget {
  const TestSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        title: Text(
          '테스트 선택',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF241D27),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.brown,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '음색측정테스트',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.black54,
                        ),
                      ),
                      Text(
                        '미완료',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 2,
            color: Colors.white,
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VocalRangeTestPage()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '음역대측정테스트',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.black54,
                        ),
                      ),
                      Text(
                        '미완료',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}