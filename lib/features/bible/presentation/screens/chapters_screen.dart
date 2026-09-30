import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../providers/bible_providers.dart';

/// Grid of chapter numbers for one book.
class ChaptersScreen extends ConsumerWidget {
  const ChaptersScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        title: Text(book.isLoading ? '' : book.valueOrNull?.name ?? ''),
      ),
      body: AsyncValueWidget(
        value: book,
        onRetry: () => ref.invalidate(bookProvider(bookId)),
        data: (b) {
          if (b == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted &&
                  GoRouterState.of(context).uri.path ==
                      AppRoutes.chapters(bookId))
                context.go(AppRoutes.read);
            });
            return const Center(child: Text('Opening this edition…'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 64,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: b.chapterCount,
            itemBuilder: (context, index) {
              final chapter = index + 1;
              return _ChapterCell(
                number: chapter,
                onTap: () => context.push(AppRoutes.reader(bookId, chapter)),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChapterCell extends StatelessWidget {
  const _ChapterCell({required this.number, required this.onTap});

  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(
          child: Text(
            '$number',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
