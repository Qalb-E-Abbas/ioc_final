import 'package:shared_preferences/shared_preferences.dart';

class UserLoginStateHandler {

  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceTeacherLoggedInKey = "ISTEACHERLOGGEDIN";

  /// saving data to sharedpreference
  static Future<bool> saveUserLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(
        sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  /// fetching data from sharedpreference
  static Future<bool> getUserLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(sharedPreferenceUserLoggedInKey);
  }



  /// saving data to sharedpreference
  static Future<bool> saveTeacherLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(
        sharedPreferenceTeacherLoggedInKey, isUserLoggedIn);
  }

  /// fetching data from sharedpreference
  static Future<bool> getTeacherLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(sharedPreferenceTeacherLoggedInKey);
  }
}
