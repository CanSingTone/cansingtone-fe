import 'dart:convert';
import 'package:cansingtone_front/songinfopage.dart';
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
  final int playlistId;
  final SongInfo songInfo;

  SongInPlaylist({
    required this.songInPlaylistId,
    required this.playlistId,
    required this.songInfo,
  });

  factory SongInPlaylist.fromJson(Map<String, dynamic> json) {
    return SongInPlaylist(
      songInPlaylistId: json['songInPlaylistId'],
      playlistId: json['playlistId'],
      songInfo: SongInfo.fromJson(json['songInfo']),
    );
  }
}

class PlaylistInfoPage extends StatefulWidget {
  final int playlistId;
  final String playlistName;
  final int isPublic;

  const PlaylistInfoPage({
    Key? key,
    required this.playlistId,
    required this.playlistName,
    required this.isPublic,
  }) : super(key: key);


  @override
  _PlaylistInfoPageState createState() => _PlaylistInfoPageState();
}

class _PlaylistInfoPageState extends State<PlaylistInfoPage> {
  late Future<List<SongInPlaylist>> futureSongsInPlaylist;

  @override
  void initState() {
    super.initState();
    futureSongsInPlaylist = fetchSongsInPlaylist(widget.playlistId);
  }

  Future<List<SongInPlaylist>> fetchSongsInPlaylist(int playlistId) async {
    final response = await http.get(Uri.parse('http://13.125.27.204:8080/songs-in-playlist/$playlistId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes))['result'];
      return data.map((json) => SongInPlaylist.fromJson(json)).toList();
    } else {
      throw Exception('노래를 불러오는데 실패했습니다.');
    }
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('노래를 불러오는데 실패했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('노래가 없습니다.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final songInPlaylist = snapshot.data![index];
                final songInfo = songInPlaylist.songInfo;
                return ListTile(
                  leading: Image.network(songInfo.albumImage),
                  title: Text(songInfo.songTitle),
                  subtitle: Text(songInfo.artist),
                  onTap: () {
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