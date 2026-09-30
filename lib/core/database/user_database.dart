import 'package:drift/drift.dart';

import 'user_database_executor.dart';

part 'user_database.g.dart';

/// Where the user last stopped reading, per translation.
@DataClassName('ReadingPositionRow')
class ReadingPositions extends Table {
  TextColumn get translation => text()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  RealColumn get scrollOffset => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {translation};
}

@DataClassName('HighlightRow')
class Highlights extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verseStart => integer()();
  IntColumn get verseEnd => integer()();
  IntColumn get color => integer()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('BookmarkRow')
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {bookId, chapter, verse},
  ];
}

@DataClassName('NoteRow')
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get body => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {bookId, chapter, verse},
  ];
}

/// Background images available to the wallpaper engine (seed + remote cache).
@DataClassName('WallpaperImageRow')
class WallpaperImages extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Absolute path in the app documents directory.
  TextColumn get path => text()();

  /// `seed` or `remote`.
  TextColumn get source => text()();

  /// Stable key, e.g. `seed_01` or remote id. Unique.
  TextColumn get key => text()();
  TextColumn get mood => text().nullable()();
  BoolColumn get isDark => boolean().withDefault(const Constant(true))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  /// Remote attribution (Unsplash/Pexels require display + link).
  TextColumn get authorName => text().nullable()();
  TextColumn get authorUrl => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get provider => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {key},
  ];
}

/// Every automatic or manual wallpaper application. Used to avoid repeats
/// and to show a history list.
@DataClassName('WallpaperHistoryRow')
class WallpaperHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get imageId => integer()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get template => text()();
  TextColumn get target => text()();

  /// `auto` or `manual`.
  TextColumn get trigger => text()();
  BoolColumn get success => boolean().withDefault(const Constant(true))();
  TextColumn get error => text().nullable()();
  DateTimeColumn get appliedAt => dateTime()();
}

/// Writable, device-local database for everything the user creates.
/// Bible text itself lives in [BibleDatabase].
@DriftDatabase(
  tables: [
    ReadingPositions,
    Highlights,
    Bookmarks,
    Notes,
    WallpaperImages,
    WallpaperHistory,
  ],
)
class UserDatabase extends _$UserDatabase {
  UserDatabase() : super(_openConnection());

  /// For tests.
  UserDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(wallpaperImages);
      if (from < 3) {
        await m.addColumn(wallpaperImages, wallpaperImages.authorName);
        await m.addColumn(wallpaperImages, wallpaperImages.authorUrl);
        await m.addColumn(wallpaperImages, wallpaperImages.sourceUrl);
        await m.addColumn(wallpaperImages, wallpaperImages.provider);
        await m.createTable(wallpaperHistory);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return openUserDatabaseExecutor();
  }

  // ---------------------------------------------------------------------------
  // Reading position
  // ---------------------------------------------------------------------------

  Future<ReadingPositionRow?> readingPosition(String translation) => (select(
    readingPositions,
  )..where((r) => r.translation.equals(translation))).getSingleOrNull();

