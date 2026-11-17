import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static late SharedPreferences _prefs;

  static String currentUser = '';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    currentUser = _prefs.getString('username') ?? '';
  }

  static bool get isLoggedIn {
    return _prefs.getBool('isLogin') ?? false;
  }

  static Future<void> login(String username) async {
    currentUser = username;

    await _prefs.setBool('isLogin', true);
    await _prefs.setString('username', username);
  }

  static Future<void> logout() async {
    await _prefs.setBool('isLogin', false);
    await _prefs.remove('username');

    currentUser = '';
  }
}
