import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cansingtone_front/song_detail_screen.dart';

class SongInfoPage extends StatefulWidget {
  final int songId;

  const SongInfoPage({Key? key, required this.songId}) : super(key: key);

  @override
  _SongInfoPageState createState() => _SongInfoPageState();
}

class _SongInfoPageState extends State<SongInfoPage> {
  Map<String, dynamic>? _songInfo;

  @override
  void initState() {
    super.initState();
    _fetchSongInfo();
  }

  Future<void> _fetchSongInfo() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'http://13.125.27.204:8080/songs/${widget.songId}',
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> songInfo = response.data['result'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SongDetailScreen(songInfo: songInfo),
          ),
        );
      } else {
        throw Exception('Failed to load song info');
      }
    } catch (e) {
      print('Error fetching song info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
