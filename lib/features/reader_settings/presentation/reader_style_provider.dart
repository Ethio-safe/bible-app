import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/preferences_provider.dart';
import '../domain/reader_style.dart';

part 'reader_style_provider.g.dart';

/// Reader typography + theme, persisted to SharedPreferences.
@Riverpod(keepAlive: true)
class ReaderStyleNotifier extends _$ReaderStyleNotifier {
  static const _kFontSize = 'reader_font_size';
  static const _kFont = 'reader_font';
  static const _kLineHeight = 'reader_line_height';
  static const _kTheme = 'reader_theme';

  @override
  ReaderStyle build() {
    final p = ref.watch(sharedPreferencesProvider);
    const d = ReaderStyle();
    return ReaderStyle(
      fontSize: p.getDouble(_kFontSize) ?? d.fontSize,
      font:
          ReaderFont.values[(p.getInt(_kFont) ?? d.font.index).clamp(
            0,
            ReaderFont.values.length - 1,
          )],
      lineHeight: p.getDouble(_kLineHeight) ?? d.lineHeight,
      theme:
          ReaderTheme.values[(p.getInt(_kTheme) ?? d.theme.index).clamp(
            0,
            ReaderTheme.values.length - 1,
          )],
    );
  }

  Future<void> setFontSize(double v) async {
    final size = v.clamp(ReaderStyle.minFontSize, ReaderStyle.maxFontSize);
    state = state.copyWith(fontSize: size);
    await ref.read(sharedPreferencesProvider).setDouble(_kFontSize, size);
  }

  Future<void> setFont(ReaderFont f) async {
    state = state.copyWith(font: f);
    await ref.read(sharedPreferencesProvider).setInt(_kFont, f.index);
  }

  Future<void> setLineHeight(double v) async {
    final h = v.clamp(ReaderStyle.minLineHeight, ReaderStyle.maxLineHeight);
    state = state.copyWith(lineHeight: h);
    await ref.read(sharedPreferencesProvider).setDouble(_kLineHeight, h);
  }

  Future<void> setTheme(ReaderTheme t) async {
    state = state.copyWith(theme: t);
    await ref.read(sharedPreferencesProvider).setInt(_kTheme, t.index);
  }

  Future<void> reset() async {
    state = const ReaderStyle();
    final p = ref.read(sharedPreferencesProvider);
    await Future.wait([
      p.remove(_kFontSize),
      p.remove(_kFont),
      p.remove(_kLineHeight),
      p.remove(_kTheme),
    ]);
  }
}