  Future<void> saveReadingPosition({
    required String translation,
    required int bookId,
    required int chapter,
    double scrollOffset = 0,
  }) {
    return into(readingPositions).insertOnConflictUpdate(
      ReadingPositionsCompanion.insert(
        translation: translation,
        bookId: bookId,
        chapter: chapter,
        scrollOffset: Value(scrollOffset),
        updatedAt: DateTime.now(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Highlights
  // ---------------------------------------------------------------------------

  Stream<List<HighlightRow>> watchChapterHighlights(int bookId, int chapter) =>
      (select(highlights)
            ..where((h) => h.bookId.equals(bookId) & h.chapter.equals(chapter))
            ..orderBy([(h) => OrderingTerm.asc(h.verseStart)]))
          .watch();

  Stream<List<HighlightRow>> watchAllHighlights() => (select(
    highlights,
  )..orderBy([(h) => OrderingTerm.desc(h.createdAt)])).watch();

  /// Deletes highlights overlapping [verseStart]..[verseEnd] then inserts one
  /// covering the whole range with [color]. Runs in a transaction.
  Future<void> setHighlight({
    required int bookId,
    required int chapter,
    required int verseStart,
    required int verseEnd,
    required int color,
  }) {
    return transaction(() async {
      await _deleteOverlapping(bookId, chapter, verseStart, verseEnd);
      await into(highlights).insert(
        HighlightsCompanion.insert(
          bookId: bookId,
          chapter: chapter,
          verseStart: verseStart,
          verseEnd: verseEnd,
          color: color,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> removeHighlight({
    required int bookId,
    required int chapter,
    required int verseStart,
    required int verseEnd,
  }) => _deleteOverlapping(bookId, chapter, verseStart, verseEnd);

  Future<int> _deleteOverlapping(
    int bookId,
    int chapter,
    int verseStart,
    int verseEnd,
  ) {
    return (delete(highlights)..where(
          (h) =>
              h.bookId.equals(bookId) &
              h.chapter.equals(chapter) &
              h.verseStart.isSmallerOrEqualValue(verseEnd) &
              h.verseEnd.isBiggerOrEqualValue(verseStart),
        ))
        .go();
  }

  Future<int> deleteHighlight(int id) =>
      (delete(highlights)..where((h) => h.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Bookmarks
  // ---------------------------------------------------------------------------

  Stream<List<BookmarkRow>> watchChapterBookmarks(int bookId, int chapter) =>
      (select(bookmarks)
            ..where((b) => b.bookId.equals(bookId) & b.chapter.equals(chapter)))
          .watch();

  Stream<List<BookmarkRow>> watchAllBookmarks() => (select(
    bookmarks,
  )..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).watch();

  Future<void> toggleBookmark(int bookId, int chapter, int verse) {
    return transaction(() async {
      final removed =
          await (delete(bookmarks)..where(
                (b) =>
                    b.bookId.equals(bookId) &
                    b.chapter.equals(chapter) &
                    b.verse.equals(verse),
              ))
              .go();
      if (removed == 0) {
        await into(bookmarks).insert(
          BookmarksCompanion.insert(
            bookId: bookId,
            chapter: chapter,
            verse: verse,
            createdAt: DateTime.now(),
          ),
        );
      }
    });
  }

  Future<int> deleteBookmark(int id) =>
      (delete(bookmarks)..where((b) => b.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Notes
  // ---------------------------------------------------------------------------

  Stream<List<NoteRow>> watchChapterNotes(int bookId, int chapter) => (select(
    notes,
  )..where((n) => n.bookId.equals(bookId) & n.chapter.equals(chapter))).watch();

  Stream<List<NoteRow>> watchAllNotes() =>
      (select(notes)..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])).watch();

  Future<NoteRow?> noteFor(int bookId, int chapter, int verse) =>
      (select(notes)..where(
            (n) =>
                n.bookId.equals(bookId) &
                n.chapter.equals(chapter) &
                n.verse.equals(verse),
          ))
          .getSingleOrNull();

  Future<void> upsertNote(int bookId, int chapter, int verse, String body) {
    return into(notes).insert(
      NotesCompanion.insert(
        bookId: bookId,
        chapter: chapter,
        verse: verse,
        body: body,
        updatedAt: DateTime.now(),
      ),
      onConflict: DoUpdate(
        (_) =>
            NotesCompanion(body: Value(body), updatedAt: Value(DateTime.now())),
        target: [notes.bookId, notes.chapter, notes.verse],
      ),
    );
  }

  Future<int> deleteNote(int id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Wallpaper images
  // ---------------------------------------------------------------------------

  Stream<List<WallpaperImageRow>> watchWallpaperImages() =>
      (select(wallpaperImages)..orderBy([
            (w) => OrderingTerm.desc(w.isFavorite),
            (w) => OrderingTerm.asc(w.addedAt),
          ]))
          .watch();

  Future<List<WallpaperImageRow>> allWallpaperImages() =>
      select(wallpaperImages).get();

  Future<WallpaperImageRow?> wallpaperImageById(int id) => (select(
    wallpaperImages,
  )..where((w) => w.id.equals(id))).getSingleOrNull();

  Future<bool> hasWallpaperImage(String key) async {
    final row = await (select(
      wallpaperImages,
    )..where((w) => w.key.equals(key))).getSingleOrNull();
    return row != null;
  }

  Future<int> insertWallpaperImage(WallpaperImagesCompanion row) =>
      into(wallpaperImages).insert(row, mode: InsertMode.insertOrIgnore);

  Future<void> setWallpaperFavorite(int id, bool favorite) =>
      (update(wallpaperImages)..where((w) => w.id.equals(id))).write(
        WallpaperImagesCompanion(isFavorite: Value(favorite)),
      );

  Future<void> touchWallpaperImage(int id) =>
      (update(wallpaperImages)..where((w) => w.id.equals(id))).write(
        WallpaperImagesCompanion(lastUsedAt: Value(DateTime.now())),
      );

  Future<int> deleteWallpaperImage(int id) =>
      (delete(wallpaperImages)..where((w) => w.id.equals(id))).go();

  /// Non-favorite remote images, least recently used first (never used → by
  /// addedAt). Candidates for eviction.
  Future<List<WallpaperImageRow>> evictableWallpaperImages() =>
      (select(wallpaperImages)
            ..where(
              (w) => w.isFavorite.equals(false) & w.source.equals('remote'),
            )
            ..orderBy([
              (w) => OrderingTerm.asc(w.lastUsedAt),
              (w) => OrderingTerm.asc(w.addedAt),
            ]))
          .get();

  // ---------------------------------------------------------------------------
  // Wallpaper history
  // ---------------------------------------------------------------------------

  Future<int> insertWallpaperHistory(WallpaperHistoryCompanion row) =>
      into(wallpaperHistory).insert(row);

  Stream<List<WallpaperHistoryRow>> watchWallpaperHistory({int limit = 50}) =>
      (select(wallpaperHistory)
            ..orderBy([(h) => OrderingTerm.desc(h.appliedAt)])
            ..limit(limit))
          .watch();

  Future<List<WallpaperHistoryRow>> recentWallpaperHistory(int limit) =>
      (select(wallpaperHistory)
            ..where((h) => h.success.equals(true))
            ..orderBy([(h) => OrderingTerm.desc(h.appliedAt)])
            ..limit(limit))
          .get();

  Future<int> pruneWallpaperHistory({int keep = 200}) async {
    final rows =
        await (select(wallpaperHistory)
              ..orderBy([(h) => OrderingTerm.desc(h.appliedAt)])
              ..limit(1, offset: keep))
            .get();
    if (rows.isEmpty) return 0;
    return (delete(wallpaperHistory)..where(
          (h) => h.appliedAt.isSmallerOrEqualValue(rows.first.appliedAt),
        ))
        .go();
  }

  // ---------------------------------------------------------------------------
  // Backup
  // ---------------------------------------------------------------------------

  Future<List<HighlightRow>> allHighlights() => select(highlights).get();
  Future<List<BookmarkRow>> allBookmarks() => select(bookmarks).get();
  Future<List<NoteRow>> allNotes() => select(notes).get();

  /// Merges rows into the database. Bookmarks/notes collide on verse (notes:
  /// newer `updatedAt` wins); highlights are inserted unless an identical
  /// range+color already exists. Returns the number of rows written.
  Future<int> importAll({
    required List<HighlightsCompanion> highlightRows,
    required List<BookmarksCompanion> bookmarkRows,
    required List<NotesCompanion> noteRows,
  }) {
    return transaction(() async {
      var written = 0;

      final existingHl = await allHighlights();
      for (final h in highlightRows) {
        final dup = existingHl.any(
          (e) =>
              e.bookId == h.bookId.value &&
              e.chapter == h.chapter.value &&
              e.verseStart == h.verseStart.value &&
              e.verseEnd == h.verseEnd.value &&
              e.color == h.color.value,
        );
        if (dup) continue;
        await into(highlights).insert(h);
        written++;
      }

      final existingBm = await allBookmarks();
      for (final b in bookmarkRows) {
        final dup = existingBm.any(
          (e) =>
              e.bookId == b.bookId.value &&
              e.chapter == b.chapter.value &&
              e.verse == b.verse.value,
        );
        if (dup) continue;
        await into(bookmarks).insert(b);
        written++;
      }

      for (final n in noteRows) {
        final existing = await noteFor(
          n.bookId.value,
          n.chapter.value,
          n.verse.value,
        );
        if (existing == null) {
          await into(notes).insert(n);
          written++;
        } else if (n.updatedAt.value.isAfter(existing.updatedAt)) {
          await (update(notes)..where((t) => t.id.equals(existing.id))).write(
            NotesCompanion(body: n.body, updatedAt: n.updatedAt),
          );
          written++;
        }
      }
      return written;
    });
  }
}
