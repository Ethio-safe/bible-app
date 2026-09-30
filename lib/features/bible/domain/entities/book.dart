import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';

enum Testament { oldTestament, newTestament }

@freezed
abstract class Book with _$Book {
  const Book._();

  const factory Book({
    /// Stable edition-specific ID, not a list index or testament indicator.
    required int id,
    required String name,
    required String abbreviation,
    required Testament testament,
    required int chapterCount,
  }) = _Book;

  bool get isOldTestament => testament == Testament.oldTestament;
}
