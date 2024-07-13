import 'dart:convert';
import 'package:cansingtone_front/playlist/otherusercard.dart';
import 'package:cansingtone_front/recommendation_screens/usercard.dart';
import 'package:cansingtone_front/songinfopage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../server_addr.dart';

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
      songInPlaylistId: (json['songInPlaylistId']),
      playlistId: (json['playlistId']),
      songInfo: SongInfo.fromJson(json['songInfo']),
    );
  }
}

class OtherPlaylistInfoPage extends StatefulWidget {
  final int playlistId;
  final String playlistName;
  final int isPublic;
  final String userId;

  const OtherPlaylistInfoPage({
    Key? key,
    required this.playlistId,
    required this.userId,
    required this.playlistName,
    required this.isPublic,
  }) : super(key: key);

  @override
  _OtherPlaylistInfoPageState createState() => _OtherPlaylistInfoPageState();
}

class _OtherPlaylistInfoPageState extends State<OtherPlaylistInfoPage> {
  late Future<List<SongInPlaylist>> futureSongsInPlaylist;

  @override
  void initState() {
    super.initState();
    futureSongsInPlaylist = fetchSongsInPlaylist(widget.playlistId);
  }

  Future<List<SongInPlaylist>> fetchSongsInPlaylist(int playlistId) async {
    final response = await http
        .get(Uri.parse('http://$SERVER_ADDR/songs-in-playlist/$playlistId'));

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes))['result'];
      print('Fetched data: $data'); // 디버깅용 프린트
      return data.map((json) => SongInPlaylist.fromJson(json)).toList();
    } else {
      throw Exception('노래를 불러오는데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        backgroundColor: Color(0xFF241D27),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.playlistName,
                style: TextStyle(fontSize: 20.0, color: Colors.white)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: height * 0.03),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OtherUserCard(
              userId: widget.userId, // 하드코딩된 userId를 widget.userId로 변경
              onEditPressed: () {},
              isEditing: false,
            ),
          ),
          SizedBox(height: height * 0.02),
          Expanded(
            child: FutureBuilder<List<SongInPlaylist>>(
              future: futureSongsInPlaylist,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('노래를 불러오는데 실패했습니다.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('노래가 없습니다.'));
                } else {
                  print('Rendering songs'); // 디버깅용 프린트
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final songInPlaylist = snapshot.data![index];
                      final songInfo = songInPlaylist.songInfo;
                      return ListTile(
                        leading: Image.network(songInfo.albumImage),
                        title: Text(songInfo.songTitle,
                            style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(songInfo.artist,
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.white)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongInfoPage(
                                songId: songInfo.songId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
