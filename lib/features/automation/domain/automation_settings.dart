import 'package:shared_preferences/shared_preferences.dart';

import '../../wallpaper/data/wallpaper_applier.dart';

enum RotationInterval {
  hourly(Duration(hours: 1), 'Every hour'),
  sixHours(Duration(hours: 6), 'Every 6 hours'),
  twelveHours(Duration(hours: 12), 'Every 12 hours'),
  daily(Duration(hours: 24), 'Daily');

  const RotationInterval(this.duration, this.label);
  final Duration duration;
  final String label;
}

enum ImageCategory {
  nature('Nature', 'nature landscape'),
  sky('Sky & stars', 'night sky stars'),
  mountains('Mountains', 'mountains'),
  ocean('Ocean', 'ocean sea'),
  forest('Forest', 'forest trees'),
  minimal('Minimal', 'minimal abstract gradient'),
  flowers('Flowers', 'flowers macro');

  const ImageCategory(this.label, this.query);
  final String label;
  final String query;
}

/// Plain settings object; serialisable to/from [SharedPreferences] so both the
/// UI isolate and the WorkManager background isolate read the same values.
class AutomationSettings {
  const AutomationSettings({
    this.enabled = false,
    this.interval = RotationInterval.sixHours,
    this.target = WallpaperTarget.lock,
    this.category = ImageCategory.nature,
    this.wifiOnly = true,
    this.remoteEnabled = true,
    this.poolSize = 30,
    this.templateName,
    this.excludeLast = 8,
    this.liveMode = false,
  });

  final bool enabled;
  final RotationInterval interval;
  final WallpaperTarget target;
  final ImageCategory category;
  final bool wifiOnly;
  final bool remoteEnabled;

  /// Max images kept in the pool (favorites don't count toward eviction).
  final int poolSize;

  /// Fixed template name, or null for "vary".
  final String? templateName;

  /// Don't repeat any image/verse used in the last N rotations.
  final int excludeLast;

  /// When true the app acts as a live wallpaper that shows a new verse every
  /// time the screen is locked. Background jobs then only pre-render the image
  /// set instead of calling `WallpaperManager.setBitmap` (which would replace
  /// the live wallpaper).
  final bool liveMode;

  /// Number of wallpapers pre-rendered for live mode.
  static const liveSetSize = 12;

  static const poolSizeOptions = [15, 30, 50];
  static const maxPoolBytes = 15 * 1024 * 1024;

  AutomationSettings copyWith({
    bool? enabled,
    RotationInterval? interval,
    WallpaperTarget? target,
    ImageCategory? category,
    bool? wifiOnly,
    bool? remoteEnabled,
    int? poolSize,
    Object? templateName = _sentinel,
    int? excludeLast,
    bool? liveMode,
  }) => AutomationSettings(
    enabled: enabled ?? this.enabled,
    interval: interval ?? this.interval,
    target: target ?? this.target,
    category: category ?? this.category,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    remoteEnabled: remoteEnabled ?? this.remoteEnabled,
    poolSize: poolSize ?? this.poolSize,
    templateName: templateName == _sentinel
        ? this.templateName
        : templateName as String?,
    excludeLast: excludeLast ?? this.excludeLast,
    liveMode: liveMode ?? this.liveMode,
  );

  static const _sentinel = Object();

  // ── Persistence ───────────────────────────────────────────────────────────

  static const _p = 'auto_';

  static AutomationSettings read(SharedPreferences prefs) {
    T pick<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    const d = AutomationSettings();
    return AutomationSettings(
      enabled: prefs.getBool('${_p}enabled') ?? d.enabled,
      interval: pick(
        RotationInterval.values,
        prefs.getString('${_p}interval'),
        d.interval,
      ),
      target: pick(
        WallpaperTarget.values,
        prefs.getString('${_p}target'),
        d.target,
      ),
      category: pick(
        ImageCategory.values,
        prefs.getString('${_p}category'),
        d.category,
      ),
      wifiOnly: prefs.getBool('${_p}wifi_only') ?? d.wifiOnly,
      remoteEnabled: prefs.getBool('${_p}remote') ?? d.remoteEnabled,
      poolSize: prefs.getInt('${_p}pool_size') ?? d.poolSize,
      templateName: prefs.getString('${_p}template'),
      excludeLast: prefs.getInt('${_p}exclude_last') ?? d.excludeLast,
      liveMode: prefs.getBool('${_p}live_mode') ?? d.liveMode,
    );
  }

  Future<void> write(SharedPreferences prefs) async {
    await prefs.setBool('${_p}enabled', enabled);
    await prefs.setString('${_p}interval', interval.name);
    await prefs.setString('${_p}target', target.name);
    await prefs.setString('${_p}category', category.name);
    await prefs.setBool('${_p}wifi_only', wifiOnly);
    await prefs.setBool('${_p}remote', remoteEnabled);
    await prefs.setInt('${_p}pool_size', poolSize);
    if (templateName == null) {
      await prefs.remove('${_p}template');
    } else {
      await prefs.setString('${_p}template', templateName!);
    }
    await prefs.setInt('${_p}exclude_last', excludeLast);
    await prefs.setBool('${_p}live_mode', liveMode);
  }
}
