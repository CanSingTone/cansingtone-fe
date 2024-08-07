import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../server_addr.dart';

const _API_PREFIX = "http://$SERVER_ADDR/users";

class UsersApi with ChangeNotifier {
  Future<bool> userExists(String id) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
      "$_API_PREFIX/exists",
      queryParameters: {'user_id': id},
    );
    final result = (response.data)['result'];
    print(result);
    return result;
  }
}

UsersApi usersApi = UsersApi();
