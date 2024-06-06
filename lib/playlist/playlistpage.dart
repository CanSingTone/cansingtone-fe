import 'dart:convert';
import 'package:cansingtone_front/playlist/likeplaylistinfo.dart';
import 'package:cansingtone_front/userdata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './playlistinfo.dart';

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

class Song {
  final String albumImageUrl;

  Song({
    required this.albumImageUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      albumImageUrl: json['songInfo']['albumImage'],
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
    String? userId = await UserDataShare.getUserId();
    final response = await http.get(Uri.parse('http://13.125.27.204:8080/playlists/${userId}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes))['result'];
      return data.map((json) => Playlist.fromJson(json)).toList();
    } else {
      throw Exception('플레이리스트를 불러오는데 실패했습니다.');
    }
  }

  Future<List<Song>> fetchSongs(int playlistId) async {
    final response = await http.get(Uri.parse('http://13.125.27.204:8080/songs-in-playlist/${playlistId}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes))['result'];
      return data.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('플레이리스트의 곡을 불러오는데 실패했습니다.');
    }
  }

  Future<void> createPlaylist(String userId, String playlistName, int isPublic) async {
    String? userId = await UserDataShare.getUserId();
    final response = await http.post(
      Uri.parse('http://13.125.27.204:8080/playlists'),
      body: {
        'user_id': userId,
        'playlist_name': playlistName,
        'is_public': isPublic.toString(),
      },
    );

    if (response.statusCode == 200) {
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
            return GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final playlist = snapshot.data![index];
                return PlaylistItem(
                  title: playlist.playlistName,
                  playlistId: playlist.playlistId,
                  playlistName: playlist.playlistName,
                  isPublic: playlist.isPublic,
                  fetchSongs: fetchSongs,
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) async {
    final _playlistNameController = TextEditingController();
    bool isPublic = false;
    String? userId = await UserDataShare.getUserId();
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
                    createPlaylist(userId!, playlistName, publicFlag);
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
  final Future<List<Song>> Function(int) fetchSongs;

  const PlaylistItem({
    Key? key,
    required this.title,
    required this.playlistId,
    required this.playlistName,
    required this.isPublic,
    required this.fetchSongs,
  }) : super(key: key);

  Future<String?> _getAlbumImageUrl() async {
    List<Song> songs = await fetchSongs(playlistId);
    if (songs.isNotEmpty) {
      return songs[0].albumImageUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (playlistName == "좋아요 표시한 음악")
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LikePlaylistInfoPage(
              playlistId: playlistId,
              playlistName: playlistName,
              isPublic: isPublic,
            ),
          ),
        );
        else
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistInfoPage(
                playlistId: playlistId,
                playlistName: playlistName,
                isPublic: isPublic,
              ),
            ),
          );
      },
      child: FutureBuilder<String?>(
        future: _getAlbumImageUrl(),
        builder: (context, snapshot) {
          Widget displayWidget;
          if (snapshot.connectionState == ConnectionState.waiting) {
            displayWidget = CircularProgressIndicator();
          } else if (playlistName == "좋아요 표시한 음악") {
            displayWidget = Icon(Icons.thumb_up, color: Colors.white, size: 70.0);
          }else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            displayWidget = Icon(Icons.music_note, color: Colors.white, size: 70.0);
          } else {
            displayWidget = Image.network(snapshot.data!, fit: BoxFit.cover);
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              //border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: displayWidget)),
                SizedBox(height: 10.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
