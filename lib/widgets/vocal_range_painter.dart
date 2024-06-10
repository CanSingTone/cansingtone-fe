import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VocalRangePainter extends CustomPainter {
  final int lowNote;
  final int highNote;
  final Color lineColor;
  final Color rangeColor;

  VocalRangePainter({
    required this.lowNote,
    required this.highNote,
    this.lineColor = Colors.white,
    this.rangeColor = const Color(0xffE365CF),
  });

  String getMidiNoteName(int midiNote) {
    final noteNames = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B'
    ];
    int octave = (midiNote / 12).floor() - 1;
    int noteIndex = (midiNote % 12).floor();
    return '${noteNames[noteIndex]}$octave';
  }

  @override
  void paint(Canvas canvas, Size size) {
    double totalRange = 84 - 34; // MIDI notes range from 21 to 108
    double lowPosition = (lowNote - 34) / totalRange * size.width;
    double highPosition = (highNote - 34) / totalRange * size.width;

    Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    Paint rangePaint = Paint()
      ..color = rangeColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawLine(Offset(3, size.height / 2 + 3),
        Offset(size.width + 3, size.height / 2 + 3), shadowPaint);

    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), linePaint);

    canvas.drawLine(Offset(lowPosition, size.height / 2),
        Offset(highPosition, size.height / 2), rangePaint);

    // 시작점과 끝점에 동그라미 그리기
    Paint circlePaint = Paint()
      ..color = rangeColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(lowPosition, size.height / 2), 10, circlePaint);
    canvas.drawCircle(Offset(highPosition, size.height / 2), 10, circlePaint);

    // 동그라미에 하이라이트 효과 추가
    Paint circleHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 노트 값 텍스트 그리기
    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    String lowNoteText = getMidiNoteName(lowNote);
    String highNoteText = getMidiNoteName(highNote);

    textPainter.text = TextSpan(
      text: lowNoteText,
      style: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(lowPosition - textPainter.width / 2, size.height / 2 + 16));

    textPainter.text = TextSpan(
      text: highNoteText,
      style: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(highPosition - textPainter.width / 2, size.height / 2 + 16));
  }

  @override
  bool shouldRepaint(VocalRangePainter oldDelegate) {
    return oldDelegate.lowNote != lowNote ||
        oldDelegate.highNote != highNote ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.rangeColor != rangeColor;
  }
}
