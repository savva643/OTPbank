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
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final AuthTokenStorage _tokenStorage;
}
