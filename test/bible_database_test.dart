import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible/core/database/bible_database.dart';
import 'package:bible/features/bible/data/repositories/drift_bible_repository.dart';
import 'package:bible/features/bible/domain/entities/book.dart';
import 'package:bible/features/bible/domain/entities/chapter.dart';
import 'package:bible/features/bible/domain/entities/translation.dart';

/// Integration test against the real bundled databases produced by
/// `tools/build_bible_db.py`. Validates schema compatibility with Drift.
void main() {
  for (final key in ['kjv', 'web', 'asv']) {
    group('$key.db', () {
      late BibleDatabase db;
      late DriftBibleRepository repo;

      setUpAll(() async {
        final file = File('assets/bible/$key.db');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Run tools/build_bible_db.py first',
        );
        db = BibleDatabase(NativeDatabase(file, enableMigrations: false));
        repo = DriftBibleRepository(
          translation: Translation(
            key: key,
            abbreviation: key.toUpperCase(),
            name: key,
            language: 'en',
            license: 'PD',
          ),
          database: db,
        );
      });

      tearDownAll(() => db.close());

      test('meta has abbreviation and schema version', () async {
        final meta = await db.readMeta();
        expect(meta['abbreviation'], key.toUpperCase());
        expect(meta['schema_version'], '1');
      });

      test('has 66 books in canonical order', () async {
        final books = await repo.getBooks();
        expect(books, hasLength(66));
        expect(books.first.name, 'Genesis');
        expect(books.first.testament, Testament.oldTestament);
        expect(books[38].name, 'Malachi');
        expect(books[39].name, 'Matthew');
        expect(books[39].testament, Testament.newTestament);
        expect(books.last.name, 'Revelation');
        expect(books.last.chapterCount, 22);
        expect(books[18].chapterCount, 150); // Psalms
      });

      test('loads John 3 with verse 16', () async {
        final chapter = await repo.getChapter(
          const ChapterId(bookId: 43, chapter: 3),
        );
        expect(chapter.title, 'John 3');
        expect(chapter.verses.length, greaterThanOrEqualTo(36));
        final v16 = chapter.verses.firstWhere((v) => v.number == 16);
        expect(v16.text.toLowerCase(), contains('god so loved the world'));
      });

      test('getVerse returns Genesis 1:1', () async {
        final v = await repo.getVerse(1, 1, 1);
        expect(v, isNotNull);
        expect(v!.text.toLowerCase(), contains('in the beginning'));
      });

      test('invalid chapter throws', () async {
        expect(
          () => repo.getChapter(const ChapterId(bookId: 43, chapter: 99)),
          throwsA(isA<ChapterNotFoundException>()),
        );
      });

      test('FTS5 search finds shepherd verses', () async {
        final results = await repo.search('shepherd', limit: 20);
        expect(results, isNotEmpty);
        expect(results.length, lessThanOrEqualTo(20));
        expect(
          results.every((v) => v.text.toLowerCase().contains('shepherd')),
          isTrue,
        );
      });
    });
  }
}
