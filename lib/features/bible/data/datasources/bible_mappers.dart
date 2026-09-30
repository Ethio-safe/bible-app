import '../../../../core/database/bible_database.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/translation.dart';
import '../../domain/entities/verse.dart';

/// Drift row → domain entity mappers.
extension BookRowMapper on BookRow {
  Book toDomain() => Book(
    id: id,
    name: name,
    abbreviation: abbreviation,
    testament: testament == 'OT'
        ? Testament.oldTestament
        : Testament.newTestament,
    chapterCount: chapterCount,
  );
}

extension VerseRowMapper on VerseRow {
  Verse toDomain() =>
      Verse(bookId: bookId, chapter: chapter, number: verse, text: body);
}

Translation translationFromMeta(String key, Map<String, String> meta) {
  return Translation(
    key: key,
    abbreviation: meta['abbreviation'] ?? key.toUpperCase(),
    name: meta['name'] ?? key.toUpperCase(),
    language: meta['language'] ?? 'en',
    license: meta['license'] ?? 'License information not supplied',
    source: [
      if (meta['source'] case final String source) source,
      if (meta['web_source'] case final String source)
        'World English Bible (standard 66 books): $source',
      if (meta['archive_source'] case final String source)
        'Mixed-source archive: $source',
      if (meta['meqabyan_attribution'] case final String attribution)
        'Meqabyan attribution: $attribution',
      if (meta['meqabyan_caveat'] case final String caveat)
        'Meqabyan source caveat: $caveat',
      if (meta['meqabyan_source_url'] case final String url)
        'Meqabyan source: $url',
    ].join('\n\n'),
    qualityNotes: meta['quality_notes'] ?? '',
    sourceUrl: meta['source_url'] ?? '',
  );
}
