import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/bible_database.dart';
import '../../../core/database/user_database.dart';
import '../../bible/domain/entities/book.dart';
import '../../votd/domain/verse_pool.dart';
import '../../votd/domain/edition_verse_pool.dart';
import '../../wallpaper/data/remote_image_source.dart';
import '../../wallpaper/data/wallpaper_applier.dart';
import '../../wallpaper/data/wallpaper_pool_manager.dart';
import '../../wallpaper/domain/entities/wallpaper_image.dart';
import '../../wallpaper/domain/wallpaper_composer.dart';
import 'automation_settings.dart';

class RotationResult {
  const RotationResult({
    required this.image,
    required this.verse,
    required this.template,
    this.remoteAdded = 0,
    this.evicted = 0,
  });
  final WallpaperImage image;
  final PoolVerse verse;
  final WallpaperTemplate template;
  final int remoteAdded;
  final int evicted;
}

/// Picks a fresh image + verse, composes at [size], applies, logs history.
/// Pure Dart aside from the injected collaborators, so it runs identically in
/// the foreground ("Refresh now") and inside the WorkManager isolate.
class RotateWallpaperUseCase {
  RotateWallpaperUseCase({
    required this.userDb,
    required this.bibleDb,
    required this.translationAbbreviation,
    required this.pool,
    required this.applier,
    required this.composer,
    required this.settings,
    this.remote,
    this.connectivity,
    Random? random,
  }) : _rng = random ?? Random();

  final UserDatabase userDb;
  final BibleDatabase bibleDb;
  final String translationAbbreviation;
  final WallpaperPoolManager pool;
  final WallpaperApplier applier;
  final WallpaperComposer composer;
  final AutomationSettings settings;
  final RemoteImageSource? remote;
  final Connectivity? connectivity;
  final Random _rng;

  Future<RotationResult> run({
    required ui.Size size,
    required String trigger,
  }) async {
    // 1. Optionally top up the pool from the network.
    var remoteAdded = 0;
    if (settings.remoteEnabled && remote != null && remote!.isConfigured) {
      if (await _networkAllowed()) {
        try {
          remoteAdded = await pool.fetchRemote(
            remote!,
            settings.category.query,
            count: 2,
          );
        } catch (_) {
          // Offline / quota — keep rotating with what we have.
        }
      }
    }
    final evicted = await pool.evict(
      maxCount: settings.poolSize,
      maxBytes: AutomationSettings.maxPoolBytes,
    );

    // 2. Choose image + verse not used recently.
    final history = await userDb.recentWallpaperHistory(settings.excludeLast);
    final image = await pickImage(history);
    final editionPool = await EditionVersePool.load(bibleDb);
    final verse = pickVerse(history, candidates: editionPool.verses);
    final template = pickTemplate();

    // 3. Compose + apply.
    final books = await bibleDb.allBooks();
    final book = books.firstWhere((b) => b.id == verse.bookId);
    final quote = await _quoteFor(verse, book.name);
    final bg = await _decode(image);
    try {
      final png = await composer.renderPng(
        WallpaperSpec(
          image: bg,
          quote: quote,
          template: template,
          size: size,
          watermark: false,
        ),
      );
      // In live mode a static setBitmap would replace the live wallpaper, so
      // the periodic job only refreshes the pre-rendered set (see renderBatch).
      if (!settings.liveMode) {
        await applier.apply(png, settings.target);
      }
      await pool.markUsed(image.id);
      await _log(image, verse, template, trigger, success: true);
    } catch (e) {
      await _log(image, verse, template, trigger, success: false, error: '$e');
      rethrow;
    } finally {
      bg.dispose();
    }
    await userDb.pruneWallpaperHistory();
    return RotationResult(
      image: image,
      verse: verse,
      template: template,
      remoteAdded: remoteAdded,
      evicted: evicted,
    );
  }

