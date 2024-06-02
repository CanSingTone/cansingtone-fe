import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './playlistinfo.dart';
import 'package:provider/provider.dart';
import '../UserData.dart';

class Playlist {
  final int playlistId;
  final String userId;
  final String playlistName;
  final int isPublic;

  Playlist({
    required this.playlistId,
    required this.userId,
    required this.playlistName,
    required this.isPublic,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      playlistId: json['playlistId'],
      userId: json['userId'],
      playlistName: json['playlistName'],
      isPublic: json['isPublic'],
    );
  }
}


class PlaylistPage extends StatefulWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late Future<List<Playlist>> futurePlaylists;

  @override
  void initState() {
    super.initState();
    futurePlaylists = fetchPlaylists();
  }

  Future<List<Playlist>> fetchPlaylists() async {
    final response = await http.get(Uri.parse('http://13.125.27.204:8080/playlists/3504301360'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes))['result'];
      return data.map((json) => Playlist.fromJson(json)).toList();
    } else {
      throw Exception('플레이리스트를 불러오는데 실패했습니다.');
    }
  }

  Future<void> createPlaylist(String userId, String playlistName, int isPublic) async {
    final response = await http.post(
      Uri.parse('http://13.125.27.204:8080/playlists'),
      body: {
        'user_id': userId,
        'playlist_name': playlistName,
        'is_public': isPublic.toString(),
      },
    );

    if (response.statusCode == 200) {
      // 성공적으로 생성된 경우, 플레이리스트를 다시 불러옴
      setState(() {
        futurePlaylists = fetchPlaylists();
      });
    } else {
      throw Exception('플레이리스트 생성에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        title: Text(
          '플레이리스트',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF241D27),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_rounded),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Playlist>>(
        future: futurePlaylists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('플레이리스트를 불러오는데 실패했습니다.', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('플레이리스트가 없습니다.', style: TextStyle(color: Colors.white)));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final playlist = snapshot.data![index];
                return PlaylistItem(
                  title: playlist.playlistName,
                  playlistId: playlist.playlistId,
                  playlistName: playlist.playlistName,
                  isPublic: playlist.isPublic,
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final _playlistNameController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('새 플레이리스트 만들기'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _playlistNameController,
                    decoration: InputDecoration(labelText: '플레이리스트 이름'),
                  ),
                  Row(
                    children: [
                      Text('공개 여부:'),
                      Switch(
                        value: isPublic,
                        onChanged: (value) {
                          setState(() {
                            isPublic = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('생성'),
                  onPressed: () {
                    final playlistName = _playlistNameController.text;
                    final publicFlag = isPublic ? 1 : 0;
                    createPlaylist('3504301360', playlistName, publicFlag);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
class PlaylistItem extends StatelessWidget {
  final String title;
  final int playlistId;
  final String playlistName;
  final int isPublic;


  const PlaylistItem({Key? key, required this.title, required this.playlistId, required this.playlistName, required this.isPublic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      trailing: Icon(Icons.more_vert, color: Colors.white),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlaylistInfoPage(
            playlistId: playlistId,
            playlistName: playlistName,
            isPublic: isPublic,
          ),),
        );
      },
    );
  }
}