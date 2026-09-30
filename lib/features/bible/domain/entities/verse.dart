import 'package:freezed_annotation/freezed_annotation.dart';

part 'verse.freezed.dart';

@freezed
abstract class Verse with _$Verse {
  const Verse._();

  const factory Verse({
    required int bookId,
    required int chapter,
    required int number,
    required String text,
  }) = _Verse;

  /// e.g. `43:3:16` — handy as a stable map key.
  String get key => '$bookId:$chapter:$number';
}
