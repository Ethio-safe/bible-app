import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation.freezed.dart';

@freezed
abstract class Translation with _$Translation {
  const Translation._();

  String get languageLabel => language == 'am'
      ? 'Amharic'
      : language == 'en'
      ? 'English'
      : language;

  String get sourceNotice => '';

  const factory Translation({
    /// Stable key, also the DB file name stem (e.g. `kjv`).
    required String key,
    required String abbreviation,
    required String name,
    required String language,
    required String license,
    @Default('') String source,
    @Default('') String qualityNotes,
    @Default('') String sourceUrl,
  }) = _Translation;
}
