import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/auth_token_storage.dart';

class ApiClient {
  ApiClient({AuthTokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? AuthTokenStorage(),
        dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null) {
            options.headers['authorization'] = 'Bearer $token';
          }

          // ignore: avoid_print
          print('[dio] --> ${options.method} ${options.baseUrl}${options.path}');
          // ignore: avoid_print
          print('[dio] headers: ${options.headers}');
          // ignore: avoid_print
          print('[dio] data: ${options.data}');
          handler.next(options);
        },

        onResponse: (response, handler) {
          // ignore: avoid_print
          print(
            '[dio] <-- ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
          );
          // ignore: avoid_print
          print('[dio] response: ${response.data}');
          handler.next(response);
        },

        onError: (e, handler) {
          // ignore: avoid_print
          print('[dio] xx ${e.type} ${e.message}');
          // ignore: avoid_print
          print('[dio] url: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
          // ignore: avoid_print
          print('[dio] response: ${e.response?.statusCode} ${e.response?.data}');

          final statusCode = e.response?.statusCode;
          if (statusCode == 401) {
            _tokenStorage.clear();
          }

          if (statusCode == 404 && e.requestOptions.path == '/user/profile') {
            final data = e.response?.data;
            if (data is Map && data['error'] is Map) {
              final err = data['error'] as Map;
              final code = err['code']?.toString();
              if (code == 'not_found') {
                _tokenStorage.clear();
              }
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  final Dio dio;
  final AuthTokenStorage _tokenStorage;
}
