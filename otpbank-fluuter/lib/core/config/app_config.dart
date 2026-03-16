import 'package:flutter/foundation.dart';

class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: kIsWeb ? '/api' : 'http://144.31.86.235/api',
  );
}
