import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/dio_client.dart';

final connectRepositoryProvider = Provider<ConnectRepository>((ref) => ConnectRepository(ref.read));

class ConnectRepository {
  ConnectRepository(this._read);
  final Reader _read;
  Dio get _dio => _read(dioProvider);

  Future<({String url, String state})> getAuthUrl() async {
    final resp = await _dio.get('/api/v1/instagram/accounts/mobile/auth-url');
    final data = resp.data['data'] as Map<String, dynamic>;
    return (url: data['url'] as String, state: data['state'] as String);
  }

  Future<bool> getStatusConnected() async {
    final resp = await _dio.get('/api/v1/instagram/accounts/mobile/status');
    final data = resp.data['data'] as Map<String, dynamic>;
    return data['connected'] as bool? ?? false;
  }
}


