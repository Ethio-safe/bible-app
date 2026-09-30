import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/search_result.dart';
import '../providers/bible_providers.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchStateProvider).text,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    ref.read(searchStateProvider.notifier).setText(text);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchStateProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search the Bible',
            border: InputBorder.none,
            suffixIcon: query.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchStateProvider.notifier).setText('');
                    },
                  ),
          ),
          onChanged: (t) => ref.read(searchStateProvider.notifier).setText(t),
          onSubmitted: _submit,
        ),
      ),
      body: Column(
        children: [
          _FilterBar(filter: query.filter),
          const Divider(height: 1),
          Expanded(
            child: query.text.trim().length < 2
                ? _RecentSearches(onTap: _submit)
                : results.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Search failed: $e')),
                    data: (data) => data == null
                        ? const SizedBox.shrink()
                        : _ResultsList(results: data),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});
  final SearchFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(searchStateProvider.notifier);
    final books = ref.watch(booksProvider).valueOrNull ?? const <Book>[];
    final selectedBook = filter.bookId == null
        ? null
        : books.where((b) => b.id == filter.bookId).firstOrNull;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          for (final scope in SearchScope.values)
            ChoiceChip(
              label: Text(switch (scope) {
                SearchScope.all => 'All',
                SearchScope.oldTestament => 'Old Testament',
                SearchScope.newTestament => 'New Testament',
              }),
              selected: filter.bookId == null && filter.scope == scope,
              onSelected: (_) => notifier.setScope(scope),
            ),
          ActionChip(
            avatar: Icon(
              selectedBook == null ? Icons.menu_book_outlined : Icons.close,
              size: 18,
            ),
            label: Text(selectedBook?.name ?? 'Book…'),
            onPressed: () async {
              if (selectedBook != null) {
                notifier.setBook(null);
                return;
              }
              final picked = await showModalBottomSheet<int>(
                context: context,
                showDragHandle: true,
                builder: (_) => _BookPicker(books: books),
              );
              if (picked != null) notifier.setBook(picked);
            },
          ),
        ],
      ),
    );
  }
}

class _BookPicker extends StatelessWidget {
  const _BookPicker({required this.books});
  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, i) {
        final b = books[i];
        return ListTile(
          dense: true,
          title: Text(b.name),
          onTap: () => Navigator.of(context).pop(b.id),
        );
      },
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentSearchesProvider);
    if (recents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Search for a word or phrase.\nUse quotes for exact phrases, e.g. "fear not".',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return ListView(
      children: [
        ListTile(
          title: Text('Recent', style: Theme.of(context).textTheme.labelLarge),
          trailing: TextButton(
            onPressed: () => ref.read(recentSearchesProvider.notifier).clear(),
            child: const Text('Clear'),
          ),
        ),
        for (final term in recents)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(term),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () =>
                  ref.read(recentSearchesProvider.notifier).remove(term),
            ),
            onTap: () => onTap(term),
          ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results});
  final SearchResults results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (results.hits.isEmpty) {
      return const Center(child: Text('No results'));
    }
    final countLabel = results.total > results.hits.length
        ? 'Showing ${results.hits.length} of ${results.total}'
        : '${results.hits.length} results';

    return ListView.separated(
      itemCount: results.hits.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '$countLabel · ${results.elapsed.inMilliseconds} ms',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final hit = results.hits[i - 1];
        return ListTile(
          title: Text(
            hit.reference,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          subtitle: Text.rich(
            _highlight(hit.snippet, theme),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => context.push(
            AppRoutes.reader(hit.book.id, hit.chapter, verse: hit.verse),
          ),
        );
      },
    );
  }

  static TextSpan _highlight(String snippet, ThemeData theme) {
    final spans = <InlineSpan>[];
    final bold = TextStyle(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface,
    );
    var i = 0;
    while (i < snippet.length) {
      final open = snippet.indexOf(SearchResult.markOpen, i);
      if (open == -1) {
        spans.add(TextSpan(text: snippet.substring(i)));
        break;
      }
      if (open > i) spans.add(TextSpan(text: snippet.substring(i, open)));
      final close = snippet.indexOf(SearchResult.markClose, open + 1);
      if (close == -1) {
        spans.add(TextSpan(text: snippet.substring(open + 1)));
        break;
      }
      spans.add(
        TextSpan(text: snippet.substring(open + 1, close), style: bold),
      );
      i = close + 1;
    }
    return TextSpan(children: spans);
  }
}
