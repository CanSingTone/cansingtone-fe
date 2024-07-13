import 'dart:convert';
import 'package:http/http.dart' as http;

import '../server_addr.dart';

Future<String> addSongToPlaylist(int playlistId, int songId) async {
  final response = await http.get(Uri.parse(
      'http://$SERVER_ADDR/songs-in-playlist?playlist_id=$playlistId&song_id=$songId'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final bool isSuccess = data['isSuccess'];
    final String message = data['message'];

    if (isSuccess) {
      return message;
    } else {
      throw Exception('요청에 실패했습니다: $message');
    }
  } else {
    throw Exception('서버 요청 중 오류가 발생했습니다: ${response.statusCode}');
  }
}
