import 'package:cansingtone_front/recommendation_screens/timbretest.dart';
import 'package:flutter/material.dart';

class TimbreBasedRecomScreen extends StatefulWidget {
  const TimbreBasedRecomScreen({super.key});

  @override
  State<TimbreBasedRecomScreen> createState() => _TimbreBasedRecomScreenState();
}

class _TimbreBasedRecomScreenState extends State<TimbreBasedRecomScreen> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/recommendation/timbre_based.png',
            height: height * 0.03),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimbreTestPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFec6bae),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Center(
                  child: Text(
                    '음색 테스트 다시 하기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Text('Timbre Based Recommendation'),
          ],
        ),
      ),
    );
  }
}
