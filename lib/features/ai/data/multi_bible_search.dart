import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/bible_database.dart';
import '../../../core/database/bundled_bibles.dart';
import '../../../core/database/database_providers.dart';
import '../../bible/data/datasources/bible_mappers.dart';
import '../../bible/data/repositories/drift_bible_repository.dart';
import '../../bible/domain/entities/search_result.dart';
import '../../bible/domain/search_query_builder.dart';

/// One bundled translation's search hits for a question.
class TranslationHits {
  const TranslationHits(this.abbreviation, this.hits);
  final String abbreviation;
  final List<SearchResult> hits;
}

/// Searches every bundled translation (KJV, WEB, ASV, and the two Ethiopian
/// editions) so the AI chat can ground and compare answers across all 5
/// bibles instead of only the user's currently selected one.
Future<List<TranslationHits>> searchAllTranslations(
  WidgetRef ref,
  String question, {
  int perTranslation = 3,
}) async {
  final fts = buildFtsQuery(question);
  if (fts == null) return const [];
  final baseDir = kIsWeb
      ? null
      : (await ref.read(bibleDbDirectoryProvider.future)).path;
  final out = <TranslationHits>[];
  for (final entry in BundledBibles.files.entries) {
    final path = kIsWeb
        ? BundledBibles.assetPath(entry.key)
        : p.join(baseDir!, entry.value);
    try {
      final db = BibleDatabase.open(path);
      try {
        final translation = translationFromMeta(entry.key, await db.readMeta());
        final repo = DriftBibleRepository(
          translation: translation,
          database: db,
        );
        final results = await repo.searchDetailed(fts, limit: perTranslation);
        if (results.hits.isNotEmpty) {
          out.add(TranslationHits(translation.abbreviation, results.hits));
        }
      } finally {
        await db.close();
      }
    } catch (_) {
      // Skip a translation whose search fails (e.g. missing FTS table on web).
    }
  }
  return out;
}
