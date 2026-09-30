import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/preferences_provider.dart';
import 'features/automation/data/live_wallpaper_service.dart';
import 'features/automation/data/rotation_scheduler.dart';
import 'features/automation/domain/automation_settings.dart';
import 'features/automation/presentation/screens/automation_screen.dart';
import 'features/lockscreen_verses/data/root_access_service.dart';
import 'features/widgets/home_widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await NotificationService.instance.initialize();
  await HomeWidgetService.init();

  if (!kIsWeb && Platform.isAndroid) {
    const scheduler = RotationScheduler();
    await scheduler.initialize();
    // Re-assert the periodic job on every launch (survives reinstall/update).
    final settings = AutomationSettings.read(prefs);
    await scheduler.sync(settings);
    // Re-start the lock-screen rotation service if the OS stopped it.
    if (settings.liveMode) {
      await const LiveWallpaperService().startLockRotation(
        target: settings.target.name,
      );
    }

    // Request root once on startup so Magisk/SuperSU can show its prompt.
    if (!(prefs.getBool('root_prompted') ?? false)) {
      await prefs.setBool('root_prompted', true);
      await RootAccessService.requestRoot();
    }
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ScreenSizeRecorder(child: VerseBibleApp()),
    ),
  );
}
