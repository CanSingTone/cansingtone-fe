import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

import '../server_addr.dart';
import '../userdata.dart';
import 'package:provider/provider.dart';

class AudioUploaderT {
  final String serverUrl = 'http://$SERVER_ADDR/test/timbre?';
  final BuildContext context;
  final String userId;

  AudioUploaderT(this.context)
      : userId = Provider.of<UserData>(context, listen: false).getUserId();

  Future<void> uploadAudioFileT(File audioFile) async {
    try {
      Dio dio = Dio();

      String fileName = basename(audioFile.path);
      FormData formData = FormData.fromMap({
        'user_id': userId,
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
