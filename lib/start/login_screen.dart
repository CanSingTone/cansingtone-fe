import 'package:cansingtone_front/service/users_api.dart';

import '../main.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future setLogin() async {
    // 로그인 상태를 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogin', true);
  }

  Future setUserInfo(String? userId, String? nickname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId!);
    //prefs.setString('nickname', nickname!);
  }

  Future<String?> _get_user_info() async {
    try {
      User user = await UserApi.instance.me();
      String? userId = user.id.toString();
      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}');
      return userId;
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/title.png'),
            SizedBox(height: 16.0),
            InkWell(
                onTap: () async {
                  //print(await KakaoSdk.origin);
                  if (await isKakaoTalkInstalled()) {
                    // 카카오톡이 설치되어 있는 경우
                    try {
                      await UserApi.instance.loginWithKakaoTalk();
                      print('카카오톡으로 로그인 성공');
                      _get_user_info();
                      setLogin();
                      Navigator.of(context).pushReplacementNamed('/nickname');
                    } catch (error) {
                      print('카카오톡으로 로그인 실패 $error');
                      // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
                      try {
                        await UserApi.instance.loginWithKakaoAccount();
                        print('카카오계정으로 로그인 성공');
                        String? id = await _get_user_info(); // 사용자 아이디 가져오기
                        if (id != null) {
                          bool result = await usersApi.userExists(id);
                          if (result) {
                            // 이미 존재하는 사용자의 경우, 로그인 상태 저장 후 index 페이지로 이동
                            // js: 이 부분에서 '회원 ID로 정보조회' API 사용해서 사용자 정보를 가져와서 앱에 저장해야 합니다. provider 쓰신 거 같은데 그거 여기서도 이용하면 될 듯
                            //setLogin(); // js: 로그인하고 나갔다 들어왔을 때 다시 로그인 안 하게 하려고 쓰는 부분입니다. 나중에 주석 푸시면 될 듯
                            Navigator.of(context).pushReplacementNamed('/home');
                          } else {
                            // 존재하지 않는 사용자의 경우, 튜토리얼 페이지로 이동
                            Navigator.of(context).pushReplacementNamed(
                                '/tutorial',
                                arguments:
                                    id); // js: id를 튜토리얼 페이지로 넘겨주면서 이동해야 할 것 같아요. 튜토리얼 페이지에서 아이디 저장하는 거 연결해주세요
                          }
                        }
                      } catch (error) {
                        print('카카오계정으로 로그인 실패 $error');
                      }
                    }
                  } else {
                    // 카카오톡이 설치되어 있지 않은 경우
                    try {
                      await UserApi.instance.loginWithKakaoAccount();
                      print('카카오계정으로 로그인 성공!');
                      String? id = await _get_user_info(); // 사용자 아이디 가져오기
                      if (id != null) {
                        bool result = await usersApi.userExists(id);
                        if (result) {
                          // 이미 존재하는 사용자의 경우, 로그인 상태 저장 후 메인 페이지로 이동
                          // js: 이 부분에서 '회원 ID로 정보조회' API 사용해서 사용자 정보를 DB에서 가져와서 앱에 저장해야 합니다. provider 쓰신 거 같은데 그거 여기서도 이용하면 될 듯
                          //setLogin(); // js: 로그인하고 나갔다 들어왔을 때 다시 로그인 안 하게 하려고 쓰는 부분입니다. 나중에 주석 푸시면 될 듯
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else {
                          // 존재하지 않는 사용자의 경우, 튜토리얼 페이지로 이동
                          Navigator.of(context)
                              .pushReplacementNamed('/tutorial', arguments: id);
                        } // js: id를 튜토리얼 페이지로 넘겨주면서 이동해야 할 것 같아요. 튜토리얼 페이지에서 아이디 저장하는 거 연결해주세요
                      }
                    } catch (error) {
                      print('카카오계정으로 로그인 실패 $error');
                    }
                  }
                },
                child: Image.asset('assets/images/start/kakao_login.png')),
          ],
        ),
      ),
    );
  }
}
