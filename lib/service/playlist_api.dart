import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

const _API_PREFIX = "http://13.125.27.204:8080/playlists";

class PlaylistApi with ChangeNotifier {
  Future<List<dynamic>> fetchPlaylistWithSimilarVocalRange(
      String userId, int vocalRangeHigh, int vocalRangeLow) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
      "$_API_PREFIX/similar-vocal-range",
      queryParameters: {
        'user_id': userId,
        'vocal_range_high': vocalRangeHigh,
        'vocal_range_low': vocalRangeLow
      },
    );
    final result = (response.data)['result'];
    return result;
  }
}

PlaylistApi playlistApi = PlaylistApi();
