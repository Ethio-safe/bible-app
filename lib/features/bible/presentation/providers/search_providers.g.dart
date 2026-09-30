// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchResultsHash() => r'838ce3a303f0d05e571b8e23a5523102aacf5189';

/// Executes the search for the current [SearchState]. Returns `null` when the
/// query is too short to run.
///
/// Copied from [searchResults].
@ProviderFor(searchResults)
final searchResultsProvider =
    AutoDisposeFutureProvider<SearchResults?>.internal(
      searchResults,
      name: r'searchResultsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchResultsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchResultsRef = AutoDisposeFutureProviderRef<SearchResults?>;
String _$searchStateHash() => r'44a73f8af95143dc4d292b6bb55dc8aef8dfa642';

/// Current search input + filters (kept alive so the tab remembers state).
///
/// Copied from [SearchState].
@ProviderFor(SearchState)
final searchStateProvider = NotifierProvider<SearchState, SearchQuery>.internal(
  SearchState.new,
  name: r'searchStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchState = Notifier<SearchQuery>;
String _$recentSearchesHash() => r'a214f369372f2451b99318a75e660a2153037ef4';

/// Last 10 distinct searches, most recent first.
///
/// Copied from [RecentSearches].
@ProviderFor(RecentSearches)
final recentSearchesProvider =
    NotifierProvider<RecentSearches, List<String>>.internal(
      RecentSearches.new,
      name: r'recentSearchesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentSearchesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecentSearches = Notifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
