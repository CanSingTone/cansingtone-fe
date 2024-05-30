// models/recommendation.dart
import 'song.dart';

class Recommendation {
  final int? recommendationId;
  final String userId;
  final int? recommendationMethod;
  final String recommendationDate;
  final Song songInfo;

  Recommendation({
    required this.recommendationId,
    required this.userId,
    required this.recommendationMethod,
    required this.recommendationDate,
    required this.songInfo,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      recommendationId: json['recommendationId'],
      userId: json['userId'],
      recommendationMethod: json['recommendationMethod'],
      recommendationDate: json['recommendationDate'],
      songInfo: Song.fromJson(json['songInfo']),
    );
  }
}
