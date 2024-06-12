import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

const _API_PREFIX = "http://13.125.27.204:8080/timbre";

class TimbreApi with ChangeNotifier {
  Future<List<dynamic>> fetchTimbres(String userId) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
      "$_API_PREFIX",
      queryParameters: {'user_id': userId},
    );
    final result = (response.data)['result'];
    return result ?? [];
  }
}

TimbreApi timbreApi = TimbreApi();
