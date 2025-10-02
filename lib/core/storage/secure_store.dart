import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _keyAuthToken = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _keyAuthToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyAuthToken);
  }
}


