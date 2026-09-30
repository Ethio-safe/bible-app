import 'package:flutter_test/flutter_test.dart';
import 'package:bible/features/bible/domain/entities/book.dart';
import 'package:bible/features/bible/domain/entities/chapter.dart';
import 'package:bible/features/bible/presentation/providers/chapter_index_provider.dart';
import 'package:bible/features/bible/presentation/providers/verse_selection_provider.dart';

void main() {
  group('VerseSelectionX', () {
    test('ranges groups contiguous verses', () {
      expect({1, 2, 3, 7, 9, 10}.ranges, [(1, 3), (7, 7), (9, 10)]);
      expect(<int>{}.ranges, isEmpty);
      expect({5}.ranges, [(5, 5)]);
    });

    test('label formats ranges', () {
      expect({3, 5, 6, 7}.label, '3, 5–7');
    });
  });

  group('ChapterIndex', () {
    final books = [
      const Book(
        id: 1,
        name: 'Genesis',
        abbreviation: 'Gen',
        testament: Testament.oldTestament,
        chapterCount: 3,
      ),
      const Book(
        id: 2,
        name: 'Exodus',
        abbreviation: 'Exod',
        testament: Testament.oldTestament,
        chapterCount: 2,
      ),
    ];
    final index = ChapterIndex(books);

    test('flattens chapters in order', () {
      expect(index.length, 5);
      expect(index.at(0), const ChapterId(bookId: 1, chapter: 1));
      expect(index.at(3), const ChapterId(bookId: 2, chapter: 1));
      expect(index.indexOf(const ChapterId(bookId: 2, chapter: 2)), 4);
      expect(index.titleOf(const ChapterId(bookId: 2, chapter: 2)), 'Exodus 2');
    });
  });
}
