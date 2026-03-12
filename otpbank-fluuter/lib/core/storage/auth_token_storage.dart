import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStorage {
  static const _kAccessTokenKey = 'accessToken';

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kAccessTokenKey);
    if (token == null || token.trim().isEmpty) return null;
    return token;
  }

  Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessTokenKey, token);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessTokenKey);
  }
}
