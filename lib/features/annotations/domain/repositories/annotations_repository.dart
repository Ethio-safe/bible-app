import '../entities/annotations.dart';

/// Persistence for everything the user creates while reading.
/// All methods returning [Stream] emit immediately and on every change.
abstract interface class AnnotationsRepository {
  // Highlights --------------------------------------------------------------
  Stream<List<Highlight>> watchChapterHighlights(int bookId, int chapter);
  Stream<List<Highlight>> watchAllHighlights();

  /// Replaces any existing highlight overlapping the given verse range.
  Future<void> setHighlight({
    required int bookId,
    required int chapter,
    required int verseStart,
    required int verseEnd,
    required HighlightColor color,
  });

  /// Removes highlights overlapping the given verse range.
  Future<void> removeHighlight({
    required int bookId,
    required int chapter,
    required int verseStart,
    required int verseEnd,
  });

  Future<void> deleteHighlight(int id);

  // Bookmarks ---------------------------------------------------------------
  Stream<List<Bookmark>> watchChapterBookmarks(int bookId, int chapter);
  Stream<List<Bookmark>> watchAllBookmarks();
  Future<void> toggleBookmark(VerseRef ref);
  Future<void> deleteBookmark(int id);

  // Notes -------------------------------------------------------------------
  Stream<List<Note>> watchChapterNotes(int bookId, int chapter);
  Stream<List<Note>> watchAllNotes();
  Future<Note?> getNote(VerseRef ref);
  Future<void> saveNote(VerseRef ref, String body);
  Future<void> deleteNote(int id);

  // Reading position --------------------------------------------------------
  Future<ReadingPosition?> getReadingPosition(String translation);
  Future<void> saveReadingPosition(ReadingPosition position);
}
