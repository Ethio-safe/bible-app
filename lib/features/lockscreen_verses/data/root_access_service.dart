import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RootAccessService {
  static const _channel = MethodChannel('com.versewall.bible/root');

  static bool get supported => !kIsWeb && Platform.isAndroid;

  /// Checks if device is rooted
  static Future<bool> isRooted() async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>('isRooted') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Requests root access (prompts user)
  static Future<bool> requestRoot() async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>('requestRoot') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Executes a command with root privileges
  static Future<bool> execCommand(String command) async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>(
        'execSuCommand',
        {'command': command},
      ) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Sets wallpaper using root with proper permissions
  /// This allows bypassing some system restrictions
  static Future<bool> setWallpaperAsRoot({
    required String imagePath,
    required String target, // 'lock', 'home', 'both'
  }) async {
    if (!supported) return false;
    
    final isRoot = await isRooted();
    if (!isRoot) {
      return false;
    }

    try {
      final cmd = 'cmd wallpaper set --user 0 $imagePath';
      return await execCommand(cmd);
    } catch (e) {
      return false;
    }
  }
}
