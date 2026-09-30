import 'package:freezed_annotation/freezed_annotation.dart';

part 'reader_style.freezed.dart';

enum ReaderFont {
  serif('Serif', 'Lora'),
  sans('Sans', 'Inter');

  const ReaderFont(this.label, this.googleFontName);
  final String label;
  final String googleFontName;
}

/// Colour theme applied to the whole app (the reader is the primary surface).
enum ReaderTheme {
  light('Light'),
  sepia('Sepia'),
  dark('Dark'),
  system('System');

  const ReaderTheme(this.label);
  final String label;
}

@freezed
abstract class ReaderStyle with _$ReaderStyle {
  const ReaderStyle._();

  const factory ReaderStyle({
    @Default(20.0) double fontSize,
    @Default(ReaderFont.serif) ReaderFont font,
    @Default(1.7) double lineHeight,
    @Default(ReaderTheme.system) ReaderTheme theme,
  }) = _ReaderStyle;

  static const minFontSize = 14.0;
  static const maxFontSize = 30.0;
  static const minLineHeight = 1.2;
  static const maxLineHeight = 2.2;
}
