import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

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
        setState(() {
          _songInfo = response.data['result'];
        });
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
      appBar: AppBar(
        title: Text(_songInfo?['songTitle'] ?? 'Song Info', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF241D27),
        leading:IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [ ],
      ),
      backgroundColor: Color(0xFF241D27),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Image.network(
                      _songInfo?['albumImage'] ?? '',
                      height: 200,
                      width: 200,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '아티스트: ${_songInfo?['artist'] ?? ''}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        '장르: ${_mapGenre(_songInfo?['genre'] ?? 0)}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Uri uri = Uri.parse(_songInfo?['songVidUrl'] ?? '');
                  _launchVideo(uri);
                },
                child: Text('노래 영상'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Uri uri = Uri.parse(_songInfo?['mrVidUrl'] ?? '');
                  _launchVideo(uri);
                },
                child: Text('밴드 MR 영상'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _mapGenre(int genre) {
    switch (genre) {
      case 1:
        return '발라드';
      case 2:
        return '댄스';
      case 3:
        return 'R&B';
      case 4:
        return '힙합';
      case 5:
        return '락';
      case 6:
        return '성인가요';
      default:
        return '';
    }
  }

  Future<void> _launchVideo(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}
