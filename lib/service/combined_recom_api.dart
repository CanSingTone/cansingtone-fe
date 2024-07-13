// api_provider.dart
import 'package:dio/dio.dart';
import '../models/recommendation.dart';
import '../server_addr.dart';

const String _API_PREFIX = "http://$SERVER_ADDR/combined-recommendations";

class CombinedRecomApi {
  final Dio _dio = Dio();
  Future<String> requestCombinedRecommendation(String userId) async {
    try {
      Response response = await _dio
          .post("$_API_PREFIX/request", queryParameters: {'user_id': userId});

      if (response.statusCode == 200) {
        String data = response.data['result'];

        return data;
      } else {
        throw Exception('요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }

  Future<List<dynamic>> getCombinedRecommendation(String userId) async {
    try {
      Response response = await _dio.get(
        "$_API_PREFIX/$userId",
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

CombinedRecomApi combinedRecomApi = CombinedRecomApi();
