import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_store.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(_AuthInterceptor(ref));
  dio.interceptors.add(LogInterceptor(responseBody: false, requestBody: true));
  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this.ref);
  final Ref ref;
  final SecureStore _secure = SecureStore();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secure.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Token $token';
    }
    handler.next(options);
  }
}


