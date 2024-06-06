// api_provider.dart
import 'package:dio/dio.dart';
import '../models/recommendation.dart';

const String _API_PREFIX = "http://13.125.27.204:8080";

class RecomApi {
  final Dio _dio = Dio();

  Future<List<dynamic>> getTimbreBasedRecommendation(String userId) async {
    try {
      //Response response = await _dio.get("$_API_PREFIX/$userId/timbre");
      Response response =
          await _dio.get("$_API_PREFIX/timbre-based-recommendations/1");

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['result'];
        return data;
      } else {
        throw Exception('요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }

  Future<List<dynamic>> getRangeBasedRecommendation(String userId) async {
    try {
      Response response = await _dio.get(
        "$_API_PREFIX/range-based-recommendations/1",
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['result'];
        return data;
      } else {
        throw Exception('요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }
}

RecomApi recomApi = RecomApi();
