import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible/core/database/user_database.dart';
import 'package:bible/features/annotations/data/drift_annotations_repository.dart';
import 'package:bible/features/annotations/domain/entities/annotations.dart';

void main() {
  late UserDatabase db;
  late DriftAnnotationsRepository repo;

  setUp(() {
    db = UserDatabase.forTesting(NativeDatabase.memory());
    repo = DriftAnnotationsRepository(db);
  });

  tearDown(() => db.close());

  group('highlights', () {
    test('set then watch returns highlight with colour', () async {
      await repo.setHighlight(
        bookId: 43,
        chapter: 3,
        verseStart: 16,
        verseEnd: 17,
        color: HighlightColor.blue,
      );
      final list = await repo.watchChapterHighlights(43, 3).first;
      expect(list, hasLength(1));
      expect(list.first.color, HighlightColor.blue);
      expect(list.first.covers(16), isTrue);
      expect(list.first.covers(18), isFalse);
      expect(list.first.reference, '16–17');
    });

    test('overlapping highlight replaces the old one', () async {
      await repo.setHighlight(
        bookId: 1,
        chapter: 1,
        verseStart: 1,
        verseEnd: 3,
        color: HighlightColor.yellow,
      );
      await repo.setHighlight(
        bookId: 1,
        chapter: 1,
        verseStart: 3,
        verseEnd: 5,
        color: HighlightColor.green,
      );
      final list = await repo.watchChapterHighlights(1, 1).first;
      expect(list, hasLength(1));
      expect(list.first.verseStart, 3);
      expect(list.first.color, HighlightColor.green);
    });

    test('remove clears overlapping range only', () async {
      await repo.setHighlight(
        bookId: 1,
        chapter: 1,
        verseStart: 1,
        verseEnd: 1,
        color: HighlightColor.pink,
      );
      await repo.setHighlight(
        bookId: 1,
        chapter: 1,
        verseStart: 10,
        verseEnd: 10,
        color: HighlightColor.pink,
      );
      await repo.removeHighlight(
        bookId: 1,
        chapter: 1,
        verseStart: 10,
        verseEnd: 10,
      );
      final list = await repo.watchAllHighlights().first;
      expect(list.map((h) => h.verseStart), [1]);
    });
  });

  group('bookmarks', () {
    const ref = VerseRef(bookId: 19, chapter: 23, verse: 1);

    test('toggle adds then removes', () async {
      await repo.toggleBookmark(ref);
      expect(await repo.watchChapterBookmarks(19, 23).first, hasLength(1));
      await repo.toggleBookmark(ref);
      expect(await repo.watchChapterBookmarks(19, 23).first, isEmpty);
    });
  });

  group('notes', () {
    const ref = VerseRef(bookId: 45, chapter: 8, verse: 28);

    test('save is an upsert', () async {
      await repo.saveNote(ref, 'first');
      await repo.saveNote(ref, 'second');
      final notes = await repo.watchAllNotes().first;
      expect(notes, hasLength(1));
      expect(notes.first.body, 'second');
      expect((await repo.getNote(ref))?.body, 'second');
    });

    test('delete removes', () async {
      await repo.saveNote(ref, 'x');
      final n = await repo.getNote(ref);
      await repo.deleteNote(n!.id);
      expect(await repo.getNote(ref), isNull);
    });
  });

  group('reading position', () {
    test('save + get per translation', () async {
      await repo.saveReadingPosition(
        const ReadingPosition(
          translation: 'kjv',
          bookId: 43,
          chapter: 3,
          scrollOffset: 420,
        ),
      );
      await repo.saveReadingPosition(
        const ReadingPosition(
          translation: 'kjv',
          bookId: 43,
          chapter: 4,
          scrollOffset: 10,
        ),
      );
      final pos = await repo.getReadingPosition('kjv');
      expect(pos?.chapter, 4);
      expect(pos?.scrollOffset, 10);
      expect(await repo.getReadingPosition('web'), isNull);
    });
  });
}
