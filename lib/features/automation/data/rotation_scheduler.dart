import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/database/asset_db_installer.dart';
import '../../../core/database/bible_database.dart';
import '../../../core/database/bundled_bibles.dart';
import '../../../core/database/user_database.dart';
import '../../wallpaper/data/remote_image_source.dart';
import '../../wallpaper/data/wallpaper_applier.dart';
import '../../wallpaper/data/wallpaper_pool_manager.dart';
import '../../wallpaper/domain/wallpaper_composer.dart';
import '../../widgets/home_widget_service.dart';
import '../domain/automation_settings.dart';
import '../domain/rotate_wallpaper_use_case.dart';
import 'live_wallpaper_service.dart';

/// Names shared between the scheduler and the background dispatcher.
class RotationTasks {
  static const periodicUnique = 'bible.rotate.periodic';
  static const oneOffUnique = 'bible.rotate.now';
  static const taskName = 'rotateWallpaper';
  static const prefLastRun = 'auto_last_run';
  static const prefLastError = 'auto_last_error';
  static const prefScreenW = 'auto_screen_w';
  static const prefScreenH = 'auto_screen_h';
}

/// Entry point executed by WorkManager in a headless background isolate.
/// Must be a top-level function annotated with `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
void rotationDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != RotationTasks.taskName &&
        taskName != Workmanager.iOSBackgroundTask) {
      return true;
    }
    try {
      await runRotationHeadless(trigger: 'auto');
      return true;
    } catch (e, st) {
      debugPrint('rotation failed: $e\n$st');
      return false; // WorkManager applies backoff and retries.
    }
  });
}

/// Builds every collaborator from scratch (no Riverpod in the background
/// isolate) and performs one rotation.
Future<RotationResult> runRotationHeadless({required String trigger}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final settings = AutomationSettings.read(prefs);

  final savedKey = prefs.getString('current_translation');
  final translationKey = BundledBibles.files.containsKey(savedKey)
      ? savedKey!
      : BundledBibles.defaultTranslation;
  final dir = await AssetDbInstaller(prefs).ensureInstalled();
  final bibleDb = BibleDatabase.open(
    p.join(dir.path, BundledBibles.files[translationKey]!),
  );
  final userDb = UserDatabase();

  try {
    final meta = await bibleDb.readMeta();
    final abbreviation = meta['abbreviation'] ?? translationKey.toUpperCase();
    final docs = await getApplicationDocumentsDirectory();
    final pool = WallpaperPoolManager(db: userDb, documentsDir: docs);
    await pool.seedPool();

    final size = _screenSize(prefs);
    final useCase = RotateWallpaperUseCase(
      userDb: userDb,
      bibleDb: bibleDb,
      translationAbbreviation: abbreviation,
      pool: pool,
      applier: WallpaperApplier.forPlatform(),
      composer: const WallpaperComposer(),
      settings: settings,
      remote: CompositeImageSource([UnsplashSource(), PexelsSource()]),
      connectivity: Connectivity(),
    );
    final result = await useCase.run(size: size, trigger: trigger);

    // Live mode: refresh the set the lock-screen engine cycles through.
    if (settings.liveMode && LiveWallpaperService.supported) {
      const live = LiveWallpaperService();
      await useCase.renderBatch(size: size, outputDir: await live.directory());
      await live.refresh();
    }

    await prefs.setString(
      RotationTasks.prefLastRun,
      DateTime.now().toIso8601String(),
    );
    await prefs.remove(RotationTasks.prefLastError);

    // Keep the iOS/Android home-screen widget in step with the wallpaper.
    await HomeWidgetService.publish(
      bibleDb: bibleDb,
      verse: result.verse,
      translation: abbreviation,
      imagePath: result.image.path,
    );
    return result;
  } catch (e) {
    await prefs.setString(RotationTasks.prefLastError, '$e');
    rethrow;
  } finally {
    await bibleDb.close();
    await userDb.close();
  }
}

/// Physical screen size recorded by the UI on every launch, so the headless
/// isolate (which has no window) can render at native resolution.
ui.Size _screenSize(SharedPreferences prefs) {
  final w = prefs.getDouble(RotationTasks.prefScreenW);
  final h = prefs.getDouble(RotationTasks.prefScreenH);
  if (w != null && h != null && w > 0 && h > 0) return ui.Size(w, h);
  return const ui.Size(1080, 1920);
}

/// Foreground helper: call once at startup with a [BuildContext].
Future<void> rememberScreenSize(BuildContext context) async {
  final size = View.of(context).physicalSize;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(RotationTasks.prefScreenW, size.width);
  await prefs.setDouble(RotationTasks.prefScreenH, size.height);
}

/// Schedules / cancels the periodic job to match [settings].
class RotationScheduler {
  const RotationScheduler();

  Future<void> initialize() => Workmanager().initialize(rotationDispatcher);

  Future<void> sync(AutomationSettings settings) async {
    if (!settings.enabled) {
      await Workmanager().cancelByUniqueName(RotationTasks.periodicUnique);
      return;
    }
    await Workmanager().registerPeriodicTask(
      RotationTasks.periodicUnique,
      RotationTasks.taskName,
      frequency: settings.interval.duration,
      flexInterval: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
      constraints: Constraints(
        // Rotation itself works offline; the network preference only gates
        // remote fetching inside the use case.
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      ),
    );
  }

  /// Runs one rotation ASAP in the background (survives app close).
  Future<void> runOnce() => Workmanager().registerOneOffTask(
    RotationTasks.oneOffUnique,
    RotationTasks.taskName,
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}
