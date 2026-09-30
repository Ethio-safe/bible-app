import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible/core/backup/backup_service.dart';
import 'package:bible/core/database/bible_database.dart';
import 'package:bible/core/database/user_database.dart';
import 'package:bible/features/bible/data/repositories/drift_bible_repository.dart';
import 'package:bible/features/bible/domain/entities/search_result.dart';
import 'package:bible/features/bible/domain/entities/translation.dart';
import 'package:bible/features/bible/domain/search_query_builder.dart';
import 'package:bible/features/votd/domain/verse_pool.dart';
import 'package:bible/features/votd/presentation/providers/votd_providers.dart';

void main() {
  group('buildFtsQuery', () {
    test('bare words become prefix terms', () {
      expect(buildFtsQuery('love hope'), '"love"* "hope"*');
    });
    test('quoted phrases preserved, mixed with words', () {
      expect(buildFtsQuery('"still waters" shep'), '"still waters" "shep"*');
    });
    test('operators and punctuation stripped', () {
      expect(buildFtsQuery('NOT (love) OR * ^'), '"NOT"* "love"* "OR"*');
      expect(buildFtsQuery('***'), isNull);
      expect(buildFtsQuery('   '), isNull);
    });
    test('apostrophes kept', () {
      expect(buildFtsQuery("Lord's"), '"Lord\'s"*');
    });
    test('punctuation separates bare words instead of joining them', () {
      expect(buildFtsQuery('love,hope'), '"love"* "hope"*');
    });
    test('punctuation in quoted phrases keeps phrase words separated', () {
      expect(buildFtsQuery('"fear,not"'), '"fear not"');
    });
  });

  group('verse pool', () {
    test('has no duplicate references and sane ranges', () {
      final seen = <String>{};
      for (final v in versePool) {
        final key = '${v.bookId}:${v.chapter}:${v.verse}';
        expect(seen.add(key), isTrue, reason: 'duplicate $key');
        expect(v.bookId, inInclusiveRange(1, 66));
        expect(v.chapter, greaterThan(0));
        expect(v.verse, greaterThan(0));
        if (v.endVerse != null) expect(v.endVerse!, greaterThan(v.verse));
      }
      expect(versePool.length, greaterThan(250));
    });

    test('verseForDate is deterministic and ignores time of day', () {
      final a = verseForDate(DateTime(2025, 3, 14, 6, 0));
      final b = verseForDate(DateTime(2025, 3, 14, 23, 59));
      expect(identical(a, b), isTrue);
      expect(verseForDate(DateTime(2025, 3, 15)), isNot(same(a)));
    });

    test('no repeats within a full pool cycle', () {
      final start = DateTime(2025, 1, 1);
      final picks = <PoolVerse>{};
      for (var i = 0; i < versePool.length; i++) {
        picks.add(verseForDate(start.add(Duration(days: i))));
      }
      expect(picks.length, versePool.length);
    });

    test('every pool reference exists in KJV', () async {
      final file = File('assets/bible/kjv.db');
      final db = BibleDatabase(NativeDatabase(file, enableMigrations: false));
      addTearDown(db.close);
      for (final v in versePool) {
        final last = v.endVerse ?? v.verse;
        for (var n = v.verse; n <= last; n++) {
          final row = await db.singleVerse(v.bookId, v.chapter, n);
          expect(row, isNotNull, reason: 'missing ${v.bookId} ${v.chapter}:$n');
        }
      }
    });
  });

  group('searchDetailed (kjv)', () {
    late BibleDatabase db;
    late DriftBibleRepository repo;

    setUpAll(() {
      db = BibleDatabase(
        NativeDatabase(File('assets/bible/kjv.db'), enableMigrations: false),
      );
      repo = DriftBibleRepository(
        translation: const Translation(
          key: 'kjv',
          abbreviation: 'KJV',
          name: 'KJV',
          language: 'en',
          license: 'PD',
        ),
        database: db,
      );
    });
    tearDownAll(() => db.close());

    test('returns snippets with marks and total count', () async {
      final r = await repo.searchDetailed(buildFtsQuery('shepherd')!);
      expect(r.hits, isNotEmpty);
      expect(r.total, greaterThanOrEqualTo(r.hits.length));
      expect(r.hits.first.snippet, contains(SearchResult.markOpen));
      expect(r.hits.first.snippet, contains(SearchResult.markClose));
    });

    test('testament filter restricts results', () async {
      final nt = await repo.searchDetailed(
        buildFtsQuery('love')!,
        filter: const SearchFilter(scope: SearchScope.newTestament),
        limit: 500,
      );
      expect(nt.hits.every((h) => h.book.id >= 40), isTrue);
    });

    test('book filter restricts results', () async {
      final r = await repo.searchDetailed(
        buildFtsQuery('love')!,
        filter: const SearchFilter(bookId: 43),
        limit: 500,
      );
      expect(r.hits, isNotEmpty);
      expect(r.hits.every((h) => h.book.id == 43), isTrue);
    });

    test('common word search completes in < 300 ms', () async {
      // Warm up the page cache once.
      await repo.searchDetailed(buildFtsQuery('lord')!);
      final sw = Stopwatch()..start();
      final r = await repo.searchDetailed(buildFtsQuery('the lord')!);
      sw.stop();
      expect(r.hits, isNotEmpty);
      expect(sw.elapsedMilliseconds, lessThan(300));
    });
  });

  group('BackupService', () {
    test('export → import round-trips and merges idempotently', () async {
      final src = UserDatabase.forTesting(NativeDatabase.memory());
      final dst = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(() async {
        await src.close();
        await dst.close();
      });

      await src.setHighlight(
        bookId: 43,
        chapter: 3,
        verseStart: 16,
        verseEnd: 16,
        color: 1,
      );
      await src.toggleBookmark(19, 23, 1);
      await src.upsertNote(45, 8, 28, 'All things work together');

      final json = BackupService(
        src,
      ).encode(await BackupService(src).buildDocument());
      expect(jsonDecode(json)['app'], 'bible');

      final imported = await BackupService(dst).importJson(json);
      expect(imported, 3);
      expect(await dst.allHighlights(), hasLength(1));
      expect(await dst.allBookmarks(), hasLength(1));
      expect((await dst.allNotes()).single.body, 'All things work together');

      // Importing again changes nothing.
      expect(await BackupService(dst).importJson(json), 0);
      expect(await dst.allNotes(), hasLength(1));
    });

    test('rejects foreign files', () async {
      final db = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      expect(
        () => BackupService(db).importJson('{"foo": 1}'),
        throwsFormatException,
      );
    });
  });
}
