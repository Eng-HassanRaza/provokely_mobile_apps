import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'connect_repository.dart';

class ConnectInstagramScreen extends HookConsumerWidget {
  const ConnectInstagramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final statusText = useState('');
    final extraParams = GoRouterState.of(context).extra as Map<String, String?>?;

    Future<void> checkStatusAndProceed() async {
      final connected = await ref.read(connectRepositoryProvider).getStatusConnected();
      if (connected) {
        if (context.mounted) context.go('/');
      } else {
        statusText.value = 'Not connected yet. Please retry.';
      }
    }

    useEffect(() {
      if (extraParams != null && extraParams['status'] == 'success') {
        statusText.value = 'Connected! Finalizing...';
        checkStatusAndProceed();
      } else if (extraParams != null && extraParams['status'] == 'error') {
        statusText.value = 'Connection failed. Please try again.';
      }
      return null;
    }, const []);

    Future<void> onConnect() async {
      isLoading.value = true;
      try {
        final result = await ref.read(connectRepositoryProvider).getAuthUrl();
        final uri = Uri.parse(result.url);
        
        // Try to open Instagram app first, fallback to external browser
        bool launched = false;
        
        // First try: Launch with external app preference (Instagram app)
        try {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          // If external app fails, try external browser
          try {
            launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            // Final fallback: in-app browser
            launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          }
        }
        
        if (!launched) {
          throw Exception('Could not open Instagram connection');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initiate Instagram connect: ${e.toString()}')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Connect Instagram')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Connect your Instagram account to enable replies and notifications.'),
              const SizedBox(height: 16),
              if (statusText.value.isNotEmpty) Text(statusText.value),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isLoading.value ? null : onConnect,
                child: isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Connect Instagram'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

