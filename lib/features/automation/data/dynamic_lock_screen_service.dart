import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart bridge to Samsung-like dynamic lock screen functionality with root support.
///
/// This service enables rooted Android devices to silently change the lock screen
/// wallpaper without user interaction. It uses platform channels to communicate with
/// native Kotlin code that executes root commands and interfaces with the WallpaperManager API.
///
/// Architecture layers:
/// 1. Dart Frontend (this class) - User-facing API
/// 2. Platform Channel - Dart ↔ Kotlin communication via MethodChannel
/// 3. Android Native Service - Root privilege management and WallpaperManager integration
/// 4. Root Privilege Layer (Magisk/su) - System-level wallpaper modification
class DynamicLockScreenService {
  const DynamicLockScreenService();

  // ── Platform Channels ────────────────────────────────────────────────
  // These match the channel names defined in MainActivity.kt

  /// Root privilege management channel
  static const _rootChannel = MethodChannel('com.versewall.bible/root');

  /// Wallpaper management channel (reuses existing channel for compatibility)
  static const _wallpaperChannel = MethodChannel('com.versewall.bible/wallpaper');

  /// Lock screen listener channel
  static const _lockscreenChannel = MethodChannel('com.versewall.bible/lockscreen');

  /// Dynamic lock screen channel (new)
  static const _dynamicLockChannel =
      MethodChannel('com.versewall.bible/dynamic_lock');

  // ── Public API ───────────────────────────────────────────────────────

  /// Checks if the device is rooted and the app has been granted root access.
  ///
  /// Returns true if:
  /// - Device has a rooted environment (su binary available)
  /// - App has been granted superuser privileges
  ///
  /// This check involves executing a test command via the su binary, which may
  /// prompt the user to grant superuser access if this is the first time.
  static Future<bool> checkRootAccess() async {
    try {
      final bool? hasRoot = await _rootChannel.invokeMethod<bool>('isRooted');
      return hasRoot ?? false;
    } on PlatformException catch (e) {
      debugPrint('Root check failed: ${e.message}');
      return false;
    }
  }

  /// Explicitly requests root permission from the user (e.g., via Magisk/SuperSU).
  ///
  /// This method will trigger the system's superuser permission dialog (if available).
  /// The user must approve the request for the app to proceed with privileged operations.
  ///
  /// Returns true if the user granted root access, false otherwise.
  static Future<bool> requestRootAccess() async {
    try {
      final bool? granted =
          await _rootChannel.invokeMethod<bool>('requestRoot');
      return granted ?? false;
    } on PlatformException catch (e) {
      debugPrint('Root request failed: ${e.message}');
      return false;
    }
  }

  /// Sets the lock screen wallpaper from a file path.
  ///
  /// With root access, this method:
  /// 1. Reads the image file
  /// 2. Streams it through the WallpaperManager API
  /// 3. Applies it to the lock screen using FLAG_LOCK flag
  ///
  /// The FLAG_LOCK flag (available since Android 7.0 / API 24) ensures that the
  /// wallpaper is applied to the lock screen specifically, bypassing restrictions
  /// that would otherwise require the app to be a system app.
  ///
  /// Parameters:
  /// - [imagePath]: Absolute path to the image file (PNG or JPG recommended)
  /// - [target]: Where to apply the wallpaper: 'lock', 'home', or 'both'
  ///
  /// Returns true if successful, false if the operation failed.
  static Future<bool> setLockScreenWallpaper(
    String imagePath, {
    String target = 'lock',
  }) async {
    try {
      final bool? success = await _dynamicLockChannel.invokeMethod<bool>(
        'setLockScreenWallpaper',
        {
          'imagePath': imagePath,
          'target': target,
        },
      );
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Wallpaper set failed: ${e.message}');
      return false;
    }
  }

