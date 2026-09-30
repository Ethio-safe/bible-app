import '../../../../core/database/bible_database.dart' show BibleDatabase;
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/translation.dart';
import '../../domain/entities/verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../datasources/bible_mappers.dart';

class ChapterNotFoundException implements Exception {
  ChapterNotFoundException(this.ref);
  final ChapterId ref;

  @override
  String toString() =>
      'Chapter not found: book ${ref.bookId}, chapter ${ref.chapter}';
}

/// [BibleRepository] backed by a single read-only [BibleDatabase].
class DriftBibleRepository implements BibleRepository {
  DriftBibleRepository({
    required this.translation,
    required BibleDatabase database,
  }) : _db = database;

  @override
  final Translation translation;
  final BibleDatabase _db;

  List<Book>? _booksCache;

  @override
  Future<List<Book>> getBooks() async {
    return _booksCache ??= (await _db.allBooks())
        .map((b) => b.toDomain())
        .toList(growable: false);
  }

  @override
  Future<Book?> getBook(int bookId) async {
    final books = await getBooks();
    return books.where((b) => b.id == bookId).firstOrNull;
  }

  @override
  Future<Chapter> getChapter(ChapterId ref) async {
    final book = await getBook(ref.bookId);
    if (book == null || ref.chapter < 1 || ref.chapter > book.chapterCount) {
      throw ChapterNotFoundException(ref);
    }
    final rows = await _db.chapterVerses(ref.bookId, ref.chapter);
    return Chapter(
      book: book,
      number: ref.chapter,
      verses: rows.map((v) => v.toDomain()).toList(growable: false),
      isPassage: await _db.isPassageChapter(ref.bookId, ref.chapter),
      sourceNotes: await _db.sourceNotesFor(ref.bookId, ref.chapter),
      sourceNotice: translation.sourceNotice,
    );
  }

  @override
  Future<Verse?> getVerse(int bookId, int chapter, int verse) async {
    if (await _db.isPassageChapter(bookId, chapter)) return null;
    final row = await _db.singleVerse(bookId, chapter, verse);
    return row?.toDomain();
  }

  @override
  Future<List<Verse>> search(String query, {int limit = 100}) async {
    final rows = await _db.searchVerses(query, limit: limit);
    return rows.map((v) => v.toDomain()).toList(growable: false);
  }

  @override
  Future<SearchResults> searchDetailed(
    String ftsQuery, {
    SearchFilter filter = const SearchFilter(),
    int limit = 200,
  }) async {
    final sw = Stopwatch()..start();
    final books = await getBooks();
    final (hits, total) = await (
      _db.searchWithSnippets(
        ftsQuery,
        limit: limit,
        bookId: filter.bookId,
        testament: filter.scope.testamentCode,
        openMark: SearchResult.markOpen,
        closeMark: SearchResult.markClose,
      ),
      // Count is only cheap without filters; otherwise use hits length.
      filter.isDefault ? _db.countSearch(ftsQuery) : Future.value(-1),
    ).wait;
    sw.stop();

    final byId = {for (final book in books) book.id: book};
    final results = hits
        .where((h) => byId.containsKey(h.bookId))
        .map(
          (h) => SearchResult(
            book: byId[h.bookId]!,
            chapter: h.chapter,
            verse: h.verse,
            text: h.text,
            snippet: h.snippet,
          ),
        )
        .toList(growable: false);

    return SearchResults(
      hits: results,
      total: total < 0 ? results.length : total,
      elapsed: sw.elapsed,
    );
  }
}
