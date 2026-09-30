import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../../domain/entities/book.dart';
import '../providers/bible_providers.dart';
import '../providers/reading_position_provider.dart';
import '../widgets/translation_chip.dart';

/// Lists this edition's books grouped by their stored testament.
class BooksScreen extends ConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: TranslationChip(),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: books,
        onRetry: () => ref.invalidate(booksProvider),
        data: (list) {
          final ot = list.where((b) => b.isOldTestament).toList();
          final nt = list.where((b) => !b.isOldTestament).toList();
          final last = ref.watch(lastReadChapterProvider);
          final lastBook = list
              .where(
                (b) =>
                    b.id == last?.bookId &&
                    last!.chapter > 0 &&
                    last.chapter <= b.chapterCount,
              )
              .firstOrNull;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (last != null && lastBook != null)
                _ContinueCard(
                  title: '${lastBook.name} ${last.chapter}',
                  onTap: () =>
                      context.push(AppRoutes.reader(last.bookId, last.chapter)),
                ),
              _SectionHeader('Old Testament', ot.length),
              for (final b in ot) _BookTile(book: b),
              _SectionHeader('New Testament', nt.length),
              for (final b in nt) _BookTile(book: b),
            ],
          );
        },
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.play_circle_fill, color: scheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue reading',
                        style: text.labelMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        title,
                        style: text.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.count);
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count books',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(book.name),
      trailing: Text(
        '${book.chapterCount}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () => context.go(AppRoutes.chapters(book.id)),
    );
  }
}
