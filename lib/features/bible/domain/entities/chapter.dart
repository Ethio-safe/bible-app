import 'package:freezed_annotation/freezed_annotation.dart';

import 'book.dart';
import 'verse.dart';

part 'chapter.freezed.dart';

/// Identifies a chapter independent of translation.
@freezed
abstract class ChapterId with _$ChapterId {
  const ChapterId._();

  const factory ChapterId({required int bookId, required int chapter}) =
      _ChapterId;

  ChapterId get next => ChapterId(bookId: bookId, chapter: chapter + 1);
  ChapterId get previous => ChapterId(bookId: bookId, chapter: chapter - 1);
}

/// A fully loaded chapter with its verses.
@freezed
abstract class Chapter with _$Chapter {
  const Chapter._();

  const factory Chapter({
    required Book book,
    required int number,
    required List<Verse> verses,
    @Default(false) bool isPassage,
    @Default('') String sourceNotes,
    @Default('') String sourceNotice,
  }) = _Chapter;

  ChapterId get ref => ChapterId(bookId: book.id, chapter: number);

  /// e.g. `John 3`
  String get title => '${book.name} $number';

  bool get hasNext => number < book.chapterCount;
  bool get hasPrevious => number > 1;
}
