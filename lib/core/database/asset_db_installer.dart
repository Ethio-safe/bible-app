import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bundled_bibles.dart';

/// Copies the read-only Bible databases from the asset bundle into the app's
/// support directory (Drift/sqlite3 cannot open files directly from assets).
///
/// Databases are re-copied when [BundledBibles.bundledDbVersion] is bumped or
/// when a file is missing.
class AssetDbInstaller {
  AssetDbInstaller(this._prefs);

  final SharedPreferences _prefs;

  static const _versionKey = 'bible_db_installed_version';

  /// Directory that holds `<key>.db` for every bundled translation.
  Future<Directory> bibleDirectory() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'bible'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Absolute path of the installed database for [translationKey].
  Future<String> pathFor(String translationKey) async {
    final dir = await bibleDirectory();
    return p.join(dir.path, BundledBibles.files[translationKey]!);
  }

  /// Ensures all bundled databases exist on disk and are up to date.
  /// Returns the directory containing them.
  Future<Directory> ensureInstalled() async {
    if (kIsWeb) return Directory.current;
    final dir = await bibleDirectory();
    final installed = _prefs.getInt(_versionKey) ?? 0;
    final needsUpgrade = installed < BundledBibles.bundledDbVersion;

    for (final entry in BundledBibles.files.entries) {
      final target = File(p.join(dir.path, entry.value));
      if (needsUpgrade || !target.existsSync() || target.lengthSync() == 0) {
        await _copyAsset(BundledBibles.assetPath(entry.key), target);
      }
    }

    if (needsUpgrade) {
      await _prefs.setInt(_versionKey, BundledBibles.bundledDbVersion);
    }
    return dir;
  }

  Future<void> _copyAsset(String assetPath, File target) async {
    final data = await rootBundle.load(assetPath);
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    // Atomic replace so a crash mid-copy never leaves a corrupt DB behind.
    if (target.existsSync()) {
      await target.delete();
    }
    await tmp.rename(target.path);
  }
}
