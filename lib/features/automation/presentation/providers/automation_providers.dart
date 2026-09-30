import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/database/user_database.dart';
import '../../../../core/storage/preferences_provider.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../wallpaper/data/remote_image_source.dart';
import '../../../wallpaper/data/wallpaper_applier.dart';
import '../../../wallpaper/presentation/providers/wallpaper_providers.dart';
import '../../../widgets/home_widget_service.dart';
import '../../data/live_wallpaper_service.dart';
import '../../data/rotation_scheduler.dart';
import '../../domain/automation_settings.dart';
import '../../domain/rotate_wallpaper_use_case.dart';

part 'automation_providers.g.dart';

@Riverpod(keepAlive: true)
RotationScheduler rotationScheduler(Ref ref) => const RotationScheduler();

@Riverpod(keepAlive: true)
class AutomationSettingsNotifier extends _$AutomationSettingsNotifier {
  @override
  AutomationSettings build() =>
      AutomationSettings.read(ref.watch(sharedPreferencesProvider));

  Future<void> update(AutomationSettings next) async {
    state = next;
    await next.write(ref.read(sharedPreferencesProvider));
    if (!kIsWeb && Platform.isAndroid) {
      await ref.read(rotationSchedulerProvider).sync(next);
    }
  }

  Future<void> setEnabled(bool v) => update(state.copyWith(enabled: v));
  Future<void> setInterval(RotationInterval v) =>
      update(state.copyWith(interval: v));
  Future<void> setTarget(WallpaperTarget v) =>
      update(state.copyWith(target: v));
  Future<void> setCategory(ImageCategory v) =>
      update(state.copyWith(category: v));
  Future<void> setWifiOnly(bool v) => update(state.copyWith(wifiOnly: v));
  Future<void> setRemoteEnabled(bool v) =>
      update(state.copyWith(remoteEnabled: v));
  Future<void> setPoolSize(int v) => update(state.copyWith(poolSize: v));
  Future<void> setTemplate(String? v) =>
      update(state.copyWith(templateName: v));
  Future<void> setLiveMode(bool v) => update(state.copyWith(liveMode: v));
}

@Riverpod(keepAlive: true)
LiveWallpaperService liveWallpaperService(Ref ref) =>
    const LiveWallpaperService();

/// Whether our live wallpaper is the system's current wallpaper. Re-checked
/// whenever the app returns to the foreground via [refresh].
@Riverpod(keepAlive: true)
class LiveWallpaperActive extends _$LiveWallpaperActive {
  @override
  Future<bool> build() => ref.watch(liveWallpaperServiceProvider).isActive();

  Future<void> refresh() async {
    state = AsyncData(await ref.read(liveWallpaperServiceProvider).isActive());
  }
}

/// Renders the wallpaper set and starts the lock-screen rotation service so a
/// new verse appears every time the phone is locked. Optionally also opens the
/// system chooser to install the live wallpaper for the home screen.
@riverpod
class LiveWallpaperSetup extends _$LiveWallpaperSetup {
  @override
  FutureOr<int?> build() => null;

  /// Returns the number of wallpapers rendered.
  Future<void> prepare(Size physicalSize, {bool openChooser = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final live = ref.read(liveWallpaperServiceProvider);
      final settings = ref.read(automationSettingsNotifierProvider);
      final useCase = await _buildUseCase(ref);
      final n = await useCase.renderBatch(
        size: physicalSize,
        outputDir: await live.directory(),
      );
      await live.refresh();
      await ref
          .read(automationSettingsNotifierProvider.notifier)
          .setLiveMode(true);
      await live.startLockRotation(target: settings.target.name);
      if (openChooser) await live.openChooser();
      return n;
    });
  }

  Future<void> disable() async {
    final live = ref.read(liveWallpaperServiceProvider);
    await live.stopLockRotation();
    await ref
        .read(automationSettingsNotifierProvider.notifier)
        .setLiveMode(false);
    state = const AsyncData(null);
  }
}

Future<RotateWallpaperUseCase> _buildUseCase(Ref ref) async {
  final settings = ref.read(automationSettingsNotifierProvider);
  final bibleDb = await ref.read(currentBibleDatabaseProvider.future);
  final translation = await ref.read(currentTranslationProvider.future);
  final pool = await ref.read(wallpaperPoolProvider.future);
  return RotateWallpaperUseCase(
    userDb: ref.read(userDatabaseProvider),
    bibleDb: bibleDb,
    translationAbbreviation: translation.abbreviation,
    pool: pool,
    applier: ref.read(wallpaperApplierProvider),
    composer: ref.read(wallpaperComposerProvider),
    settings: settings,
    remote: CompositeImageSource([UnsplashSource(), PexelsSource()]),
    connectivity: Connectivity(),
  );
}

@riverpod
Stream<List<WallpaperHistoryRow>> wallpaperHistory(Ref ref) =>
    ref.watch(userDatabaseProvider).watchWallpaperHistory(limit: 30);

@riverpod
Future<({int count, int bytes})> poolStats(Ref ref) async {
  ref.watch(wallpaperHistoryProvider); // refresh after each rotation
  final pool = await ref.watch(wallpaperPoolProvider.future);
  return pool.stats();
}

/// Whether at least one remote provider has an API key compiled in.
@riverpod
bool remoteConfigured(Ref ref) =>
    UnsplashSource().isConfigured || PexelsSource().isConfigured;

/// Last successful run / last error recorded by the background job.
@riverpod
({DateTime? lastRun, String? lastError}) rotationStatus(Ref ref) {
  ref.watch(wallpaperHistoryProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final raw = prefs.getString(RotationTasks.prefLastRun);
  return (
    lastRun: raw == null ? null : DateTime.tryParse(raw),
    lastError: prefs.getString(RotationTasks.prefLastError),
  );
}

/// Foreground "Refresh now": runs the same use case the background job runs,
/// but with live providers so the UI updates immediately.
@riverpod
class RefreshNowController extends _$RefreshNowController {
  @override
  FutureOr<RotationResult?> build() => null;

  Future<void> run(Size physicalSize) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = ref.read(automationSettingsNotifierProvider);
      final bibleDb = await ref.read(currentBibleDatabaseProvider.future);
      final translation = await ref.read(currentTranslationProvider.future);
      final useCase = await _buildUseCase(ref);
      final result = await useCase.run(size: physicalSize, trigger: 'manual');
      if (settings.liveMode && LiveWallpaperService.supported) {
        final live = ref.read(liveWallpaperServiceProvider);
        await useCase.renderBatch(
          size: physicalSize,
          outputDir: await live.directory(),
        );
        await live.refresh();
      }
      await ref
          .read(sharedPreferencesProvider)
          .setString(
            RotationTasks.prefLastRun,
            DateTime.now().toIso8601String(),
          );
      await HomeWidgetService.publish(
        bibleDb: bibleDb,
        verse: result.verse,
        translation: translation.abbreviation,
        imagePath: result.image.path,
      );
      ref.invalidate(poolStatsProvider);
      return result;
    });
  }
}
