import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/settings.dart';
import 'settings_repository.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = useState<InstagramSettings?>(null);
    final error = useState<String?>(null);
    final loading = useState(true);

    useEffect(() {
      () async {
        try {
          settings.value = await repo.getInstagramSettings();
        } catch (e) {
          error.value = 'Failed to load settings';
        } finally {
          loading.value = false;
        }
      }();
      return null;
    }, const []);

    Future<void> savePatch(Map<String, dynamic> patch) async {
      if (settings.value == null) return;
      final previous = InstagramSettings(
        autoCommentEnabled: settings.value!.autoCommentEnabled,
        responseStyle: settings.value!.responseStyle,
        requireApprovalForNegative: settings.value!.requireApprovalForNegative,
        requireApprovalForHate: settings.value!.requireApprovalForHate,
        notifyOnPositive: settings.value!.notifyOnPositive,
        notifyOnNegative: settings.value!.notifyOnNegative,
        notifyOnHate: settings.value!.notifyOnHate,
        notifyOnNeutral: settings.value!.notifyOnNeutral,
        notifyOnPurchaseIntent: settings.value!.notifyOnPurchaseIntent,
        notifyOnQuestion: settings.value!.notifyOnQuestion,
      );
      // optimistic
      settings.value = InstagramSettings.fromJson({
        ...previous.toJson(),
        ...patch,
      });
      try {
        settings.value = await repo.updateInstagramSettings(patch);
      } catch (e) {
        settings.value = previous; // rollback
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save settings')),
          );
        }
      }
    }

    if (loading.value) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error.value != null) {
      return Scaffold(body: Center(child: Text(error.value!)));
    }
    final s = settings.value!;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Auto comment enabled'),
            value: s.autoCommentEnabled,
            onChanged: (v) => savePatch({'auto_comment_enabled': v}),
          ),
          if (s.autoCommentEnabled) ...[
            SwitchListTile(
              title: const Text('Require approval for negative'),
              value: s.requireApprovalForNegative ?? false,
              onChanged: (v) => savePatch({'require_approval_for_negative': v}),
            ),
            SwitchListTile(
              title: const Text('Require approval for hate'),
              value: s.requireApprovalForHate ?? false,
              onChanged: (v) => savePatch({'require_approval_for_hate': v}),
            ),
          ],
          const Divider(),
          const ListTile(title: Text('Notifications')),
          SwitchListTile(
            title: const Text('Positive'),
            value: s.notifyOnPositive ?? false,
            onChanged: (v) => savePatch({'notify_on_positive': v}),
          ),
          SwitchListTile(
            title: const Text('Negative'),
            value: s.notifyOnNegative ?? false,
            onChanged: (v) => savePatch({'notify_on_negative': v}),
          ),
          SwitchListTile(
            title: const Text('Hate'),
            value: s.notifyOnHate ?? false,
            onChanged: (v) => savePatch({'notify_on_hate': v}),
          ),
          SwitchListTile(
            title: const Text('Neutral'),
            value: s.notifyOnNeutral ?? false,
            onChanged: (v) => savePatch({'notify_on_neutral': v}),
          ),
          SwitchListTile(
            title: const Text('Purchase intent'),
            value: s.notifyOnPurchaseIntent ?? false,
            onChanged: (v) => savePatch({'notify_on_purchase_intent': v}),
          ),
          SwitchListTile(
            title: const Text('Question'),
            value: s.notifyOnQuestion ?? false,
            onChanged: (v) => savePatch({'notify_on_question': v}),
          ),
          const Divider(),
          ListTile(
            title: const Text('Response style'),
            trailing: DropdownButton<String>(
              value: s.responseStyle,
              items: const [
                DropdownMenuItem(value: 'professional', child: Text('Professional')),
                DropdownMenuItem(value: 'casual', child: Text('Casual')),
                DropdownMenuItem(value: 'controversial', child: Text('Controversial')),
                DropdownMenuItem(value: 'sarcastic', child: Text('Sarcastic')),
              ],
              onChanged: (v) => savePatch({'response_style': v}),
            ),
          ),
        ],
      ),
    );
  }
}