  /// Pre-renders [count] distinct wallpapers into [outputDir] for the live
  /// wallpaper engine. Existing PNGs are replaced atomically (render to temp
  /// names, then swap) so the engine never sees a half-written set.
  Future<int> renderBatch({
    required ui.Size size,
    required Directory outputDir,
    int count = AutomationSettings.liveSetSize,
  }) async {
    final images = (await userDb.allWallpaperImages())
        .map(WallpaperPoolManager.toEntity)
        .toList();
    if (images.isEmpty) throw StateError('Wallpaper pool is empty');
    final books = await bibleDb.allBooks();

    images.shuffle(_rng);
    // Distinct verses by reference (the pool has no duplicates, but guard
    // anyway so two wallpapers can never carry the same quote).
    final seen = <String>{};
    final verses = <PoolVerse>[];
    final editionPool = await EditionVersePool.load(bibleDb);
    for (final v in List<PoolVerse>.of(editionPool.verses)..shuffle(_rng)) {
      if (seen.add('${v.bookId}:${v.chapter}:${v.verse}')) verses.add(v);
    }
    final n = min(count, verses.length);
    const templates = WallpaperTemplate.values;

    await outputDir.create(recursive: true);
    final tmp = <File>[];
    try {
      for (var i = 0; i < n; i++) {
        final image = images[i % images.length];
        final verse = verses[i];
        final book = books.where((b) => b.id == verse.bookId).firstOrNull;
        if (book == null) continue;
        final quote = await _quoteFor(verse, book.name);
        final bg = await _decode(image);
        try {
          final png = await composer.renderPng(
            WallpaperSpec(
              image: bg,
              quote: quote,
              template: settings.templateName == null
                  ? templates[i % templates.length]
                  : pickTemplate(),
              size: size,
              watermark: false,
            ),
          );
          final f = File(p.join(outputDir.path, '.tmp_$i.png'));
          await f.writeAsBytes(png, flush: true);
          tmp.add(f);
        } finally {
          bg.dispose();
        }
      }
      // Swap: delete old set, promote temp files.
      for (final f in outputDir.listSync().whereType<File>()) {
        if (p.basename(f.path).startsWith('wp_')) await f.delete();
      }
      for (var i = 0; i < tmp.length; i++) {
        await tmp[i].rename(
          p.join(outputDir.path, 'wp_${i.toString().padLeft(2, '0')}.png'),
        );
      }
      return tmp.length;
    } catch (_) {
      for (final f in tmp) {
        if (f.existsSync()) await f.delete();
      }
      rethrow;
    }
  }

  // ── Selection (public for tests) ──────────────────────────────────────────

  Future<WallpaperImage> pickImage(List<WallpaperHistoryRow> history) async {
    final all = (await userDb.allWallpaperImages())
        .map(WallpaperPoolManager.toEntity)
        .toList();
    if (all.isEmpty) throw StateError('Wallpaper pool is empty');
    final recent = history.map((h) => h.imageId).toSet();
    var candidates = all.where((i) => !recent.contains(i.id)).toList();
    if (candidates.isEmpty) candidates = all;
    // Prefer images never used, then least recently used, then random.
    candidates.shuffle(_rng);
    candidates.sort((a, b) {
      if (a.lastUsedAt == null && b.lastUsedAt != null) return -1;
      if (a.lastUsedAt != null && b.lastUsedAt == null) return 1;
      return 0;
    });
    // Take from the top ~third to keep some randomness.
    final n = max(1, candidates.length ~/ 3);
    return candidates[_rng.nextInt(n)];
  }

  PoolVerse pickVerse(
    List<WallpaperHistoryRow> history, {
    List<PoolVerse> candidates = versePool,
  }) {
    final recent = {
      for (final h in history) '${h.bookId}:${h.chapter}:${h.verse}',
    };
    final fresh = candidates
        .where((v) => !recent.contains('${v.bookId}:${v.chapter}:${v.verse}'))
        .toList();
    final list = fresh.isEmpty ? candidates : fresh;
    return list[_rng.nextInt(list.length)];
  }

  WallpaperTemplate pickTemplate() {
    final fixed = settings.templateName;
    if (fixed != null) {
      return WallpaperTemplate.values
              .where((t) => t.name == fixed)
              .firstOrNull ??
          WallpaperTemplate.classic;
    }
    return WallpaperTemplate.values[_rng.nextInt(
      WallpaperTemplate.values.length,
    )];
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<bool> _networkAllowed() async {
    final c = connectivity;
    if (c == null) return true;
    final results = await c.checkConnectivity();
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return false;
    }
    if (!settings.wifiOnly) return true;
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  Future<WallpaperQuote> _quoteFor(PoolVerse v, String bookName) async {
    final last = v.endVerse ?? v.verse;
    final parts = <String>[];
    for (var n = v.verse; n <= last; n++) {
      final row = await bibleDb.singleVerse(v.bookId, v.chapter, n);
      if (row != null) parts.add(row.body.trim());
    }
    final range = v.isRange ? '-${v.endVerse}' : '';
    return WallpaperQuote(
      text: parts.join(' '),
      reference: '$bookName ${v.chapter}:${v.verse}$range',
      translation: translationAbbreviation,
      bookId: v.bookId,
      chapter: v.chapter,
      verse: v.verse,
    );
  }

  Future<ui.Image> _decode(WallpaperImage image) async {
    final bytes = await image.file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  Future<void> _log(
    WallpaperImage image,
    PoolVerse verse,
    WallpaperTemplate template,
    String trigger, {
    required bool success,
    String? error,
  }) => userDb.insertWallpaperHistory(
    WallpaperHistoryCompanion.insert(
      imageId: image.id,
      bookId: verse.bookId,
      chapter: verse.chapter,
      verse: verse.verse,
      template: template.name,
      target: settings.target.name,
      trigger: trigger,
      success: Value(success),
      error: Value(error),
      appliedAt: DateTime.now(),
    ),
  );
}

extension BookLookup on List<Book> {
  Book? byId(int id) => where((b) => b.id == id).firstOrNull;
}
