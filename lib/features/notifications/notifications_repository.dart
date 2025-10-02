import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../models/notification_item.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) => NotificationsRepository(ref.read));

class NotificationsRepository {
  NotificationsRepository(this._read);
  final Reader _read;
  Dio get _dio => _read(dioProvider);

  Future<({List<NotificationItem> items, int nextPage})> list({required int page, int pageSize = 20}) async {
    final resp = await _dio.get(
      '/api/v1/core/notifications/',
      queryParameters: {
        'needs_approval': true,
        'is_read': false,
        'page': page,
        'page_size': pageSize,
      },
    );
    final results = (resp.data['data']['results'] as List<dynamic>).cast<Map<String, dynamic>>();
    final items = results.map(NotificationItem.fromJson).toList();
    final next = resp.data['data']['next'] as String?; // could be URL
    final nextPage = next == null ? -1 : page + 1;
    return (items: items, nextPage: nextPage);
  }

  Future<int> count() async {
    final resp = await _dio.get('/api/v1/core/notifications/count');
    return (resp.data['data']['count'] as num).toInt();
  }

  Future<void> markRead(String id) async {
    await _dio.patch('/api/v1/core/notifications/$id/mark_read');
  }

  Future<void> markAllRead() async {
    await _dio.post('/api/v1/core/notifications/mark_all_read');
  }
}


