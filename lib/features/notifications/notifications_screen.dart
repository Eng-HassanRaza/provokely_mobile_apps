import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/notification_item.dart';
import '../notifications/notifications_repository.dart';
import '../connect/connect_repository.dart';

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = useState<List<NotificationItem>>([]);
    final page = useState(1);
    final nextPage = useState<int>(1);
    final loading = useState(false);
    final count = useState(0);

    Future<void> load({bool initial = false}) async {
      if (loading.value) return;
      if (!initial && nextPage.value == -1) return;
      loading.value = true;
      final repo = ref.read(notificationsRepositoryProvider);
      try {
        final res = await repo.list(page: initial ? 1 : nextPage.value);
        if (initial) {
          items.value = res.items;
          page.value = 1;
        } else {
          items.value = [...items.value, ...res.items];
          page.value = nextPage.value;
        }
        nextPage.value = res.nextPage;
        count.value = await repo.count();
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      () async {
        // Gate: ensure Instagram is connected, otherwise redirect to connect screen.
        try {
          final connected = await ref.read(connectRepositoryProvider).getStatusConnected();
          if (!connected && context.mounted) {
            context.push('/connect');
          }
        } catch (_) {}
        await load(initial: true);
      }();
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings),
              ),
              if (count.value > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: Text('${count.value}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
            ],
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => load(initial: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.value.length + 1,
          itemBuilder: (context, index) {
            if (index == items.value.length) {
              if (nextPage.value == -1) {
                return const SizedBox(height: 64);
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: loading.value ? null : () => load(initial: false),
                    child: loading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Load more'),
                  ),
                ),
              );
            }
            final n = items.value[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(n.sentimentLabel.substring(0, 1).toUpperCase())),
                title: Text(n.previewText, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(n.sentimentLabel),
                trailing: n.needsApproval ? const Chip(label: Text('Needs approval')) : const SizedBox.shrink(),
                onTap: () => context.push('/approval/${n.commentId}', extra: {
                  'text': n.previewText,
                  'sentiment': n.sentimentLabel,
                  'ai_reply': n.aiReply,
                }),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/connect'),
        icon: const Icon(Icons.link),
        label: const Text('Connect IG'),
      ),
    );
  }
}


