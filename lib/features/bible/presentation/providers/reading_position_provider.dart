import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/preferences_provider.dart';
import '../../../annotations/domain/entities/annotations.dart';
import '../../../annotations/presentation/providers/annotations_providers.dart';
import '../../domain/entities/chapter.dart';
import 'bible_providers.dart';

part 'reading_position_provider.g.dart';

/// Tracks the chapter the user is currently reading.
///
/// The chapter reference is mirrored to SharedPreferences (synchronous read →
/// used to pick the initial route at startup); the scroll offset lives in the
/// user database, keyed by translation.
@Riverpod(keepAlive: true)
class LastReadChapter extends _$LastReadChapter {
  static const _kBook = 'last_read_book';
  static const _kChapter = 'last_read_chapter';

  @override
  ChapterId? build() {
    final p = ref.watch(sharedPreferencesProvider);
    final translation = ref.watch(currentTranslationKeyProvider);
    final book = p.getInt(scopedReadingKey(_kBook, translation));
    final chapter = p.getInt(scopedReadingKey(_kChapter, translation));
    if (book == null || chapter == null) return null;
    return ChapterId(bookId: book, chapter: chapter);
  }

  Future<void> set(ChapterId id) async {
    if (state == id) return;
    state = id;
    final p = ref.read(sharedPreferencesProvider);
    final translation = ref.read(currentTranslationKeyProvider);
    await Future.wait([
      p.setInt(scopedReadingKey(_kBook, translation), id.bookId),
      p.setInt(scopedReadingKey(_kChapter, translation), id.chapter),
      RecentChapters.record(p, id, translation: translation),
    ]);
  }
}

/// Small helper for the most-recently-read chapter history (persisted in
/// SharedPreferences as a capped, most-recent-first list of `book:chapter`).
///
/// Kept intentionally free of code-gen so it can be read synchronously wherever
/// a [SharedPreferences] instance is available (e.g. the chapter navigator).
String scopedReadingKey(String key, String translation) =>
    translation == 'kjv' ? key : '${key}_$translation';

class RecentChapters {
  RecentChapters._();

  static const _key = 'recent_chapters';
  static const _max = 12;

  /// Reads the current history, most-recent first.
  static List<ChapterId> read(
    SharedPreferences p, {
    String translation = 'kjv',
  }) {
    final raw =
        p.getStringList(scopedReadingKey(_key, translation)) ??
        const <String>[];
    final out = <ChapterId>[];
    for (final s in raw) {
      final parts = s.split(':');
      if (parts.length != 2) continue;
      final b = int.tryParse(parts[0]);
      final c = int.tryParse(parts[1]);
      if (b != null && c != null && b > 0 && c > 0)
        out.add(ChapterId(bookId: b, chapter: c));
    }
    return out;
  }

  /// Moves [id] to the front of the history and persists it.
  static Future<void> record(
    SharedPreferences p,
    ChapterId id, {
    String translation = 'kjv',
  }) {
    final current = read(p, translation: translation)
      ..removeWhere((e) => e == id);
    current.insert(0, id);
    final capped = current.take(_max).map((e) => '${e.bookId}:${e.chapter}');
    return p.setStringList(
      scopedReadingKey(_key, translation),
      capped.toList(),
    );
  }
}

/// Persists the scroll offset for the current chapter/translation.
@Riverpod(keepAlive: true)
class ScrollPositionSaver extends _$ScrollPositionSaver {
  @override
  void build() {}

  Future<void> save(ChapterId id, double offset) async {
    final translation = ref.read(currentTranslationKeyProvider);
    await ref
        .read(annotationsRepositoryProvider)
        .saveReadingPosition(
          ReadingPosition(
            translation: translation,
            bookId: id.bookId,
            chapter: id.chapter,
            scrollOffset: offset,
          ),
        );
  }

  /// Returns the saved offset if it belongs to [id] for the current translation.
  Future<double> restore(ChapterId id) async {
    final translation = ref.read(currentTranslationKeyProvider);
    final pos = await ref
        .read(annotationsRepositoryProvider)
        .getReadingPosition(translation);
    if (pos == null || pos.bookId != id.bookId || pos.chapter != id.chapter) {
      return 0;
    }
    return pos.scrollOffset;
  }
}
