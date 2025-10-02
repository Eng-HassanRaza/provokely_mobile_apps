import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'approvals_repository.dart';

class ApprovalScreen extends HookConsumerWidget {
  const ApprovalScreen({super.key, required this.commentId, this.initialText, this.initialSentiment, this.initialAiReply});
  final String commentId;
  final String? initialText;
  final String? initialSentiment;
  final String? initialAiReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(approvalsRepositoryProvider);
    final loading = useState(false);
    final text = useState<String?>(initialText);
    final sentiment = useState<String?>(initialSentiment);
    final replyCtrl = useTextEditingController(text: initialAiReply ?? '');
    final saving = useState(false);

    useEffect(() => null, const []);

    Future<void> doApprove() async {
      saving.value = true;
      try {
        await repo.approve(commentId, text: replyCtrl.text.trim().isEmpty ? null : replyCtrl.text.trim());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approved and replied')));
          context.pop();
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to approve')));
        }
      } finally {
        saving.value = false;
      }
    }

    Future<void> doDecline() async {
      saving.value = true;
      try {
        await repo.decline(commentId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Declined')));
          context.pop();
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to decline')));
        }
      } finally {
        saving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Approve Reply')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(text.value ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Sentiment: ${sentiment.value ?? ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: replyCtrl,
              decoration: const InputDecoration(labelText: 'AI reply (editable)'),
              maxLines: 4,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: saving.value ? null : doDecline,
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: saving.value ? null : doApprove,
                    child: saving.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Approve'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


