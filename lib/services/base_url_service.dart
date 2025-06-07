import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlService {
  static late SharedPreferences _prefs;

  static const String _key = 'base_url';
  static String defaultUrl = 'http://192.168.4.2:6060'; // Example ESP32 IP

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String getBaseUrl() {
    return _prefs.getString(_key) ?? defaultUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_key, url);
  }
}
