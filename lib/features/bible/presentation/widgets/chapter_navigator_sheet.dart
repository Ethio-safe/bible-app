import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/storage/preferences_provider.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../providers/bible_providers.dart';
import '../providers/reading_position_provider.dart';

/// Three-step picker: Book (OT/NT tabs) → Chapter → Verse.
Future<void> showChapterNavigatorSheet(
  BuildContext context, {
  required ChapterId current,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) =>
          _Navigator(current: current, scrollController: scrollController),
    ),
  );
}

enum _Step { book, chapter, verse }

class _Navigator extends ConsumerStatefulWidget {
  const _Navigator({required this.current, required this.scrollController});

  final ChapterId current;
  final ScrollController scrollController;

  @override
  ConsumerState<_Navigator> createState() => _NavigatorState();
}

class _NavigatorState extends ConsumerState<_Navigator> {
  _Step _step = _Step.book;
  Book? _book;
  int? _chapter;

  void _go({int? verse}) {
    Navigator.of(context).pop();
    context.replace(AppRoutes.reader(_book!.id, _chapter!, verse: verse));
  }

  /// Jumps straight to a chapter (used by the Recents strip).
  void _goTo(ChapterId id) {
    Navigator.of(context).pop();
    context.replace(AppRoutes.reader(id.bookId, id.chapter));
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Breadcrumb header ---------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 4),
          child: Row(
            children: [
              if (_step != _Step.book)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    _step = _step == _Step.verse ? _Step.chapter : _Step.book;
                  }),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  switch (_step) {
                    _Step.book => 'Books',
                    _Step.chapter => _book!.name,
                    _Step.verse => '${_book!.name} $_chapter',
                  },
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_step == _Step.verse)
                TextButton(onPressed: () => _go(), child: const Text('Open'))
              else
                const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: booksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (books) => switch (_step) {
              _Step.book => _BookStep(
                books: books,
                currentBookId: widget.current.bookId,
                recents:
                    RecentChapters.read(
                          ref.watch(sharedPreferencesProvider),
                          translation: ref.watch(currentTranslationKeyProvider),
                        )
                        .where(
                          (r) =>
                              r != widget.current &&
                              books.any(
                                (b) =>
                                    b.id == r.bookId &&
                                    r.chapter > 0 &&
                                    r.chapter <= b.chapterCount,
                              ),
                        )
                        .take(8)
                        .toList(),
                scrollController: widget.scrollController,
                onPick: (b) => setState(() {
                  _book = b;
                  _step = _Step.chapter;
                }),
                onPickRecent: _goTo,
              ),
              _Step.chapter => _NumberGrid(
                count: _book!.chapterCount,
                highlighted: _book!.id == widget.current.bookId
                    ? widget.current.chapter
                    : null,
                scrollController: widget.scrollController,
                onPick: (c) => setState(() {
                  _chapter = c;
                  _step = _Step.verse;
                }),
              ),
              _Step.verse => _VerseStep(
                id: ChapterId(bookId: _book!.id, chapter: _chapter!),
                scrollController: widget.scrollController,
                onPick: (v) => _go(verse: v),
              ),
            },
          ),
        ),
      ],
    );
  }
}

class _BookStep extends StatelessWidget {
  const _BookStep({
    required this.books,
    required this.currentBookId,
    required this.recents,
    required this.scrollController,
    required this.onPick,
    required this.onPickRecent,
  });

  final List<Book> books;
  final int currentBookId;
  final List<ChapterId> recents;
  final ScrollController scrollController;
  final ValueChanged<Book> onPick;
  final ValueChanged<ChapterId> onPickRecent;

  @override
  Widget build(BuildContext context) {
    final ot = books.where((b) => b.isOldTestament).toList();
    final nt = books.where((b) => !b.isOldTestament).toList();
    final startNt =
        books.where((b) => b.id == currentBookId).firstOrNull?.testament ==
        Testament.newTestament;

    return DefaultTabController(
      length: 2,
      initialIndex: startNt ? 1 : 0,
      child: Column(
        children: [
          if (recents.isNotEmpty)
            _RecentsStrip(recents: recents, books: books, onPick: onPickRecent),
          const TabBar(
            tabs: [
              Tab(text: 'Old Testament'),
              Tab(text: 'New Testament'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _BookGrid(
                  books: ot,
                  currentBookId: currentBookId,
                  controller: startNt ? null : scrollController,
                  onPick: onPick,
                ),
                _BookGrid(
                  books: nt,
                  currentBookId: currentBookId,
                  controller: startNt ? scrollController : null,
                  onPick: onPick,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal strip of recently read chapters shown above the OT/NT tabs.
/// Tapping a card jumps straight to that chapter.
class _RecentsStrip extends StatelessWidget {
  const _RecentsStrip({
    required this.recents,
    required this.books,
    required this.onPick,
  });

  final List<ChapterId> recents;
  final List<Book> books;
  final ValueChanged<ChapterId> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'Recents',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final id = recents[i];
              final book = books.firstWhere((b) => b.id == id.bookId);
              return _RecentCard(
                label: '${book.name} ${id.chapter}',
                onTap: () => onPick(id),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({
    required this.books,
    required this.currentBookId,
    required this.controller,
    required this.onPick,
  });

  final List<Book> books;
  final int currentBookId;
  final ScrollController? controller;
  final ValueChanged<Book> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 110,
        mainAxisExtent: 52,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, i) {
        final b = books[i];
        final active = b.id == currentBookId;
        return Material(
          color: active ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onPick(b),
            child: Center(
              child: Text(
                b.abbreviation,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? scheme.onPrimaryContainer : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({
    required this.count,
    required this.highlighted,
    required this.scrollController,
    required this.onPick,
  });

  final int count;
  final int? highlighted;
  final ScrollController scrollController;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 60,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: count,
      itemBuilder: (context, i) {
        final n = i + 1;
        final active = n == highlighted;
        return Material(
          color: active ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onPick(n),
            child: Center(
              child: Text(
                '$n',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? scheme.onPrimaryContainer : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VerseStep extends ConsumerWidget {
  const _VerseStep({
    required this.id,
    required this.scrollController,
    required this.onPick,
  });

  final ChapterId id;
  final ScrollController scrollController;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ref.watch(chapterProvider(id));
    return chapter.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (c) => _NumberGrid(
        count: c.verses.length,
        highlighted: null,
        scrollController: scrollController,
        onPick: onPick,
      ),
    );
  }
}
