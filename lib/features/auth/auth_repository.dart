import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/secure_store.dart';
import '../../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref));

class AuthRepository {
  AuthRepository(this._ref);
  final Ref _ref;
  final SecureStore _secure = SecureStore();

  Dio get _dio => _ref.read(dioProvider);

  Future<UserModel> login({String? username, String? email, required String password}) async {
    final body = <String, dynamic>{'password': password};
    if (username != null && username.isNotEmpty) body['username'] = username;
    if (email != null && email.isNotEmpty) body['email'] = email;

    final resp = await _dio.post('/api/v1/auth/login', data: body);
    final data = resp.data['data'] as Map<String, dynamic>;
    await _secure.saveToken(data['token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel?> me() async {
    try {
      final resp = await _dio.get('/api/v1/auth/me');
      return UserModel.fromJson(resp.data['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _secure.deleteToken();
  }
}