  /// Sets the lock screen wallpaper from image bytes.
  ///
  /// This is an alternative to [setLockScreenWallpaper] when you have the image
  /// as raw bytes rather than a file path. Useful for on-the-fly image generation
  /// or downloaded images that haven't been saved to disk yet.
  ///
  /// Parameters:
  /// - [bytes]: The image data (PNG or JPG)
  /// - [target]: Where to apply the wallpaper: 'lock', 'home', or 'both'
  ///
  /// Returns true if successful, false if the operation failed.
  static Future<bool> setLockScreenWallpaperFromBytes(
    Uint8List bytes, {
    String target = 'lock',
  }) async {
    try {
      // Reuse the existing wallpaper channel which already supports bytes
      await _wallpaperChannel.invokeMethod<void>('setWallpaper', {
        'bytes': bytes,
        'target': target,
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint('Wallpaper set from bytes failed: ${e.message}');
      return false;
    }
  }

  /// Schedules periodic wallpaper updates (background task).
  ///
  /// This method sets up a background job that will:
  /// 1. Run periodically at the specified interval
  /// 2. Execute with constraints (e.g., when connected to network)
  /// 3. Persist across device restarts
  ///
  /// The actual wallpaper update logic must be implemented in a native
  /// WorkManager Worker class (WallpaperWorker.kt).
  ///
  /// Parameters:
  /// - [intervalMinutes]: How often to update the wallpaper (minimum 15 minutes)
  /// - [requiresNetwork]: If true, only run when device has internet connectivity
  /// - [requiresCharging]: If true, only run when device is charging
  /// - [requiresBatteryNotLow]: If true, only run when battery is not critically low
  ///
  /// Example:
  /// ```dart
  /// // Update wallpaper every 2 hours (120 minutes) with network connectivity
  /// await DynamicLockScreenService.startAutoChange(
  ///   intervalMinutes: 120,
  ///   requiresNetwork: true,
  /// );
  /// ```
  static Future<void> startAutoChange({
    required int intervalMinutes,
    bool requiresNetwork = false,
    bool requiresCharging = false,
    bool requiresBatteryNotLow = false,
  }) async {
    try {
      await _dynamicLockChannel.invokeMethod<void>(
        'startAutoChange',
        {
          'intervalMinutes': intervalMinutes,
          'requiresNetwork': requiresNetwork,
          'requiresCharging': requiresCharging,
          'requiresBatteryNotLow': requiresBatteryNotLow,
        },
      );
    } on PlatformException catch (e) {
      debugPrint('Auto change start failed: ${e.message}');
    }
  }

  /// Stops the scheduled wallpaper update background job.
  ///
  /// This cancels any ongoing or scheduled wallpaper updates. The background
  /// job will no longer run until [startAutoChange] is called again.
  static Future<void> stopAutoChange() async {
    try {
      await _dynamicLockChannel.invokeMethod<void>('stopAutoChange');
    } on PlatformException catch (e) {
      debugPrint('Auto change stop failed: ${e.message}');
    }
  }

  /// Checks if automatic wallpaper updates are currently running.
  ///
  /// Returns true if a background update job is scheduled or running, false otherwise.
  static Future<bool> isAutoChangeRunning() async {
    try {
      final bool? running =
          await _dynamicLockChannel.invokeMethod<bool>('isAutoChangeRunning');
      return running ?? false;
    } on PlatformException catch (e) {
      debugPrint('Auto change check failed: ${e.message}');
      return false;
    }
  }

  /// Registers a listener for lock screen events (screen on/off, unlock).
  ///
  /// This starts a BroadcastReceiver that monitors system events:
  /// - ACTION_SCREEN_ON: Screen turned on
  /// - ACTION_SCREEN_OFF: Screen turned off (ready to show lock screen)
  /// - ACTION_USER_PRESENT: Device unlocked by user
  ///
  /// Use this to trigger immediate wallpaper changes at specific moments,
  /// e.g., changing the wallpaper when the device is locked.
  static Future<void> startLockScreenListener() async {
    try {
      await _lockscreenChannel.invokeMethod<void>('startLockScreenListener');
    } on PlatformException catch (e) {
      debugPrint('Lock screen listener start failed: ${e.message}');
    }
  }

  /// Unregisters the lock screen event listener.
  ///
  /// This stops monitoring lock screen events and frees up resources.
  /// Call this when you no longer need immediate event-based updates.
  static Future<void> stopLockScreenListener() async {
    try {
      await _lockscreenChannel.invokeMethod<void>('stopLockScreenListener');
    } on PlatformException catch (e) {
      debugPrint('Lock screen listener stop failed: ${e.message}');
    }
  }

  /// Executes an arbitrary shell command with superuser privileges.
  ///
  /// **Use with caution!** This method executes raw shell commands as root.
  /// Only use this for advanced scenarios where you need direct system access
  /// beyond what the high-level APIs provide.
  ///
  /// Example commands:
  /// ```dart
  /// // Change file permissions
  /// await DynamicLockScreenService.execSuCommand(
  ///   'chmod 644 /data/system/wallpaper_info.xml'
  /// );
  ///
  /// // Copy a file to a system directory
  /// await DynamicLockScreenService.execSuCommand(
  ///   'cp /data/data/com.versewall.bible/wallpaper.png /data/system/wallpaper.png'
  /// );
  /// ```
  ///
  /// Parameters:
  /// - [command]: The shell command to execute (without 'su' prefix)
  ///
  /// Returns true if the command succeeded, false otherwise.
  static Future<bool> execSuCommand(String command) async {
    try {
      final bool? success = await _rootChannel.invokeMethod<bool>(
        'execSuCommand',
        {'command': command},
      );
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Su command failed: ${e.message}');
      return false;
    }
  }

  // ── Helper Methods ───────────────────────────────────────────────────

  /// Convenience method: sets wallpaper only if device is rooted.
  ///
  /// This wraps [setLockScreenWallpaper] with an upfront root check, useful
  /// for preventing unnecessary errors when root is unavailable.
  ///
  /// Returns the result of [setLockScreenWallpaper] if rooted, false otherwise.
  static Future<bool> setIfRooted(
    String imagePath, {
    String target = 'lock',
  }) async {
    final rooted = await checkRootAccess();
    if (!rooted) {
      debugPrint('Device is not rooted. Wallpaper change skipped.');
      return false;
    }
    return setLockScreenWallpaper(imagePath, target: target);
  }

  /// Gets a human-readable description of the root and wallpaper capabilities.
  ///
  /// Useful for debugging and status displays. Checks:
  /// - Whether the device is rooted
  /// - Whether the app has been granted root access
  /// - Whether wallpaper operations are available
  static Future<String> getCapabilities() async {
    final rooted = await checkRootAccess();
    final autoRunning = await isAutoChangeRunning();

    return '''
Root Access: ${rooted ? 'Enabled' : 'Disabled'}
Auto Updates: ${autoRunning ? 'Running' : 'Stopped'}
Platform: Android
API Support: WallpaperManager.FLAG_LOCK (API 24+)
    ''';
  }
}
