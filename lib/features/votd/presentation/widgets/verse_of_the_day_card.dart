import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router.dart';
import '../providers/votd_providers.dart';

/// Card shown at the top of the Bible tab with today's verse.
class VerseOfTheDayCard extends ConsumerWidget {
  const VerseOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votd = ref.watch(verseOfTheDayProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      clipBehavior: Clip.antiAlias,
      color: scheme.primaryContainer,
      child: votd.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Verse of the day unavailable: $e'),
        ),
        data: (v) => InkWell(
          onTap: () => context.push(
            AppRoutes.reader(v.book.id, v.pool.chapter, verse: v.pool.verse),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 18,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Verse of the Day',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Share',
                      icon: const Icon(Icons.ios_share, size: 20),
                      color: scheme.onPrimaryContainer,
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(text: v.shareText, subject: v.reference),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  v.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${v.reference} · ${v.translationAbbreviation}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
