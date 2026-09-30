import 'dart:convert';

import 'package:drift/drift.dart';

import 'bible_database_executor.dart';

part 'bible_database.g.dart';

/// Metadata key/value pairs (abbreviation, name, language, license, ...).
@DataClassName('MetaRow')
class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('BookRow')
class Books extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get abbreviation => text()();
  TextColumn get testament => text()();
  IntColumn get chapterCount => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VerseRow')
class Verses extends Table {
  IntColumn get id => integer()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();

  /// Verse text. Named `body` in Dart to avoid shadowing the `text()` builder;
  /// mapped to the `text` column produced by the build script.
  TextColumn get body => text().named('text')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Read-only connection to one pre-built translation database
/// (`kjv.db`, `web.db`, ...). The schema is created by
/// `tools/build_bible_db.py`; Drift never migrates it.
///
/// Full-text search lives in the `verses_fts` FTS5 virtual table and is
/// queried with raw SQL (see [searchVerses]).
@DriftDatabase(tables: [Meta, Books, Verses])
class BibleDatabase extends _$BibleDatabase {
  BibleDatabase(super.executor);

  /// Opens the database file at [path] read-only on a background isolate.
  ///
  /// Migrations are disabled because the schema is baked into the asset file;
  /// `query_only` makes any accidental write fail loudly.
  factory BibleDatabase.open(String path) {
    return BibleDatabase(openBibleExecutor(path));
  }

  @override
  int get schemaVersion => 1;

  Future<Map<String, String>>? _metadata;

  /// A passage row's verse number is a storage key, not a Bible reference.
  static const nonPassageSql = '''NOT EXISTS (
    SELECT 1 FROM json_each(COALESCE((
      SELECT CASE WHEN json_valid(value) THEN value ELSE '[]' END
      FROM meta WHERE key = 'passage_chapters'
    ), '[]')) p WHERE p.value = CAST(v.book_id AS TEXT) || ':' || v.chapter
  )''';

  Future<bool> isPassageChapter(int bookId, int chapter) async {
    final raw = (await (_metadata ??= readMeta()))['passage_chapters'];
    if (raw == null) return false;
    try {
      final value = jsonDecode(raw);
      return value is List && value.contains('$bookId:$chapter');
    } on FormatException {
      return false;
    }
  }

  Future<String> sourceNotesFor(int bookId, int chapter) async {
    final raw = (await (_metadata ??= readMeta()))['chapter_notes'];
    if (raw == null) return '';
    try {
      final value = jsonDecode(raw);
      final note = value is Map ? value['$bookId:$chapter'] : null;
      return note is String ? note : '';
    } on FormatException {
      return '';
    }
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  Future<Map<String, String>> readMeta() async {
    final rows = await select(meta).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<List<BookRow>> allBooks() =>
      (select(books)..orderBy([(b) => OrderingTerm.asc(b.id)])).get();

  Future<BookRow?> bookById(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<List<VerseRow>> chapterVerses(int bookId, int chapter) =>
      (select(verses)
            ..where((v) => v.bookId.equals(bookId) & v.chapter.equals(chapter))
            ..orderBy([(v) => OrderingTerm.asc(v.verse)]))
          .get();

  Future<VerseRow?> singleVerse(int bookId, int chapter, int verse) =>
      (select(verses)..where(
            (v) =>
                v.bookId.equals(bookId) &
                v.chapter.equals(chapter) &
                v.verse.equals(verse),
          ))
          .getSingleOrNull();

  /// Full-text search over verse text using FTS5. Results are ranked by bm25.
  Future<List<VerseRow>> searchVerses(String query, {int limit = 100}) {
    return customSelect(
      '''
      SELECT v.* FROM verses_fts f
      JOIN verses v ON v.id = f.rowid
      WHERE verses_fts MATCH ? AND $nonPassageSql
      ORDER BY bm25(verses_fts)
      LIMIT ?
      ''',
      variables: [Variable.withString(query), Variable.withInt(limit)],
      readsFrom: {verses},
    ).map((row) => verses.map(row.data)).get();
  }

  /// FTS5 search returning a highlighted snippet per hit.
  ///
  /// Matches inside the snippet are wrapped in [openMark]/[closeMark] so the
  /// UI can render them bold. Optional filters restrict by testament or book.
  Future<List<SearchHit>> searchWithSnippets(
    String query, {
    int limit = 200,
    String? testament,
    int? bookId,
    String openMark = '\u0001',
    String closeMark = '\u0002',
  }) {
    // Variables in SQL order: snippet marks, MATCH, optional filter, limit.
    final where = StringBuffer('verses_fts MATCH ? AND $nonPassageSql');
    final vars = <Variable>[
      Variable.withString(openMark),
      Variable.withString(closeMark),
      Variable.withString(query),
    ];
    if (bookId != null) {
      where.write(' AND v.book_id = ?');
      vars.add(Variable.withInt(bookId));
    } else if (testament != null) {
      where.write(' AND b.testament = ?');
      vars.add(Variable.withString(testament));
    }
    vars.add(Variable.withInt(limit));

    return customSelect(
      '''
      SELECT v.book_id, v.chapter, v.verse, v.text,
             snippet(verses_fts, 0, ?, ?, '…', 40) AS snippet
      FROM verses_fts f
      JOIN verses v ON v.id = f.rowid
      JOIN books  b ON b.id = v.book_id
      WHERE $where
      ORDER BY bm25(verses_fts)
      LIMIT ?
      ''',
      variables: vars,
      readsFrom: {verses, books},
    ).map((row) {
      return SearchHit(
        bookId: row.read<int>('book_id'),
        chapter: row.read<int>('chapter'),
        verse: row.read<int>('verse'),
        text: row.read<String>('text'),
        snippet: row.read<String>('snippet'),
      );
    }).get();
  }

  /// Total number of verses matching [query] (for "N results" labels).
  Future<int> countSearch(String query) async {
    final row = await customSelect(
      'SELECT count(*) AS c FROM verses_fts '
      'JOIN verses v ON v.id = verses_fts.rowid '
      'WHERE verses_fts MATCH ? AND $nonPassageSql',
      variables: [Variable.withString(query)],
    ).getSingle();
    return row.read<int>('c');
  }
}

/// Raw search row with FTS snippet; mapped to a domain type upstream.
class SearchHit {
  const SearchHit({
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.snippet,
  });

  final int bookId;
  final int chapter;
  final int verse;
  final String text;
  final String snippet;
}
