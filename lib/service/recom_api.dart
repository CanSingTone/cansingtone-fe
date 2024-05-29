import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

const _API_PREFIX = "13.125.27.204:8080/recommendations";

class RecomApi with ChangeNotifier {
  Future<Map<String, dynamic>> getTimbreBasedRecommendation(
      String userId) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get("$_API_PREFIX/{$userId}/timbre");
    final result = (response.data)['result'];
    return result;
  }
}

RecomApi recomApi = RecomApi();
