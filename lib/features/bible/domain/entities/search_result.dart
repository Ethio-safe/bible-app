import 'package:freezed_annotation/freezed_annotation.dart';

import 'book.dart';

part 'search_result.freezed.dart';

/// Which part of the Bible to search.
enum SearchScope {
  all('All'),
  oldTestament('Old Testament'),
  newTestament('New Testament');

  const SearchScope(this.label);
  final String label;

  String? get testamentCode => switch (this) {
    SearchScope.all => null,
    SearchScope.oldTestament => 'OT',
    SearchScope.newTestament => 'NT',
  };
}

@freezed
abstract class SearchFilter with _$SearchFilter {
  const SearchFilter._();

  const factory SearchFilter({
    @Default(SearchScope.all) SearchScope scope,

    /// When set, overrides [scope] and restricts to a single book.
    int? bookId,
  }) = _SearchFilter;

  bool get isDefault => scope == SearchScope.all && bookId == null;
}

@freezed
abstract class SearchQuery with _$SearchQuery {
  const factory SearchQuery({
    required String text,
    @Default(SearchFilter()) SearchFilter filter,
  }) = _SearchQuery;
}

/// A single search hit. [snippet] contains the match context with matched
/// terms wrapped in [SearchResult.markOpen]/[SearchResult.markClose].
@freezed
abstract class SearchResult with _$SearchResult {
  const SearchResult._();

  static const markOpen = '\u0001';
  static const markClose = '\u0002';

  const factory SearchResult({
    required Book book,
    required int chapter,
    required int verse,
    required String text,
    required String snippet,
  }) = _SearchResult;

  String get reference => '${book.name} $chapter:$verse';
}

@freezed
abstract class SearchResults with _$SearchResults {
  const factory SearchResults({
    required List<SearchResult> hits,

    /// Total matches ignoring [limit]; may exceed `hits.length`.
    required int total,
    required Duration elapsed,
  }) = _SearchResults;
}
