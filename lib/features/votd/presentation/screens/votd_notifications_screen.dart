import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/votd_providers.dart';

/// Verse-of-the-Day notification history: the last [historyDays] days'
/// verses, most recent first.
class VotdNotificationsScreen extends ConsumerWidget {
  const VotdNotificationsScreen({super.key});

  static const historyDays = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recent = ref.watch(recentVersesOfTheDayProvider(historyDays));

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: recent.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Unable to load notifications: $e')),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                leading: const CircleAvatar(
                  child: Icon(Icons.notifications_outlined),
                ),
                title: Text(
                  item.verse.reference,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.verse.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Text(
                  _dayLabel(item.day),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _dayLabel(DateTime day) {
    final today = DateTime.now();
    final diff = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${day.month}/${day.day}';
  }
}
