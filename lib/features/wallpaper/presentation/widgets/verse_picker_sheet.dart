import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bible/domain/entities/search_result.dart';
import '../../../bible/domain/search_query_builder.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../votd/domain/verse_pool.dart';
import '../../../votd/presentation/providers/votd_providers.dart';
import '../providers/wallpaper_providers.dart';

Future<void> showVersePickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _VersePickerSheet(),
  );
}

class _VersePickerSheet extends ConsumerStatefulWidget {
  const _VersePickerSheet();

  @override
  ConsumerState<_VersePickerSheet> createState() => _VersePickerSheetState();
}

class _VersePickerSheetState extends ConsumerState<_VersePickerSheet> {
  VerseTheme? _theme;
  final _searchController = TextEditingController();
  List<SearchResult> _searchResults = const [];
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final fts = buildFtsQuery(_searchController.text);
    if (fts == null) {
      setState(() => _searchResults = const []);
      return;
    }
    setState(() => _searching = true);
    try {
      final repo = await ref.read(bibleRepositoryProvider.future);
      final results = (await repo.searchDetailed(fts, limit: 50)).hits;
      if (mounted) setState(() => _searchResults = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(previewControllerProvider.notifier);
    final books = ref.watch(booksProvider).valueOrNull ?? const [];
    String nameOf(int id) =>
        books.where((b) => b.id == id).map((b) => b.name).firstOrNull ?? '#$id';

    final pool = ref.watch(editionVersePoolProvider);
    final list = (pool.valueOrNull?.verses ?? <PoolVerse>[])
        .where((v) => _theme == null || v.theme == _theme)
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (context, scroll) => Column(
        children: [
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text('Verse of the Day'),
            onTap: () {
              controller.setSource(const VotdQuoteSource());
              Navigator.pop(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search the Bible',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: _searching ? null : _search,
                  icon: _searching
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _theme == null,
                  onSelected: (_) => setState(() => _theme = null),
                ),
                for (final t in VerseTheme.values)
                  ChoiceChip(
                    label: Text(_label(t)),
                    selected: _theme == t,
                    onSelected: (_) => setState(() => _theme = t),
                  ),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: _searchController.text.trim().isNotEmpty
                ? _SearchResultsList(
                    results: _searchResults,
                    onPick: (result) {
                      controller.setSource(
                        RangeQuoteSource(
                          bookId: result.book.id,
                          chapter: result.chapter,
                          start: result.verse,
                          end: result.verse,
                        ),
                      );
                      Navigator.pop(context);
                    },
                  )
                : pool.isLoading
                ? const Center(child: CircularProgressIndicator())
                : pool.hasError
                ? const Center(
                    child: Text('Verses unavailable in this edition.'),
                  )
                : ListView.builder(
                    controller: scroll,
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final v = list[i];
                      final range = v.isRange ? '-${v.endVerse}' : '';
                      return ListTile(
                        dense: true,
                        title: Text(
                          '${nameOf(v.bookId)} ${v.chapter}:${v.verse}$range',
                        ),
                        subtitle: Text(_label(v.theme)),
                        onTap: () {
                          controller.setSource(PoolQuoteSource(v));
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static String _label(VerseTheme t) =>
      t.name[0].toUpperCase() + t.name.substring(1);
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.results, required this.onPick});

  final List<SearchResult> results;
  final ValueChanged<SearchResult> onPick;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(child: Text('No matching verses found.'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          dense: true,
          title: Text(result.reference),
          subtitle: Text(
            result.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onPick(result),
        );
      },
    );
  }
}
