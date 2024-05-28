import 'package:cansingtone_front/userdata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 이 부분을 추가해야 합니다.

class UserDataService {
  static Future<void> fetchAndSaveUserData(BuildContext context, int userId) async {
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
          print('User ID: ${Provider.of<UserData>(context, listen: false).userId}');
          print('Nickname: ${Provider.of<UserData>(context, listen: false).nickname}');
          print('Gender: ${Provider.of<UserData>(context, listen: false).gender}');
          print('Ages: ${Provider.of<UserData>(context, listen: false).ages}');
          print('Preferred Genre 1: ${Provider.of<UserData>(context, listen: false).prefGenre1}');
          print('Preferred Genre 2: ${Provider.of<UserData>(context, listen: false).prefGenre2}');
          print('Preferred Genre 3: ${Provider.of<UserData>(context, listen: false).prefGenre3}');
          print('Vocal Range High: ${Provider.of<UserData>(context, listen: false).vocalRangeHigh}');
          print('Vocal Range Low: ${Provider.of<UserData>(context, listen: false).vocalRangeLow}');
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
}
