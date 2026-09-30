import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart side of the Android live-wallpaper integration.
///
/// The native `VerseLiveWallpaperService` shows PNGs from [directory] and
/// advances to the next one every time the screen is locked. We pre-render
/// those PNGs here and tell the service when the set has changed.
class LiveWallpaperService {
  const LiveWallpaperService();

  static const _channel = MethodChannel('com.versewall.bible/wallpaper');

  static bool get supported => !kIsWeb && Platform.isAndroid;

  /// Folder the native engine reads from (`filesDir/live_wallpapers`).
  Future<Directory> directory() async {
    final path = await _channel.invokeMethod<String>('liveWallpaperDir');
    return Directory(path!)..createSync(recursive: true);
  }

  /// True when our service is the currently selected system wallpaper.
  Future<bool> isActive() async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>('isLiveWallpaperActive') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the system chooser so the user can grant us wallpaper duty.
  /// Returns false if no chooser activity could be launched.
  Future<bool> openChooser() async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>('openLiveWallpaperChooser') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// Tells a running engine to reload the image set from disk.
  Future<void> refresh() async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>('refreshLiveWallpaper');
    } on PlatformException {
      // Engine not running; it will pick up the new set on next start.
    }
  }

  /// Number of rendered wallpapers currently on disk.
  Future<int> count() async {
    if (!supported) return 0;
    final dir = await directory();
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .length;
  }

  // ── Lock-screen rotation (foreground service) ─────────────────────────

  /// Starts the service that sets a new wallpaper on every screen-off.
  /// [target] is `lock`, `home` or `both`.
  Future<void> startLockRotation({String target = 'lock'}) async {
    if (!supported) return;
    await _channel.invokeMethod<void>('startLockRotation', {'target': target});
  }

  Future<void> stopLockRotation() async {
    if (!supported) return;
    await _channel.invokeMethod<void>('stopLockRotation');
  }

  Future<bool> isLockRotationRunning() async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>('isLockRotationRunning') ??
          false;
    } on PlatformException {
      return false;
    }
  }
}
