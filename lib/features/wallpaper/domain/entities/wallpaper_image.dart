import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallpaper_image.freezed.dart';

enum WallpaperSource { seed, remote }

@freezed
abstract class WallpaperImage with _$WallpaperImage {
  const WallpaperImage._();

  const factory WallpaperImage({
    required int id,
    required String key,
    required String path,
    required WallpaperSource source,
    required bool isDark,
    required bool isFavorite,
    required int width,
    required int height,
    String? mood,
    DateTime? lastUsedAt,
    String? authorName,
    String? authorUrl,
    String? sourceUrl,
    String? provider,
  }) = _WallpaperImage;

  File get file => File(path);

  bool get hasAttribution => authorName != null && provider != null;

  String? get attributionLine => hasAttribution
      ? 'Photo by $authorName on ${provider![0].toUpperCase()}${provider!.substring(1)}'
      : null;
}

/// The text that goes on a wallpaper.
@freezed
abstract class WallpaperQuote with _$WallpaperQuote {
  const WallpaperQuote._();

  const factory WallpaperQuote({
    required String text,
    required String reference,
    required String translation,
    required int bookId,
    required int chapter,
    required int verse,
  }) = _WallpaperQuote;

  String get attribution => '$reference · $translation';
}

/// Visual arrangement of the quote on the image.
enum WallpaperTemplate {
  /// Centered serif quote, reference below, soft dark scrim.
  classic('Classic'),

  /// Quote anchored to the lower third above the lock-screen shortcuts.
  lowerThird('Lower third'),

  /// Big bold sans quote, left aligned, strong bottom gradient.
  bold('Bold'),

  /// Small quote inside a frosted card in the middle.
  card('Card');

  const WallpaperTemplate(this.label);
  final String label;
}
