import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/preferences_provider.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/search_query_builder.dart';
import 'bible_providers.dart';

part 'search_providers.g.dart';

/// Current search input + filters (kept alive so the tab remembers state).
@Riverpod(keepAlive: true)
class SearchState extends _$SearchState {
  @override
  SearchQuery build() => const SearchQuery(text: '');

  void setText(String text) => state = state.copyWith(text: text);

  void setScope(SearchScope scope) => state = state.copyWith(
    filter: state.filter.copyWith(scope: scope, bookId: null),
  );

  void setBook(int? bookId) =>
      state = state.copyWith(filter: state.filter.copyWith(bookId: bookId));

  void clearFilters() => state = state.copyWith(filter: const SearchFilter());

  void clear() => state = const SearchQuery(text: '');
}

/// Executes the search for the current [SearchState]. Returns `null` when the
/// query is too short to run.
@riverpod
Future<SearchResults?> searchResults(Ref ref) async {
  final query = ref.watch(searchStateProvider);
  final fts = buildFtsQuery(query.text);
  if (fts == null || query.text.trim().length < 2) return null;

  // Debounce keystrokes; bail out if a newer query superseded this one.
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(const Duration(milliseconds: 250));
  if (disposed) return null;

  final repo = await ref.watch(bibleRepositoryProvider.future);
  final results = await repo.searchDetailed(fts, filter: query.filter);
  if (disposed) return null;

  unawaited(ref.read(recentSearchesProvider.notifier).add(query.text));
  return results;
}

/// Last 10 distinct searches, most recent first.
@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  static const _key = 'recent_searches';
  static const _max = 10;

  @override
  List<String> build() =>
      ref.watch(sharedPreferencesProvider).getStringList(_key) ?? const [];

  Future<void> add(String term) async {
    final t = term.trim();
    if (t.length < 2) return;
    final next = [
      t,
      ...state.where((s) => s.toLowerCase() != t.toLowerCase()),
    ].take(_max).toList();
    if (next.length == state.length && next.first == (state.firstOrNull)) {
      return;
    }
    state = next;
    await ref.read(sharedPreferencesProvider).setStringList(_key, next);
  }

  Future<void> remove(String term) async {
    state = state.where((s) => s != term).toList();
    await ref.read(sharedPreferencesProvider).setStringList(_key, state);
  }

  Future<void> clear() async {
    state = const [];
    await ref.read(sharedPreferencesProvider).remove(_key);
  }
}
