import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../bible/domain/entities/book.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../widgets/home_widget_service.dart';
import '../../domain/verse_pool.dart';
import '../../domain/edition_verse_pool.dart';

part 'votd_providers.g.dart';

final editionVersePoolProvider = FutureProvider<EditionVersePool>((ref) async {
  final db = await ref.watch(currentBibleDatabaseProvider.future);
  return EditionVersePool.load(db);
});

/// A resolved quote from the pool: text + human reference in the current
/// translation.
class DailyVerse {
  const DailyVerse({
    required this.pool,
    required this.book,
    required this.text,
    required this.translationAbbreviation,
  });

  final PoolVerse pool;
  final Book book;
  final String text;
  final String translationAbbreviation;

  String get reference {
    final end = pool.isRange ? '-${pool.endVerse}' : '';
    return '${book.name} ${pool.chapter}:${pool.verse}$end';
  }

  String get shareText => '"$text"\n— $reference ($translationAbbreviation)';
}

int _dayNumber(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

List<int>? _shuffledOrder;

/// A random (Fisher–Yates) permutation of `0..n-1`, computed once and
/// cached. A fixed seed keeps it identical across every app run/device —
/// same verse for everyone on a given day — while still being a genuine
/// shuffle rather than a predictable arithmetic stride. Because the day only
/// ever selects via `day % n`, and any run of `n` consecutive days covers
/// every residue exactly once, every verse still shows exactly once before
/// the pool repeats.
List<int> _orderFor(int n) {
  final cached = _shuffledOrder;
  if (cached != null && cached.length == n) return cached;
  final order = List<int>.generate(n, (i) => i);
  final rnd = Random(0xC0FFEE);
  for (var i = n - 1; i > 0; i--) {
    final j = rnd.nextInt(i + 1);
    final t = order[i];
    order[i] = order[j];
    order[j] = t;
  }
  return _shuffledOrder = order;
}

/// Truly random pick for a calendar day: same verse all day, on every
/// device, with no repeat until the whole pool has been shown.
PoolVerse verseForDate(DateTime date, [List<PoolVerse> pool = versePool]) {
  final day = _dayNumber(date);
  final n = pool.length;
  return pool[_orderFor(n)[day % n]];
}

/// Resolves a [PoolVerse] to text using the current translation.
@riverpod
Future<DailyVerse> resolvePoolVerse(Ref ref, PoolVerse pool) async {
  final editionPool = await ref.watch(editionVersePoolProvider.future);
  pool = editionPool.resolve(pool);
  final repo = await ref.watch(bibleRepositoryProvider.future);
  final translation = await ref.watch(currentTranslationProvider.future);
  final book = await repo.getBook(pool.bookId);
  if (book == null) throw StateError('Unknown book ${pool.bookId}');

  final last = pool.endVerse ?? pool.verse;
  final parts = <String>[];
  for (var v = pool.verse; v <= last; v++) {
    final verse = await repo.getVerse(pool.bookId, pool.chapter, v);
    if (verse != null) parts.add(verse.text.trim());
  }
  return DailyVerse(
    pool: pool,
    book: book,
    text: parts.join(' '),
    translationAbbreviation: translation.abbreviation,
  );
}

/// The verse shown [daysAgo] days before today (0 = today) plus its date —
/// powers the notification history screen.
@riverpod
Future<List<({DateTime day, DailyVerse verse})>> recentVersesOfTheDay(
  Ref ref,
  int count,
) async {
  final today = DateTime.now();
  final result = <({DateTime day, DailyVerse verse})>[];
  for (var i = 0; i < count; i++) {
    final day = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: i));
    final verse = await ref.watch(
      resolvePoolVerseProvider(verseForDate(day)).future,
    );
    result.add((day: day, verse: verse));
  }
  return result;
}

/// Today's verse (local calendar day). Also refreshes the OS home/lock-screen
/// widget so it shows today's verse even when automation is off.
@riverpod
Future<DailyVerse> verseOfTheDay(Ref ref) async {
  final pool = verseForDate(DateTime.now());
  final daily = await ref.watch(resolvePoolVerseProvider(pool).future);
  if (HomeWidgetService.supported) {
    final bibleDb = await ref.read(currentBibleDatabaseProvider.future);
    // Fire-and-forget; HomeWidgetService swallows its own errors.
    unawaited(
      HomeWidgetService.publishIfStale(
        bibleDb: bibleDb,
        verse: daily.pool,
        translation: daily.translationAbbreviation,
      ),
    );
  }
  return daily;
}
