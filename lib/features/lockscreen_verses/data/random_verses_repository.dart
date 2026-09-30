import 'dart:math';

import '../../bible/domain/entities/chapter.dart';
import '../../bible/domain/repositories/bible_repository.dart';
import '../domain/entities/random_verse.dart';
import 'datasources/random_verses_local_source.dart';

class RandomVersesRepository {
  final BibleRepository bibleRepository;
  final RandomVersesLocalSource localSource;

  RandomVersesRepository({
    required this.bibleRepository,
    required this.localSource,
  });

  /// Fetches 10 random verses from the Bible
  Future<List<RandomVerse>> fetchRandomVerses() async {
    try {
      final books = await bibleRepository.getBooks();
      if (books.isEmpty) return [];

      final random = Random();
      final randomVerses = <RandomVerse>[];

      for (int i = 0; i < 10; i++) {
        final book = books[random.nextInt(books.length)];
        final chapters = book.chapterCount;
        if (chapters == 0) continue;

        final chapter = random.nextInt(chapters) + 1;
        final chapterData = await bibleRepository.getChapter(
          ChapterId(bookId: book.id, chapter: chapter),
        );

        if (chapterData.verses.isNotEmpty) {
          final verse = chapterData.verses[random.nextInt(chapterData.verses.length)];
          randomVerses.add(RandomVerse(
            book: book.name,
            chapter: chapter,
            verse: verse.number,
            text: verse.text,
            reference: '${book.name} $chapter:${verse.number}',
          ));
        }
      }

      // Save to local storage
      await localSource.saveVerses(randomVerses);
      return randomVerses;
    } catch (e) {
      return [];
    }
  }

  /// Gets cached random verses
  Future<List<RandomVerse>> getCachedVerses() async {
    return localSource.getVerses();
  }

  /// Refreshes the random verses cache
  Future<List<RandomVerse>> refreshVerses() async {
    return fetchRandomVerses();
  }
}
