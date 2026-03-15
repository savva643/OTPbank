import 'package:shared_preferences/shared_preferences.dart';

class PinCodeStorage {
  static const _kPinCodeKey = 'pinCode';

  Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kPinCodeKey);
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPinCodeKey, pin);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPinCodeKey);
  }
}
