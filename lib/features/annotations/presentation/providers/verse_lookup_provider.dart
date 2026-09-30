import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../bible/domain/entities/chapter.dart';
import '../../domain/entities/annotations.dart';

part 'verse_lookup_provider.g.dart';

/// Human-readable reference + text for a verse (or range) in the current
/// translation. Used by "My Stuff" list items.
@riverpod
Future<({String reference, String text})> verseLookup(
  Ref ref,
  VerseRef verseRef, {
  int? verseEnd,
}) async {
  final repo = await ref.watch(bibleRepositoryProvider.future);
  final book = await repo.getBook(verseRef.bookId);
  if (book == null) {
    return (
      reference:
          'Book ${verseRef.bookId} ${verseRef.chapter}:${verseRef.verse}',
      text:
          'Unavailable in this edition. Switch to the edition where this item was saved.',
    );
  }
  final end = verseEnd ?? verseRef.verse;

  if (verseRef.chapter >= 1 && verseRef.chapter <= book.chapterCount) {
    final chapter = await repo.getChapter(
      ChapterId(bookId: verseRef.bookId, chapter: verseRef.chapter),
    );
    if (chapter.isPassage) {
      return (
        reference: '${chapter.title} (chapter passage)',
        text:
            'Whole-chapter reading passage; verse annotations are unavailable.',
      );
    }
  }

  final buffer = StringBuffer();
  for (var v = verseRef.verse; v <= end; v++) {
    final verse = await repo.getVerse(verseRef.bookId, verseRef.chapter, v);
    if (verse != null) buffer.write('${verse.text} ');
  }

  final range = end == verseRef.verse
      ? '${verseRef.verse}'
      : '${verseRef.verse}–$end';
  return (
    reference: '${book.name} ${verseRef.chapter}:$range',
    text: buffer.toString().trim(),
  );
}
