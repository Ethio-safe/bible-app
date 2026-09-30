import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LockScreenService {
  static const _channel = MethodChannel('com.versewall.bible/lockscreen');

  static bool get supported => !kIsWeb && Platform.isAndroid;

  /// Starts listening to lock/unlock events
  static Future<void> startListener() async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>('startLockScreenListener');
    } catch (e) {
      print('Failed to start lock screen listener: $e');
    }
  }

  /// Stops listening to lock/unlock events
  static Future<void> stopListener() async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>('stopLockScreenListener');
    } catch (e) {
      print('Failed to stop lock screen listener: $e');
    }
  }

  /// Set up a method call handler for lock screen events
  static void setEventHandler(Function(String event) onEvent) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLockscreenEvent') {
        final event = call.arguments as String?;
        if (event != null) {
          onEvent(event);
        }
      }
    });
  }
}
