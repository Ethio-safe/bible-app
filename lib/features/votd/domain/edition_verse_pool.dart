import 'dart:convert';

import '../../../core/database/bible_database.dart';
import 'verse_pool.dart';

/// Validated references in one database's numbering. Canonical book mapping
/// does NOT establish shared OT versification for the Ethiopian collections.
class EditionVersePool {
  EditionVersePool._(this.verses, this._canonical);

  final List<PoolVerse> verses;
  final Map<String, PoolVerse> _canonical;

  static String _key(PoolVerse v) =>
      '${v.bookId}:${v.chapter}:${v.verse}:${v.endVerse}';

  PoolVerse resolve(PoolVerse requested) {
    final mapped = _canonical[_key(requested)];
    if (mapped != null) return mapped;
    for (final v in verses) {
      if (_key(v) == _key(requested)) return v;
    }
    // Return an actual reference with the fallback text, never the requested
    // label attached to an unrelated passage.
    return verses[(requested.bookId * 7919 +
            requested.chapter * 31 +
            requested.verse) %
        verses.length];
  }

  static Future<EditionVersePool> load(BibleDatabase db) async {
    final meta = await db.readMeta();
    final books = await db.allBooks();
    final byId = {for (final b in books) b.id: b};
    final study = books.any((b) => b.id >= 1000);
    final ids = <String, int>{};
    final raw = meta['canonical_book_ids'];
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            if (entry.key is String && entry.value is int) {
              ids[entry.key as String] = entry.value as int;
            }
          }
        }
      } on FormatException {
        // Invalid metadata must not make the background worker crash.
      }
    } else if (!study) {
      for (final b in books) {
        if (b.id >= 1 && b.id <= 66) ids['${b.id}'] = b.id;
      }
    }

    final chapters = <(int, int), Map<int, VerseRow>>{};
    final mapped = <String, PoolVerse>{};
    for (final v in versePool) {
      if (study && v.bookId < 40) continue;
      final id = ids['${v.bookId}'];
      final book = byId[id];
      if (id == null || book == null || (study && book.testament != 'NT'))
        continue;
      if (await db.isPassageChapter(id, v.chapter)) continue;
      final rows = chapters[(id, v.chapter)] ??= {
        for (final row in await db.chapterVerses(id, v.chapter)) row.verse: row,
      };
      var complete = true;
      for (var n = v.verse; n <= (v.endVerse ?? v.verse); n++) {
        if (rows[n]?.body.trim().isNotEmpty != true) complete = false;
      }
      if (!complete) continue;
      mapped[_key(v)] = PoolVerse(
        id,
        v.chapter,
        v.verse,
        v.theme,
        endVerse: v.endVerse,
      );
    }
    if (mapped.isNotEmpty)
      return EditionVersePool._(mapped.values.toList(), mapped);

    // Also handles missing/malformed maps and small or incomplete editions.
    final row = await db.customSelect('''
      SELECT v.book_id, v.chapter, v.verse FROM verses v
      JOIN books b ON b.id = v.book_id
      WHERE length(trim(v.text)) > 0 AND v.chapter > 0
        AND v.chapter <= b.chapter_count AND v.verse > 0
        AND ${BibleDatabase.nonPassageSql}
        ${study ? "AND b.testament = 'NT'" : ''}
      ORDER BY CASE WHEN b.testament = 'NT' THEN 0 ELSE 1 END,
        b.id, v.chapter, v.verse LIMIT 1
    ''').getSingleOrNull();
    if (row == null) throw StateError('This edition has no readable verses.');
    return EditionVersePool._([
      PoolVerse(
        row.read<int>('book_id'),
        row.read<int>('chapter'),
        row.read<int>('verse'),
        VerseTheme.hope,
      ),
    ], {});
  }
}
