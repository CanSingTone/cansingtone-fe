import 'package:cansingtone_front/recommendation_screens/timbre_based_recom_screen.dart';
import 'package:cansingtone_front/test_screens/timbretest.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../server_addr.dart';
import '../service/timbre_api.dart';
import '../userdata.dart';

class TimbreManagementScreen extends StatefulWidget {
  @override
  _TimbreManagementScreenState createState() => _TimbreManagementScreenState();
}

class _TimbreManagementScreenState extends State<TimbreManagementScreen> {
  Future<void> _deleteTimbre(int timbreId) async {
    final response = await http.delete(
      Uri.parse('http://$SERVER_ADDR/timbre/$timbreId'),
    );

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음색 삭제에 실패했습니다.')),
      );
    }
  }

  Future<void> _updateTimbre(int timbreId, String newTimbreName) async {
    final response = await http.patch(
      Uri.parse(
          'http://$SERVER_ADDR/timbre/$timbreId?timbre_name=$newTimbreName'),
    );

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음색 수정에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('음색 관리'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final timbres = await timbreApi.fetchTimbres(userData.userId);
              if (timbres.length >= 3) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('음색 추가 불가'),
                      content: Text('음색의 개수가 최대치입니다!'),
                      actions: [
                        TextButton(
                          child: Text('닫기'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('음색 추가'),
                      content: Text('새로 음색을 추가하러 가시겠습니까?'),
                      actions: [
                        TextButton(
                          child: Text('확인'),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimbreTestPage(
                                    cameFrom: 'timbre_management_screen'),
                              ),
                            );
                          },
                        ),
                        TextButton(
                          child: Text('닫기'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
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
                                      _updateTimbre(
                                          timbre['timbreId'], newTimbreName);
                                      Navigator.pop(context);
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
                                      _deleteTimbre(timbre['timbreId']);
                                      Navigator.pop(context);
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
