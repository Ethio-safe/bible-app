import 'package:flutter/material.dart' show Color;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'annotations.freezed.dart';

/// Reference to a single verse, translation-independent.
@freezed
abstract class VerseRef with _$VerseRef {
  const VerseRef._();

  const factory VerseRef({
    required int bookId,
    required int chapter,
    required int verse,
  }) = _VerseRef;

  String get key => '$bookId:$chapter:$verse';
}

/// The five highlight colours, stored by index.
enum HighlightColor {
  yellow(Color(0xFFFFE082), Color(0xFF7A5C00)),
  green(Color(0xFFC5E1A5), Color(0xFF33691E)),
  blue(Color(0xFFB3E5FC), Color(0xFF01579B)),
  pink(Color(0xFFF8BBD0), Color(0xFF880E4F)),
  purple(Color(0xFFD1C4E9), Color(0xFF4527A0));

  const HighlightColor(this.light, this.dark);

  /// Fill colour on light backgrounds.
  final Color light;

  /// Fill colour on dark backgrounds.
  final Color dark;

  static HighlightColor fromIndex(int i) =>
      values[i.clamp(0, values.length - 1)];
}

@freezed
abstract class Highlight with _$Highlight {
  const Highlight._();

  const factory Highlight({
    required int id,
    required int bookId,
    required int chapter,
    required int verseStart,
    required int verseEnd,
    required HighlightColor color,
    required DateTime createdAt,
  }) = _Highlight;

  bool covers(int verse) => verse >= verseStart && verse <= verseEnd;

  String get reference =>
      verseStart == verseEnd ? '$verseStart' : '$verseStart–$verseEnd';
}

@freezed
abstract class Bookmark with _$Bookmark {
  const factory Bookmark({
    required int id,
    required int bookId,
    required int chapter,
    required int verse,
    required DateTime createdAt,
  }) = _Bookmark;
}

@freezed
abstract class Note with _$Note {
  const factory Note({
    required int id,
    required int bookId,
    required int chapter,
    required int verse,
    required String body,
    required DateTime updatedAt,
  }) = _Note;
}

@freezed
abstract class ReadingPosition with _$ReadingPosition {
  const factory ReadingPosition({
    required String translation,
    required int bookId,
    required int chapter,
    @Default(0) double scrollOffset,
  }) = _ReadingPosition;
}
