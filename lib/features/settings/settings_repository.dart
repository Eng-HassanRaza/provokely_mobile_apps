import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../models/settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository(ref.read));

class SettingsRepository {
  SettingsRepository(this._read);
  final Reader _read;
  Dio get _dio => _read(dioProvider);

  Future<InstagramSettings> getInstagramSettings() async {
    final resp = await _dio.get('/api/v1/core/settings/instagram');
    return InstagramSettings.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<InstagramSettings> updateInstagramSettings(Map<String, dynamic> patch) async {
    final resp = await _dio.put('/api/v1/core/settings/instagram', data: patch);
    return InstagramSettings.fromJson(resp.data['data'] as Map<String, dynamic>);
  }
}


