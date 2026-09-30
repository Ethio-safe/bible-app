import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum WallpaperTarget { lock, home, both }

enum ApplyOutcome {
  /// Wallpaper set directly (Android).
  applied,

  /// Saved to Photos; user must set it manually (iOS).
  savedToPhotos,
}

abstract class WallpaperApplier {
  /// Whether [apply] can set the wallpaper directly on this platform.
  bool get canSetDirectly;

  Future<ApplyOutcome> apply(Uint8List png, WallpaperTarget target);

  /// Saves the PNG to the system gallery/Photos. Returns the album name used.
  Future<void> saveToGallery(Uint8List png);

  /// Writes to a temp file for sharing. Caller owns cleanup.
  static Future<File> writeTemp(
    Uint8List png, {
    String prefix = 'verse',
  }) async {
    final dir = await getTemporaryDirectory();
    final f = File(
      p.join(dir.path, '$prefix-${DateTime.now().millisecondsSinceEpoch}.png'),
    );
    return f.writeAsBytes(png, flush: true);
  }

  static WallpaperApplier forPlatform() {
    if (!kIsWeb && Platform.isAndroid) return AndroidWallpaperApplier();
    return IosWallpaperApplier();
  }
}

class AndroidWallpaperApplier implements WallpaperApplier {
  static const _channel = MethodChannel('com.versewall.bible/wallpaper');

  @override
  bool get canSetDirectly => true;

  @override
  Future<ApplyOutcome> apply(Uint8List png, WallpaperTarget target) async {
    await _channel.invokeMethod<void>('setWallpaper', {
      'bytes': png,
      'target': target.name,
    });
    return ApplyOutcome.applied;
  }

  @override
  Future<void> saveToGallery(Uint8List png) => _saveWithGal(png);
}

class IosWallpaperApplier implements WallpaperApplier {
  @override
  bool get canSetDirectly => false;

  @override
  Future<ApplyOutcome> apply(Uint8List png, WallpaperTarget target) async {
    await _saveWithGal(png);
    return ApplyOutcome.savedToPhotos;
  }

  @override
  Future<void> saveToGallery(Uint8List png) => _saveWithGal(png);
}

class GalleryAccessDenied implements Exception {
  const GalleryAccessDenied();
  @override
  String toString() => 'Photos access denied';
}

const galAlbum = 'Verse Bible';

Future<void> _saveWithGal(Uint8List png) async {
  if (!await Gal.hasAccess(toAlbum: true)) {
    final ok = await Gal.requestAccess(toAlbum: true);
    if (!ok) throw const GalleryAccessDenied();
  }
  await Gal.putImageBytes(
    png,
    album: galAlbum,
    name: 'verse-${DateTime.now().millisecondsSinceEpoch}',
  );
}
