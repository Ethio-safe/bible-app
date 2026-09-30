import '../entities/book.dart';
import '../entities/chapter.dart';
import '../entities/search_result.dart';
import '../entities/translation.dart';
import '../entities/verse.dart';

/// Read access to one translation of the Bible.
///
/// Implementations are bound to a single translation; swapping translation
/// means obtaining a new repository instance (see `bibleRepositoryProvider`).
abstract interface class BibleRepository {
  Translation get translation;

  Future<List<Book>> getBooks();

  Future<Book?> getBook(int bookId);

  Future<Chapter> getChapter(ChapterId ref);

  Future<Verse?> getVerse(int bookId, int chapter, int verse);

  /// Full-text search. [query] uses FTS5 syntax; callers should sanitize.
  Future<List<Verse>> search(String query, {int limit = 100});

  /// Full-text search with highlighted snippets and optional filters.
  /// [ftsQuery] must already be sanitized (see `buildFtsQuery`).
  Future<SearchResults> searchDetailed(
    String ftsQuery, {
    SearchFilter filter = const SearchFilter(),
    int limit = 200,
  });
}
