import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/bible_database.dart' show BibleDatabase;
import '../../../../core/database/bundled_bibles.dart';
import '../../../../core/database/database_providers.dart';
import '../../../../core/storage/preferences_provider.dart';
import '../../data/datasources/bible_mappers.dart';
import '../../data/repositories/drift_bible_repository.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/translation.dart';
import '../../domain/repositories/bible_repository.dart';

part 'bible_providers.g.dart';

// -----------------------------------------------------------------------------
// Translations
// -----------------------------------------------------------------------------

/// All bundled translations with metadata read from each DB's `meta` table.
@Riverpod(keepAlive: true)
Future<List<Translation>> translations(Ref ref) async {
  final result = <Translation>[];
  for (final entry in BundledBibles.files.entries) {
    final path = kIsWeb
        ? BundledBibles.assetPath(entry.key)
        : p.join(
            (await ref.watch(bibleDbDirectoryProvider.future)).path,
            entry.value,
          );
    final db = BibleDatabase.open(path);
    try {
      result.add(translationFromMeta(entry.key, await db.readMeta()));
    } finally {
      await db.close();
    }
  }
  return result;
}

/// The user-selected translation key (`kjv`, `web`, `asv`), persisted.
@Riverpod(keepAlive: true)
class CurrentTranslationKey extends _$CurrentTranslationKey {
  static const _prefKey = 'current_translation';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_prefKey);
    if (saved != null && BundledBibles.files.containsKey(saved)) return saved;
    if (saved != null) {
      // Repair stale keys (for example removed experimental editions).
      Future.microtask(
        () => prefs.setString(_prefKey, BundledBibles.defaultTranslation),
      );
    }
    return BundledBibles.defaultTranslation;
  }

  Future<void> set(String key) async {
    if (!BundledBibles.files.containsKey(key) || key == state) return;
    state = key;
    await ref.read(sharedPreferencesProvider).setString(_prefKey, key);
  }
}

/// Resolved [Translation] for the current key.
@riverpod
Future<Translation> currentTranslation(Ref ref) async {
  final key = ref.watch(currentTranslationKeyProvider);
  final all = await ref.watch(translationsProvider.future);
  return all.firstWhere((t) => t.key == key);
}

// -----------------------------------------------------------------------------
// Repository (bound to the current translation)
// -----------------------------------------------------------------------------

/// Open connection to the current translation's DB. Re-created (and the old
/// one closed) whenever the translation changes.
@Riverpod(keepAlive: true)
Future<BibleDatabase> currentBibleDatabase(Ref ref) async {
  final key = ref.watch(currentTranslationKeyProvider);
  final path = kIsWeb
      ? BundledBibles.assetPath(key)
      : p.join(
          (await ref.watch(bibleDbDirectoryProvider.future)).path,
          BundledBibles.files[key]!,
        );
  final db = BibleDatabase.open(path);
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
Future<BibleRepository> bibleRepository(Ref ref) async {
  final translation = await ref.watch(currentTranslationProvider.future);
  final db = await ref.watch(currentBibleDatabaseProvider.future);
  return DriftBibleRepository(translation: translation, database: db);
}

// -----------------------------------------------------------------------------
// Content
// -----------------------------------------------------------------------------

@riverpod
Future<List<Book>> books(Ref ref) async {
  final repo = await ref.watch(bibleRepositoryProvider.future);
  return repo.getBooks();
}

@riverpod
Future<Book?> book(Ref ref, int bookId) async {
  final repo = await ref.watch(bibleRepositoryProvider.future);
  return repo.getBook(bookId);
}

@riverpod
Future<Chapter> chapter(Ref ref, ChapterId id) async {
  final repo = await ref.watch(bibleRepositoryProvider.future);
  return repo.getChapter(id);
}
