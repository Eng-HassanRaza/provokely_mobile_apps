import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uni_links/uni_links.dart';

import '../../features/auth/login_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/connect/connect_instagram_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/approvals/approval_screen.dart';
import '../../features/auth/session_controller.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: _SessionListenable(ref),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/connect', builder: (_, __) => const ConnectInstagramScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(
        path: '/approval/:commentId',
        builder: (ctx, state) => ApprovalScreen(
          commentId: state.pathParameters['commentId']!,
          initialText: (state.extra as Map?)?['text'] as String?,
          initialSentiment: (state.extra as Map?)?['sentiment'] as String?,
          initialAiReply: (state.extra as Map?)?['ai_reply'] as String?,
        ),
      ),
    ],
    redirect: (ctx, state) {
      final session = ref.read(sessionControllerProvider);
      final loggedIn = session.isLoggedIn;
      final onLogin = state.fullPath == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/';
      return null;
    },
  );

  // Deep link listener: provokely://oauth/instagram?status=success
  linkStream.listen((link) {
    if (link == null) return;
    final uri = Uri.parse(link);
    if (uri.scheme == 'provokely' && uri.host == 'oauth' && uri.path == '/instagram') {
      router.push('/connect', extra: uri.queryParameters);
    }
  });

  // Handle initial deep link if app launched via URL
  () async {
    try {
      final link = await getInitialLink();
      if (link == null) return;
      final uri = Uri.parse(link);
      if (uri.scheme == 'provokely' && uri.host == 'oauth' && uri.path == '/instagram') {
        router.push('/connect', extra: uri.queryParameters);
      }
    } catch (_) {}
  }();

  return router;
});

class _SessionListenable extends ChangeNotifier {
  _SessionListenable(this.ref) {
    ref.listen(sessionControllerProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}


