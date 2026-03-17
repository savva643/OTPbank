import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _envBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (kIsWeb) {
      final v = _envBaseUrl.trim();
      if (v.startsWith('https://')) return v;

      final origin = Uri.base.origin;
      if (v.isEmpty) return '$origin/api';
      if (v.startsWith('/')) return '$origin$v';

      return '$origin/api';
    }

    return _envBaseUrl.trim().isNotEmpty ? _envBaseUrl.trim() : 'http://144.31.86.235/api';
  }
}
