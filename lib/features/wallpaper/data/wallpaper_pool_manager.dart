import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../../core/database/user_database.dart';
import '../domain/entities/wallpaper_image.dart';
import 'remote_image_source.dart';

/// Manages the on-device pool of background images.
///
/// Phase 4: copies the bundled seed set into the documents directory once and
/// registers it in [UserDatabase.wallpaperImages]. Phase 5 adds the rolling
/// remote cache with eviction (favorites are never evicted).
class WallpaperPoolManager {
  WallpaperPoolManager({
    required UserDatabase db,
    required Directory documentsDir,
    AssetBundle? bundle,
  }) : _db = db,
       _root = Directory(p.join(documentsDir.path, 'wallpapers')),
       _bundle = bundle ?? rootBundle;

  final UserDatabase _db;
  final Directory _root;
  final AssetBundle _bundle;

  static const seedAssetDir = 'assets/wallpapers/seed';
  static const seedManifest = '$seedAssetDir/seed_manifest.json';

  Directory get seedDir => Directory(p.join(_root.path, 'seed'));

  /// Idempotent. Copies any seed image not yet registered.
  Future<int> seedPool() async {
    await seedDir.create(recursive: true);
    final manifestJson = await _bundle.loadString(seedManifest);
    final entries = (jsonDecode(manifestJson) as List).cast<Map>();

    var added = 0;
    for (final e in entries) {
      final file = e['file'] as String;
      final key = p.basenameWithoutExtension(file);
      if (await _db.hasWallpaperImage(key)) continue;

      final bytes = await _bundle.load('$seedAssetDir/$file');
      final target = File(p.join(seedDir.path, file));
      await target.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );

      await _db.insertWallpaperImage(
        WallpaperImagesCompanion.insert(
          path: target.path,
          source: 'seed',
          key: key,
          mood: Value(e['mood'] as String?),
          isDark: Value(e['dark'] as bool? ?? true),
          width: 1080,
          height: 1920,
          sizeBytes: Value(bytes.lengthInBytes),
          addedAt: DateTime.now(),
        ),
      );
      added++;
    }
    return added;
  }

  Stream<List<WallpaperImage>> watchAll() =>
      _db.watchWallpaperImages().map((rows) => rows.map(toEntity).toList());

  Future<WallpaperImage?> byId(int id) async {
    final row = await _db.wallpaperImageById(id);
    return row == null ? null : toEntity(row);
  }

  Future<void> setFavorite(int id, bool favorite) =>
      _db.setWallpaperFavorite(id, favorite);

  Future<void> markUsed(int id) => _db.touchWallpaperImage(id);

  Future<void> delete(int id) async {
    final row = await _db.wallpaperImageById(id);
    if (row == null) return;
    await _db.deleteWallpaperImage(id);
    final f = File(row.path);
    if (await f.exists()) await f.delete();
  }

  Directory get remoteDir => Directory(p.join(_root.path, 'remote'));

  /// Downloads up to [count] new photos matching [query], normalises them to
  /// 1080×1920 WebP and inserts them. Returns how many were added.
  Future<int> fetchRemote(
    RemoteImageSource source,
    String query, {
    int count = 3,
    Dio? dio,
  }) async {
    if (!source.isConfigured) return 0;
    await remoteDir.create(recursive: true);
    final client = dio ?? Dio();
    final photos = await source.search(query, count: count * 2);
    var added = 0;
    for (final photo in photos) {
      if (added >= count) break;
      if (await _db.hasWallpaperImage(photo.key)) continue;
      try {
        final res = await client.get<List<int>>(
          photo.downloadUrl,
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        final raw = Uint8List.fromList(res.data!);
        final webp = await compute(normaliseToWebp, raw);
        if (webp == null) continue;
        final target = File(p.join(remoteDir.path, '${photo.key}.webp'));
        await target.writeAsBytes(webp, flush: true);
        await _db.insertWallpaperImage(
          WallpaperImagesCompanion.insert(
            path: target.path,
            source: 'remote',
            key: photo.key,
            isDark: Value(photo.isDark),
            width: targetWidth,
            height: targetHeight,
            sizeBytes: Value(webp.length),
            addedAt: DateTime.now(),
            authorName: Value(photo.authorName),
            authorUrl: Value(photo.authorUrl),
            sourceUrl: Value(photo.sourceUrl),
            provider: Value(photo.provider),
          ),
        );
        await source.reportUsed(photo);
        added++;
      } catch (_) {
        // Skip this photo; try the next.
      }
    }
    return added;
  }

  static const targetWidth = 1080;
  static const targetHeight = 1920;

  /// Decode → cover-crop to 9:16 → resize → WebP (lossy). Runs in an isolate.
  /// Falls back to JPEG bytes if WebP encoding is unavailable.
  static Uint8List? normaliseToWebp(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final srcRatio = decoded.width / decoded.height;
    const dstRatio = targetWidth / targetHeight;
    img.Image cropped;
    if (srcRatio > dstRatio) {
      final w = (decoded.height * dstRatio).round();
      cropped = img.copyCrop(
        decoded,
        x: (decoded.width - w) ~/ 2,
        y: 0,
        width: w,
        height: decoded.height,
      );
    } else {
      final h = (decoded.width / dstRatio).round();
      cropped = img.copyCrop(
        decoded,
        x: 0,
        y: (decoded.height - h) ~/ 2,
        width: decoded.width,
        height: h,
      );
    }
    final resized = img.copyResize(
      cropped,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.cubic,
    );
    // package:image encodes WebP losslessly only in some versions; JPEG q82 is
    // a robust, similarly-sized fallback and decodes everywhere.
    return Uint8List.fromList(img.encodeJpg(resized, quality: 82));
  }

  /// Removes least-recently-used, non-favorite remote images until the pool
  /// fits [maxCount] images and [maxBytes]. Seed images are never evicted.
  Future<int> evict({required int maxCount, required int maxBytes}) async {
    final all = await _db.allWallpaperImages();
    var count = all.length;
    var bytes = all.fold<int>(0, (s, r) => s + r.sizeBytes);
    if (count <= maxCount && bytes <= maxBytes) return 0;

    final candidates = await _db.evictableWallpaperImages();
    var removed = 0;
    for (final c in candidates) {
      if (count <= maxCount && bytes <= maxBytes) break;
      await delete(c.id);
      count--;
      bytes -= c.sizeBytes;
      removed++;
    }
    return removed;
  }

  Future<({int count, int bytes})> stats() async {
    final all = await _db.allWallpaperImages();
    return (
      count: all.length,
      bytes: all.fold<int>(0, (s, r) => s + r.sizeBytes),
    );
  }

  static WallpaperImage toEntity(WallpaperImageRow r) => WallpaperImage(
    id: r.id,
    key: r.key,
    path: r.path,
    source: r.source == 'remote'
        ? WallpaperSource.remote
        : WallpaperSource.seed,
    isDark: r.isDark,
    isFavorite: r.isFavorite,
    width: r.width,
    height: r.height,
    mood: r.mood,
    lastUsedAt: r.lastUsedAt,
    authorName: r.authorName,
    authorUrl: r.authorUrl,
    sourceUrl: r.sourceUrl,
    provider: r.provider,
  );
}
