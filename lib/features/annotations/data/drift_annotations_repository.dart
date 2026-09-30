import '../../../core/database/user_database.dart';
import '../domain/entities/annotations.dart';
import '../domain/repositories/annotations_repository.dart';

class DriftAnnotationsRepository implements AnnotationsRepository {
  DriftAnnotationsRepository(this._db);

  final UserDatabase _db;

  // Highlights ----------------------------------------------------------------

  @override
  Stream<List<Highlight>> watchChapterHighlights(int bookId, int chapter) =>
      _db.watchChapterHighlights(bookId, chapter).map(_mapHighlights);

  @override
  Stream<List<Highlight>> watchAllHighlights() =>
      _db.watchAllHighlights().map(_mapHighlights);

  @override
  Future<void> setHighlight({
    required int bookId,
    required int chapter,
    required int verseStart,
    required int verseEnd,
    required HighlightColor color,
  }) => _db.setHighlight(
    bookId: bookId,
    chapter: chapter,
    verseStart: verseStart,
    verseEnd: verseEnd,
    color: color.index,
  );

  @override
  Future<void> removeHighlight({
    required int bookId,
    required int chapter,
    required int verseStart,
    required int verseEnd,
  }) => _db.removeHighlight(
    bookId: bookId,
    chapter: chapter,
    verseStart: verseStart,
    verseEnd: verseEnd,
  );

  @override
  Future<void> deleteHighlight(int id) => _db.deleteHighlight(id);

  // Bookmarks -----------------------------------------------------------------

  @override
  Stream<List<Bookmark>> watchChapterBookmarks(int bookId, int chapter) =>
      _db.watchChapterBookmarks(bookId, chapter).map(_mapBookmarks);

  @override
  Stream<List<Bookmark>> watchAllBookmarks() =>
      _db.watchAllBookmarks().map(_mapBookmarks);

  @override
  Future<void> toggleBookmark(VerseRef ref) =>
      _db.toggleBookmark(ref.bookId, ref.chapter, ref.verse);

  @override
  Future<void> deleteBookmark(int id) => _db.deleteBookmark(id);

  // Notes ---------------------------------------------------------------------

  @override
  Stream<List<Note>> watchChapterNotes(int bookId, int chapter) =>
      _db.watchChapterNotes(bookId, chapter).map(_mapNotes);

  @override
  Stream<List<Note>> watchAllNotes() => _db.watchAllNotes().map(_mapNotes);

  @override
  Future<Note?> getNote(VerseRef ref) async {
    final row = await _db.noteFor(ref.bookId, ref.chapter, ref.verse);
    return row == null ? null : _note(row);
  }

  @override
  Future<void> saveNote(VerseRef ref, String body) =>
      _db.upsertNote(ref.bookId, ref.chapter, ref.verse, body);

  @override
  Future<void> deleteNote(int id) => _db.deleteNote(id);

  // Reading position ----------------------------------------------------------

  @override
  Future<ReadingPosition?> getReadingPosition(String translation) async {
    final row = await _db.readingPosition(translation);
    if (row == null) return null;
    return ReadingPosition(
      translation: row.translation,
      bookId: row.bookId,
      chapter: row.chapter,
      scrollOffset: row.scrollOffset,
    );
  }

  @override
  Future<void> saveReadingPosition(ReadingPosition position) =>
      _db.saveReadingPosition(
        translation: position.translation,
        bookId: position.bookId,
        chapter: position.chapter,
        scrollOffset: position.scrollOffset,
      );

  // Mappers -------------------------------------------------------------------

  static List<Highlight> _mapHighlights(List<HighlightRow> rows) => rows
      .map(
        (r) => Highlight(
          id: r.id,
          bookId: r.bookId,
          chapter: r.chapter,
          verseStart: r.verseStart,
          verseEnd: r.verseEnd,
          color: HighlightColor.fromIndex(r.color),
          createdAt: r.createdAt,
        ),
      )
      .toList(growable: false);

  static List<Bookmark> _mapBookmarks(List<BookmarkRow> rows) => rows
      .map(
        (r) => Bookmark(
          id: r.id,
          bookId: r.bookId,
          chapter: r.chapter,
          verse: r.verse,
          createdAt: r.createdAt,
        ),
      )
      .toList(growable: false);

  static List<Note> _mapNotes(List<NoteRow> rows) =>
      rows.map(_note).toList(growable: false);

  static Note _note(NoteRow r) => Note(
    id: r.id,
    bookId: r.bookId,
    chapter: r.chapter,
    verse: r.verse,
    body: r.body,
    updatedAt: r.updatedAt,
  );
}
