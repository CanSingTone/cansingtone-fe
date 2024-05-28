import 'package:flutter/material.dart';


  class playlist extends StatelessWidget {
  const playlist({Key? key}) : super(key: key);

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
            onPressed: () {

            },
          ),
        ],
      ),
      body: ListView(
        children: [
          PlaylistItem(title: '플레이리스트 1'),
          PlaylistItem(title: '플레이리스트 2'),
          PlaylistItem(title: '플레이리스트 3'),
        ],

      ),
    );
  }
  }
class PlaylistItem extends StatelessWidget {
  final String title;

  const PlaylistItem({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      trailing: Icon(Icons.more_vert, color: Colors.white),
      onTap: () {

      },
    );
  }
}