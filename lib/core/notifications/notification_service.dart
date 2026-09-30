import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper over flutter_local_notifications for the daily
/// Verse-of-the-Day reminder.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  static const votdNotificationId = 1001;
  static const votdChannelId = 'votd_daily';
  static const votdPayload = 'votd';

  /// How many individual days ahead we keep scheduled. Each day gets its own
  /// notification (rather than one OS-level daily repeat) so the verse text
  /// is always correct even if the app isn't opened in between.
  static const votdDaysAhead = 14;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Set by [initialize]; invoked when the user taps a notification.
  void Function(String? payload)? onTap;

  /// Payload of the notification that launched the app (cold start), if any.
  String? launchPayload;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (kIsWeb) return;

    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (r) => onTap?.call(r.payload),
    );

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      launchPayload = launch!.notificationResponse?.payload;
    }
  }

  /// Returns true if notifications may be shown.
  Future<bool> requestPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await impl?.requestNotificationsPermission();
      return granted ?? true;
    }
    if (Platform.isIOS) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await impl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Schedules one distinct notification per entry — each with its own
  /// verse text — instead of a single OS-level daily repeat whose body would
  /// go stale until the app is reopened. Cancels any previously scheduled
  /// VOTD notifications first. Entries whose [fireAt] is already in the past
  /// are skipped.
  Future<void> scheduleUpcoming(
    List<({DateTime fireAt, String title, String body})> entries,
  ) async {
    await initialize();
    await cancelDaily();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        votdChannelId,
        'Verse of the Day',
        channelDescription: 'A daily Bible verse reminder',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    var id = votdNotificationId;
    for (final entry in entries.take(votdDaysAhead)) {
      final when = tz.TZDateTime(
        tz.local,
        entry.fireAt.year,
        entry.fireAt.month,
        entry.fireAt.day,
        entry.fireAt.hour,
        entry.fireAt.minute,
      );
      if (!when.isAfter(now)) {
        id++;
        continue;
      }
      await _plugin.zonedSchedule(
        id,
        entry.title,
        entry.body,
        when,
        details,
        payload: votdPayload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      id++;
    }
  }

  Future<void> cancelDaily() async {
    await initialize();
    for (var i = 0; i < votdDaysAhead; i++) {
      await _plugin.cancel(votdNotificationId + i);
    }
  }

  Future<bool> isDailyScheduled() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any(
      (p) =>
          p.id >= votdNotificationId &&
          p.id < votdNotificationId + votdDaysAhead,
    );
  }

  /// Fires immediately — used by the settings "Send test" action.
  Future<void> showNow({required String title, required String body}) async {
    await initialize();
    await _plugin.show(
      votdNotificationId + 1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          votdChannelId,
          'Verse of the Day',
          channelDescription: 'A daily Bible verse reminder',
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: votdPayload,
    );
  }
}
