import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_repository.dart';
import 'session_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final isLoading = useState(false);
    final useEmail = useState(false);

    Future<void> onLogin() async {
      isLoading.value = true;
      try {
        final repo = ref.read(authRepositoryProvider);
        final user = await repo.login(
          username: useEmail.value ? null : usernameCtrl.text.trim(),
          email: useEmail.value ? emailCtrl.text.trim() : null,
          password: passwordCtrl.text,
        );
        await ref.read(sessionControllerProvider.notifier).setLoggedIn(user);
        if (context.mounted) context.go('/');
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      // Attempt session restore once.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sessionControllerProvider.notifier).restore();
      });
      return null;
    }, const []);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Provokely', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      selected: !useEmail.value,
                      label: const Text('Username'),
                      onSelected: (_) => useEmail.value = false,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      selected: useEmail.value,
                      label: const Text('Email'),
                      onSelected: (_) => useEmail.value = true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!useEmail.value)
                  TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
                if (useEmail.value)
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: isLoading.value ? null : onLogin,
                  child: isLoading.value ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


