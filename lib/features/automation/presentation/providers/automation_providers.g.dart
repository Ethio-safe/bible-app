// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rotationSchedulerHash() => r'723f7f028101abdb3901d6cfee9ac07716379944';

/// See also [rotationScheduler].
@ProviderFor(rotationScheduler)
final rotationSchedulerProvider = Provider<RotationScheduler>.internal(
  rotationScheduler,
  name: r'rotationSchedulerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rotationSchedulerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RotationSchedulerRef = ProviderRef<RotationScheduler>;
String _$liveWallpaperServiceHash() =>
    r'018bead1423c76a5813d4b7b05eefdb087dd13ed';

/// See also [liveWallpaperService].
@ProviderFor(liveWallpaperService)
final liveWallpaperServiceProvider = Provider<LiveWallpaperService>.internal(
  liveWallpaperService,
  name: r'liveWallpaperServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$liveWallpaperServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LiveWallpaperServiceRef = ProviderRef<LiveWallpaperService>;
String _$wallpaperHistoryHash() => r'699f301acc4ccca3072680e48f3a69bdc56f6d6a';

/// See also [wallpaperHistory].
@ProviderFor(wallpaperHistory)
final wallpaperHistoryProvider =
    AutoDisposeStreamProvider<List<WallpaperHistoryRow>>.internal(
      wallpaperHistory,
      name: r'wallpaperHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wallpaperHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WallpaperHistoryRef =
    AutoDisposeStreamProviderRef<List<WallpaperHistoryRow>>;
String _$poolStatsHash() => r'af2885bb23dd8d58d805147775d46d74d175a926';

/// See also [poolStats].
@ProviderFor(poolStats)
final poolStatsProvider =
    AutoDisposeFutureProvider<({int count, int bytes})>.internal(
      poolStats,
      name: r'poolStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$poolStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PoolStatsRef = AutoDisposeFutureProviderRef<({int count, int bytes})>;
String _$remoteConfiguredHash() => r'a193792db28902a3d7fe72837c021054b046fd79';

/// Whether at least one remote provider has an API key compiled in.
///
/// Copied from [remoteConfigured].
@ProviderFor(remoteConfigured)
final remoteConfiguredProvider = AutoDisposeProvider<bool>.internal(
  remoteConfigured,
  name: r'remoteConfiguredProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$remoteConfiguredHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemoteConfiguredRef = AutoDisposeProviderRef<bool>;
String _$rotationStatusHash() => r'8960d765a9c7f73ba4d322142ed732d98c87d29c';

/// Last successful run / last error recorded by the background job.
///
/// Copied from [rotationStatus].
@ProviderFor(rotationStatus)
final rotationStatusProvider =
    AutoDisposeProvider<({DateTime? lastRun, String? lastError})>.internal(
      rotationStatus,
      name: r'rotationStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rotationStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RotationStatusRef =
    AutoDisposeProviderRef<({DateTime? lastRun, String? lastError})>;
String _$automationSettingsNotifierHash() =>
    r'414ab863487a0b95529cd2f662acc42e04ba15a5';

/// See also [AutomationSettingsNotifier].
@ProviderFor(AutomationSettingsNotifier)
final automationSettingsNotifierProvider =
    NotifierProvider<AutomationSettingsNotifier, AutomationSettings>.internal(
      AutomationSettingsNotifier.new,
      name: r'automationSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$automationSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AutomationSettingsNotifier = Notifier<AutomationSettings>;
String _$liveWallpaperActiveHash() =>
    r'e5aecec1ef454589d9547bf1ad80027842370001';

/// Whether our live wallpaper is the system's current wallpaper. Re-checked
/// whenever the app returns to the foreground via [refresh].
///
/// Copied from [LiveWallpaperActive].
@ProviderFor(LiveWallpaperActive)
final liveWallpaperActiveProvider =
    AsyncNotifierProvider<LiveWallpaperActive, bool>.internal(
      LiveWallpaperActive.new,
      name: r'liveWallpaperActiveProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$liveWallpaperActiveHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LiveWallpaperActive = AsyncNotifier<bool>;
String _$liveWallpaperSetupHash() =>
    r'c404cf5614751f0c37f4dd705fa1f951c1d20956';

/// Renders the wallpaper set and starts the lock-screen rotation service so a
/// new verse appears every time the phone is locked. Optionally also opens the
/// system chooser to install the live wallpaper for the home screen.
///
/// Copied from [LiveWallpaperSetup].
@ProviderFor(LiveWallpaperSetup)
final liveWallpaperSetupProvider =
    AutoDisposeAsyncNotifierProvider<LiveWallpaperSetup, int?>.internal(
      LiveWallpaperSetup.new,
      name: r'liveWallpaperSetupProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$liveWallpaperSetupHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LiveWallpaperSetup = AutoDisposeAsyncNotifier<int?>;
String _$refreshNowControllerHash() =>
    r'f6f69a712bbe4a21fcaab2f8a4dd6c5f1de0b076';

/// Foreground "Refresh now": runs the same use case the background job runs,
/// but with live providers so the UI updates immediately.
///
/// Copied from [RefreshNowController].
@ProviderFor(RefreshNowController)
final refreshNowControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      RefreshNowController,
      RotationResult?
    >.internal(
      RefreshNowController.new,
      name: r'refreshNowControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$refreshNowControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RefreshNowController = AutoDisposeAsyncNotifier<RotationResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
