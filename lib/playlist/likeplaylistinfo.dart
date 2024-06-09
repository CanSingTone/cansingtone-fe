import 'dart:convert';
import 'package:cansingtone_front/songinfopage.dart';
import 'package:cansingtone_front/userdata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SongInfo {
  final int songId;
  final String songTitle;
  final String albumImage;
  final String artist;
  final int genre;
  final int artistGender;
  final String songVidUrl;
  final String mrVidUrl;
  final int highestNote;
  final int lowestNote;

  SongInfo({
    required this.songId,
    required this.songTitle,
    required this.albumImage,
    required this.artist,
    required this.genre,
    required this.artistGender,
    required this.songVidUrl,
    required this.mrVidUrl,
    required this.highestNote,
    required this.lowestNote,
  });

  factory SongInfo.fromJson(Map<String, dynamic> json) {
    return SongInfo(
      songId: json['songId'],
      songTitle: json['songTitle'],
      albumImage: json['albumImage'],
      artist: json['artist'],
      genre: json['genre'],
      artistGender: json['artistGender'],
      songVidUrl: json['songVidUrl'],
      mrVidUrl: json['mrVidUrl'],
      highestNote: json['highestNote'],
      lowestNote: json['lowestNote'],
    );
  }
}

class SongInPlaylist {
  final int songInPlaylistId;
  final String playlistId;
  final SongInfo songInfo;

  SongInPlaylist({
    required this.songInPlaylistId,
    required this.playlistId,
    required this.songInfo,
  });

  factory SongInPlaylist.fromJson(Map<String, dynamic> json) {
    return SongInPlaylist(
      songInPlaylistId: json['likeId'],
      playlistId: json['userId'],
      songInfo: SongInfo.fromJson(json['songInfo']),
    );
  }
}

class LikePlaylistInfoPage extends StatefulWidget {
  final int playlistId;
  final String playlistName;
  final int isPublic;

  const LikePlaylistInfoPage({
    Key? key,
    required this.playlistId,
    required this.playlistName,
    required this.isPublic,
  }) : super(key: key);

  @override
  _LikePlaylistInfoPageState createState() => _LikePlaylistInfoPageState();
}

class _LikePlaylistInfoPageState extends State<LikePlaylistInfoPage> {
  late Future<List<SongInPlaylist>> futureSongsInPlaylist;

  @override
  void initState() {
    super.initState();
    futureSongsInPlaylist = fetchSongsInPlaylist();
  }

  Future<List<SongInPlaylist>> fetchSongsInPlaylist() async {
    String? userId = await UserDataShare.getUserId();
    final response = await http.get(Uri.parse('http://13.125.27.204:8080/like/$userId'));

    // 디버깅 로그 추가
    print('User ID: $userId');
    print('Request URL: http://13.125.27.204:8080/like/$userId');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes))['result'];
      // 데이터 구조 확인
      print('Parsed data: $data');
      return data.map((json) => SongInPlaylist.fromJson(json)).toList();
    } else {
      throw Exception('노래를 불러오는데 실패했습니다.');
    }
  }

  Future<void> deleteLikeSongInPlaylist(int likeId) async {
    final response = await http.delete(
      Uri.parse('http://13.125.27.204:8080/like?like_id=$likeId'),
    );
    if (response.statusCode == 200) {
      print('삭제');
      setState(() {
        futureSongsInPlaylist = fetchSongsInPlaylist();
      });
    } else {
      throw Exception('노래를 삭제하는데 실패했습니다.');
    }
  }

  void _showDeleteDialog(BuildContext context, int songInPlaylistId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('노래 삭제'),
          content: Text('정말 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                deleteLikeSongInPlaylist(songInPlaylistId);
                // 삭제 함수 호출
                Navigator.of(context).pop();
              },
              child: Text('예'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('아니오'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPublicText = widget.isPublic == 1 ? '공개' : '비공개';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.playlistName),
            Text(
              isPublicText,
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<SongInPlaylist>>(
        future: futureSongsInPlaylist,
        builder: (context, snapshot) {
          print('FutureBuilder snapshot state: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('FutureBuilder error: ${snapshot.error}');
            return Center(child: Text('노래를 불러오는데 실패했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('노래가 없습니다.'));
          } else {
            final songs = snapshot.data!;
            print('Loaded songs: $songs');
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final songInPlaylist = songs[index];
                final songInfo = songInPlaylist.songInfo;
                final id = songInPlaylist.songInPlaylistId;
                return ListTile(
                  leading: songInfo.albumImage.isNotEmpty
                      ? Image.network(songInfo.albumImage)
                      : Icon(Icons.music_note),
                  title: Text(songInfo.songTitle),
                  subtitle: Text(songInfo.artist),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteDialog(context, id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongInfoPage(
                          songId: songInfo.songId,
                        ),
                      ),
                    );

                    // 세부 정보 페이지로 이동 (나중에 구현)
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
