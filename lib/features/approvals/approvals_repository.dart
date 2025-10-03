import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../models/comment_summary.dart';

final approvalsRepositoryProvider = Provider<ApprovalsRepository>((ref) => ApprovalsRepository(ref));

class ApprovalsRepository {
  ApprovalsRepository(this._ref);
  final Ref _ref;
  Dio get _dio => _ref.read(dioProvider);

  Future<CommentSummary> getComment(String id) async {
    // If there's a dedicated endpoint, swap; otherwise assume notification detail provides enough.
    final resp = await _dio.get('/api/v1/core/comments/$id');
    return CommentSummary.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> approve(String id, {String? text}) async {
    await _dio.post('/api/v1/core/comments/$id/approve', data: text == null ? null : {'text': text});
  }

  Future<void> decline(String id) async {
    await _dio.post('/api/v1/core/comments/$id/decline');
  }
}


