import 'package:flutter/material.dart';
import 'package:cansingtone_front/songinfopage.dart';

class SearchResultsPage extends StatelessWidget {
  final List<dynamic> searchResults;

  SearchResultsPage({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF241D27),
      ),
      body: Container(
        color: Color(0xFF241D27),
        child: ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            var result = searchResults[index];
            return ListTile(
              leading: Image.network(
                result['albumImage'] ?? '',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                result['songTitle'] ?? 'Unknown title',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                result['artist'] ?? 'Unknown artist',
                style: TextStyle(color: Colors.grey[400]),
              ),
              tileColor: Color(0xFF241D27),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongInfoPage(songId: result['songId']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
