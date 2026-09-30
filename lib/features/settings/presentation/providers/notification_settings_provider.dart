import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/storage/preferences_provider.dart';
import '../../../votd/presentation/providers/votd_providers.dart';

part 'notification_settings_provider.g.dart';

class NotificationSettings {
  const NotificationSettings({required this.enabled, required this.time});

  final bool enabled;
  final TimeOfDay time;

  NotificationSettings copyWith({bool? enabled, TimeOfDay? time}) =>
      NotificationSettings(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );
}

@Riverpod(keepAlive: true)
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  static const _kEnabled = 'votd_notif_enabled';
  static const _kHour = 'votd_notif_hour';
  static const _kMinute = 'votd_notif_minute';

  @override
  NotificationSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationSettings(
      enabled: prefs.getBool(_kEnabled) ?? false,
      time: TimeOfDay(
        hour: prefs.getInt(_kHour) ?? 8,
        minute: prefs.getInt(_kMinute) ?? 0,
      ),
    );
  }

  /// Returns false if the OS denied permission.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final ok = await NotificationService.instance.requestPermission();
      if (!ok) return false;
    }
    state = state.copyWith(enabled: enabled);
    await ref.read(sharedPreferencesProvider).setBool(_kEnabled, enabled);
    await ref.read(votdSchedulerProvider).sync();
    return true;
  }

  Future<void> setTime(TimeOfDay time) async {
    state = state.copyWith(time: time);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_kHour, time.hour);
    await prefs.setInt(_kMinute, time.minute);
    await ref.read(votdSchedulerProvider).sync();
  }
}

/// Keeps the OS-scheduled notifications in step with settings: schedules the
/// next [NotificationService.votdDaysAhead] days individually (each with its
/// own verse), so the correct verse fires every day even if the app isn't
/// reopened in between. Call [sync] on app start and whenever settings or
/// translation change.
class VotdScheduler {
  VotdScheduler(this._ref);
  final Ref _ref;

  Future<void> sync() async {
    final settings = _ref.read(notificationSettingsNotifierProvider);
    final service = NotificationService.instance;
    if (!settings.enabled) {
      await service.cancelDaily();
      return;
    }
    final now = DateTime.now();
    final todayFire = DateTime(
      now.year,
      now.month,
      now.day,
      settings.time.hour,
      settings.time.minute,
    );
    final firstDay = todayFire.isAfter(now)
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    final entries = <({DateTime fireAt, String title, String body})>[];
    for (var i = 0; i < NotificationService.votdDaysAhead; i++) {
      final day = firstDay.add(Duration(days: i));
      final fireAt = DateTime(
        day.year,
        day.month,
        day.day,
        settings.time.hour,
        settings.time.minute,
      );
      final verse = await _ref.read(
        resolvePoolVerseProvider(verseForDate(day)).future,
      );
      entries.add((
        fireAt: fireAt,
        title: 'Verse of the Day · ${verse.reference}',
        body: verse.text,
      ));
    }
    await service.scheduleUpcoming(entries);
  }

  Future<void> sendTest() async {
    final verse = await _ref.read(verseOfTheDayProvider.future);
    await NotificationService.instance.showNow(
      title: 'Verse of the Day · ${verse.reference}',
      body: verse.text,
    );
  }
}

@Riverpod(keepAlive: true)
VotdScheduler votdScheduler(Ref ref) => VotdScheduler(ref);
