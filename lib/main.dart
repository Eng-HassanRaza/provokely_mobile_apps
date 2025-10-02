import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'features/push/push_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const ProvokelyApp(),
  ));

  // Fire-and-forget push init; guarded by dart-define.
  unawaited(initializePushIfEnabled(container));
}

class ProvokelyApp extends ConsumerWidget {
  const ProvokelyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return MaterialApp.router(
      title: 'Provokely',
      theme: theme,
      darkTheme: ThemeData.dark(useMaterial3: true),
      routerConfig: router,
    );
  }
}


