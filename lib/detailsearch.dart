import 'package:flutter/material.dart';

class DetailSearchPage extends StatefulWidget {
  @override
  _DetailSearchPageState createState() => _DetailSearchPageState();
}

class _DetailSearchPageState extends State<DetailSearchPage> {
  // Variables to store user selections
  String? selectedCategory;
  List<String> selectedGenres = [];
  RangeValues selectedRange = RangeValues(2, 4);
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세 검색',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFF241D27),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Color(0xFF241D27),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '검색 조건',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제목 또는 가수', style: TextStyle(color: Colors.white)),
                SizedBox(height: 8.0),
                TextFormField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    hintText: '검색어 입력',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('장르', style: TextStyle(color: Colors.white)),
                SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  children: _buildGenreToggleButtons(),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text('음역대', style: TextStyle(color: Colors.white)),
            RangeSlider(
              values: selectedRange,
              onChanged: (RangeValues values) {
                setState(() {
                  selectedRange = values;
                });
              },
              min: 1,
              max: 10,
              divisions: 9,
              labels: RangeLabels(
                selectedRange.start.round().toString(),
                selectedRange.end.round().toString(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {

              },
              child: Text('검색', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }


  List<Widget> _buildGenreToggleButtons() {
    List<String> genres = ['발라드', '댄스', 'R&B', '힙합', '락', '성인가요'];
    return List.generate(2, (index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: genres.sublist(index * 3, index * 3 + 3).map((genre) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(genre, style: TextStyle(color: Colors.black)),
              selected: selectedGenres.contains(genre),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedGenres.add(genre);
                  } else {
                    selectedGenres.remove(genre);
                  }
                });
              },
              selectedColor: Colors.lightGreen,
              checkmarkColor: Colors.white,
            ),
          );
        }).toList(),
      );
    }).toList();
  }
}