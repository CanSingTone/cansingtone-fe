import 'package:flutter/material.dart';


class UserData extends ChangeNotifier {
  String userId = '';
  String nickname = '';
  int gender = 0;
  int ages = 0;
  int prefGenre1 = 0;
  int prefGenre2 = 0;
  int prefGenre3 = 0;
  int vocalRangeHigh = 0;
  int vocalRangeLow = 0;

  String getUserId() {
   return userId;
  }

  void updateUserId(String newUserId) {
    userId = newUserId;
    notifyListeners();
  }

  void updateNickname(String newNickname) {
    nickname = newNickname;
    notifyListeners();
  }

  void updateGender(int newGender) {
    gender = newGender;
    notifyListeners();
  }

  void updateAges(int newAges) {
    ages = newAges;
    notifyListeners();
  }

  void updatePrefGenres(int genre1, int genre2, int genre3) {
    prefGenre1 = genre1;
    prefGenre2 = genre2;
    prefGenre3 = genre3;
    notifyListeners();
  }

  void updateVocalRange(int high, int low) {
    vocalRangeHigh = high;
    vocalRangeLow = low;
    notifyListeners();
  }



  void updateFromJson(Map<String, dynamic> json) {
    userId = json['result']['userId'];
    nickname = json['result']['nickname'];
    gender = json['result']['gender'];
    ages = json['result']['ages'];
    prefGenre1 = json['result']['pref_genre1'];
    prefGenre2 = json['result']['pref_genre2'];
    prefGenre3 = json['result']['pref_genre3'];
    vocalRangeHigh = json['result']['vocal_range_high'];
    vocalRangeLow = json['result']['vocal_range_low'];
    notifyListeners();
  }


}
