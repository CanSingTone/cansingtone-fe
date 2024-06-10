// timbre_based_recom_screen.dart 파일에서

// ... 기존 import 문들 ...
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/timbre_api.dart';
import '../userdata.dart';

// ... 기존 코드 ...

class TimbreManagementScreen extends StatefulWidget {
  @override
  _TimbreManagementScreenState createState() => _TimbreManagementScreenState();
}

class _TimbreManagementScreenState extends State<TimbreManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('음색 관리'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // 음색 테스트 화면으로
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: timbreApi.fetchTimbres(userData.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('음색이 없습니다.'));
          } else {
            List<dynamic> timbres = snapshot.data!;
            return ListView.builder(
              itemCount: timbres.length,
              itemBuilder: (context, index) {
                var timbre = timbres[index];
                return ListTile(
                  title: Text(timbre['timbreName'],
                      style: TextStyle(fontSize: 18)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              String newTimbreName = timbre['timbreName'];
                              return AlertDialog(
                                title: Text('음색 이름 수정'),
                                content: TextField(
                                  onChanged: (value) {
                                    newTimbreName = value;
                                  },
                                  decoration: InputDecoration(
                                    hintText: '새 음색 이름',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text('수정'),
                                    onPressed: () {
                                      // 음색 수정 API 호출
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          // 삭제 확인 다이얼로그 표시
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('음색 삭제'),
                                content: Text('이 음색을 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text('삭제'),
                                    onPressed: () {
                                      // 음색 삭제 API 호출
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
