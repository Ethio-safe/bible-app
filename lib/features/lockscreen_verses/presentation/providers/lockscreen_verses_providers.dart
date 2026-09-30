import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/random_verses_local_source.dart';
import '../../data/random_verses_repository.dart';
import '../../domain/entities/random_verse.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../../core/storage/preferences_provider.dart';

final randomVersesLocalSourceProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RandomVersesLocalSourceImpl(prefs);
});

final randomVersesRepositoryProvider = Provider((ref) {
  final bibleRepository = ref.watch(bibleRepositoryProvider).requireValue;
  final localSource = ref.watch(randomVersesLocalSourceProvider);
  return RandomVersesRepository(
    bibleRepository: bibleRepository,
    localSource: localSource,
  );
});

final randomVersesCachedProvider =
    FutureProvider<List<RandomVerse>>((ref) async {
  final repo = ref.watch(randomVersesRepositoryProvider);
  return repo.getCachedVerses();
});

final randomVersesRefreshProvider =
    FutureProvider<List<RandomVerse>>((ref) async {
  final repo = ref.watch(randomVersesRepositoryProvider);
  return repo.refreshVerses();
});

class RandomVersesNotifier extends StateNotifier<List<RandomVerse>> {
  final RandomVersesRepository repository;

  RandomVersesNotifier(this.repository) : super([]);

  Future<void> loadCached() async {
    state = await repository.getCachedVerses();
  }

  Future<void> refresh() async {
    state = await repository.refreshVerses();
  }
}

final randomVersesNotifierProvider =
    StateNotifierProvider<RandomVersesNotifier, List<RandomVerse>>((ref) {
  final repo = ref.watch(randomVersesRepositoryProvider);
  return RandomVersesNotifier(repo)..loadCached();
});
