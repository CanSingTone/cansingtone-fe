import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

import './userdata.dart';
import 'package:provider/provider.dart';

class AudioUploader {
  final String serverUrl = 'http://13.125.27.204:8080/test/vocal-range?';



  Future<void> uploadAudioFile(File audioFile) async {
    try {
      Dio dio = Dio();

      String fileName = basename(audioFile.path);
      FormData formData = FormData.fromMap({
        'user_id': '8',
        'voice_data': await MultipartFile.fromFile(
          audioFile.path,
          filename: fileName,
        ),
      });

      Response response = await dio.post(
        serverUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        print('File uploaded successfully: ${response.data}');
        //updateVocalRange
      } else {
        print('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading audio file: $e');
    }
  }
}