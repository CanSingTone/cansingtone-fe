import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

const _API_PREFIX = "http://13.125.27.204:8080";

class CharApi with ChangeNotifier {
  Future<List<dynamic>> fetchKaraokeTopChart(String userId) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
      "$_API_PREFIX/songs/karaoke-top-chart",
    );
    final result = (response.data)['result'];
    return result;
  }

  Future<List<dynamic>> fetchPersonalizedChart(String userId) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
      "$_API_PREFIX/songs/personalized-chart",
    );
    final result = (response.data)['result'];
    return result;
  }
}
