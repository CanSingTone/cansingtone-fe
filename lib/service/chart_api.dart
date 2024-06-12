import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

const _API_PREFIX = "http://13.125.27.204:8080";

class CharApi with ChangeNotifier {
  Future<List<dynamic>> fetchKaraokeTopChart() async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
      "$_API_PREFIX/charts/karaoke-top-chart",
    );
    final result = (response.data)['result'];
    //print(result);
    return result;
  }

  Future<List<dynamic>> fetchPersonalizedChart(
      int preferAge, int preferGender) async {
    Response response;

    Dio dio = new Dio();
    try {
      response = await dio.get(
        "$_API_PREFIX/charts/personalized-chart",
        queryParameters: {
          'age': preferAge,
          'gender': preferGender,
        },
      );
      final result = response.data['result'];

      return result;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

CharApi chartApi = CharApi();
