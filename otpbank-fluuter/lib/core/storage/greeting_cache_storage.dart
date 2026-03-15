import 'package:shared_preferences/shared_preferences.dart';

class GreetingCacheStorage {
  static const _kUserNameKey = 'cachedUserName';
  static const _kAvatarUrlKey = 'cachedAvatarUrl';

  Future<({String? userName, String? avatarUrl})> getCached() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString(_kUserNameKey);
    final avatarUrl = prefs.getString(_kAvatarUrlKey);

    final normalizedName = (userName ?? '').trim();
    final normalizedAvatar = (avatarUrl ?? '').trim();

    return (
      userName: normalizedName.isEmpty ? null : normalizedName,
      avatarUrl: normalizedAvatar.isEmpty ? null : normalizedAvatar,
    );
  }

  Future<void> setCached({required String userName, String? avatarUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserNameKey, userName);

    final normalizedAvatar = (avatarUrl ?? '').trim();
    if (normalizedAvatar.isEmpty) {
      await prefs.remove(_kAvatarUrlKey);
    } else {
      await prefs.setString(_kAvatarUrlKey, normalizedAvatar);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserNameKey);
    await prefs.remove(_kAvatarUrlKey);
  }
}
