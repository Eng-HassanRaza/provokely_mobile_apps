import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/secure_store.dart';
import '../../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref));

class AuthException implements Exception {
  final String message;
  final dynamic originalError;
  
  AuthException(this.message, [this.originalError]);
  
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._ref);
  final Ref _ref;
  final SecureStore _secure = SecureStore();

  Dio get _dio => _ref.read(dioProvider);

  Future<UserModel> login({String? username, String? email, required String password}) async {
    try {
      if (kDebugMode) {
        print('🔐 Auth: Starting login request');
        print('🔐 Auth: Base URL: ${_dio.options.baseUrl}');
        print('🔐 Auth: Endpoint: /api/v1/auth/login');
        print('🔐 Auth: Username: ${username ?? 'null'}');
        print('🔐 Auth: Email: ${email ?? 'null'}');
      }

      final body = <String, dynamic>{'password': password};
      if (username != null && username.isNotEmpty) body['username'] = username;
      if (email != null && email.isNotEmpty) body['email'] = email;

      if (kDebugMode) {
        print('🔐 Auth: Request body: $body');
      }

      final resp = await _dio.post('/api/v1/auth/login', data: body);
      
      if (kDebugMode) {
        print('🔐 Auth: Response status: ${resp.statusCode}');
        print('🔐 Auth: Response data: ${resp.data}');
      }

      final data = resp.data['data'] as Map<String, dynamic>;
      await _secure.saveToken(data['token'] as String);
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Auth: DioException occurred');
        print('❌ Auth: Error type: ${e.type}');
        print('❌ Auth: Error message: ${e.message}');
        print('❌ Auth: Response data: ${e.response?.data}');
        print('❌ Auth: Response status: ${e.response?.statusCode}');
        print('❌ Auth: Request options: ${e.requestOptions.uri}');
      }

      String errorMessage = 'Login failed';
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Please check your internet connection and try again.';
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        if (statusCode == 401) {
          errorMessage = 'Invalid credentials. Please check your username/email and password.';
        } else if (statusCode == 400) {
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'] as String;
          } else {
            errorMessage = 'Invalid request. Please check your input.';
          }
        } else if (statusCode == 404) {
          errorMessage = 'Server endpoint not found. Please contact support.';
        } else if (statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage = 'Login failed with status code: $statusCode';
        }
      }
      
      throw AuthException(errorMessage, e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth: Unexpected error: $e');
      }
      throw AuthException('Unexpected error occurred: ${e.toString()}', e);
    }
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


