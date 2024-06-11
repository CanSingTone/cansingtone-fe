import 'package:flutter/material.dart';
import 'package:cansingtone_front/song_detail_screen.dart';
import '../service/chart_api.dart';

class KaraokeTopChartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF241D27),
      appBar: AppBar(
        title: Text('노래방 TOP 50', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF241D27),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.of(context).pop(); // 뒤로가기 버튼이 클릭되었을 때의 동작
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: chartApi.fetchKaraokeTopChart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<dynamic> recommendations = snapshot.data!;
            return ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                var recommendation = recommendations[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to the song detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SongDetailScreen(songInfo: recommendation),
                      ),
                    );
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              recommendation['albumImage'],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recommendation['songTitle'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  recommendation['artist'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('데이터 없음'));
          }
        },
      ),
    );
  }
}
