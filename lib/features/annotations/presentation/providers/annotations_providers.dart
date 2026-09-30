import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../../bible/domain/entities/chapter.dart';
import '../../data/drift_annotations_repository.dart';
import '../../domain/entities/annotations.dart';
import '../../domain/repositories/annotations_repository.dart';

part 'annotations_providers.g.dart';

@Riverpod(keepAlive: true)
AnnotationsRepository annotationsRepository(Ref ref) {
  return DriftAnnotationsRepository(ref.watch(userDatabaseProvider));
}

// Per-chapter streams (used by the reader) -----------------------------------

@riverpod
Stream<List<Highlight>> chapterHighlights(Ref ref, ChapterId id) {
  return ref
      .watch(annotationsRepositoryProvider)
      .watchChapterHighlights(id.bookId, id.chapter);
}

@riverpod
Stream<List<Bookmark>> chapterBookmarks(Ref ref, ChapterId id) {
  return ref
      .watch(annotationsRepositoryProvider)
      .watchChapterBookmarks(id.bookId, id.chapter);
}

@riverpod
Stream<List<Note>> chapterNotes(Ref ref, ChapterId id) {
  return ref
      .watch(annotationsRepositoryProvider)
      .watchChapterNotes(id.bookId, id.chapter);
}

// Global streams (used by "My Stuff") ----------------------------------------

@riverpod
Stream<List<Highlight>> allHighlights(Ref ref) =>
    ref.watch(annotationsRepositoryProvider).watchAllHighlights();

@riverpod
Stream<List<Bookmark>> allBookmarks(Ref ref) =>
    ref.watch(annotationsRepositoryProvider).watchAllBookmarks();

@riverpod
Stream<List<Note>> allNotes(Ref ref) =>
    ref.watch(annotationsRepositoryProvider).watchAllNotes();
