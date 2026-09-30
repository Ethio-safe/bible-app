import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/preferences_provider.dart';
import 'asset_db_installer.dart';
import 'user_database.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AssetDbInstaller assetDbInstaller(Ref ref) {
  return AssetDbInstaller(ref.watch(sharedPreferencesProvider));
}

/// Resolves once the bundled Bible DBs are guaranteed to be on disk.
@Riverpod(keepAlive: true)
Future<Directory> bibleDbDirectory(Ref ref) {
  return ref.watch(assetDbInstallerProvider).ensureInstalled();
}

@Riverpod(keepAlive: true)
UserDatabase userDatabase(Ref ref) {
  final db = UserDatabase();
  ref.onDispose(db.close);
  return db;
}
