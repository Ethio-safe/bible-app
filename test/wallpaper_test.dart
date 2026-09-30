import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible/core/database/user_database.dart';
import 'package:bible/features/wallpaper/data/wallpaper_pool_manager.dart';
import 'package:bible/features/wallpaper/domain/entities/wallpaper_image.dart';
import 'package:bible/features/wallpaper/domain/wallpaper_composer.dart';

/// Serves the real seed assets from disk without a Flutter engine asset
/// bundle.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.view(bytes.buffer);
  }
}

Future<ui.Image> _solidImage(int w, int h, ui.Color color) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    ui.Paint()..color = color,
  );
  return recorder.endRecording().toImage(w, h);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WallpaperPoolManager', () {
    late UserDatabase db;
    late Directory tmp;

    setUp(() async {
      db = UserDatabase.forTesting(NativeDatabase.memory());
      tmp = await Directory.systemTemp.createTemp('vb_pool_');
    });

    tearDown(() async {
      await db.close();
      await tmp.delete(recursive: true);
    });

    test('seedPool copies all seed images once and is idempotent', () async {
      final manifest =
          jsonDecode(File(WallpaperPoolManager.seedManifest).readAsStringSync())
              as List;
      expect(manifest.length, greaterThanOrEqualTo(15));

      final pool = WallpaperPoolManager(
        db: db,
        documentsDir: tmp,
        bundle: _DiskBundle(),
      );
      final added = await pool.seedPool();
      expect(added, manifest.length);

      final images = await pool.watchAll().first;
      expect(images, hasLength(manifest.length));
      for (final img in images) {
        expect(img.file.existsSync(), isTrue, reason: img.path);
        expect(img.source, WallpaperSource.seed);
      }

      expect(await pool.seedPool(), 0, reason: 'second run adds nothing');
    });

    test('favorites sort first and persist', () async {
      final pool = WallpaperPoolManager(
        db: db,
        documentsDir: tmp,
        bundle: _DiskBundle(),
      );
      await pool.seedPool();
      final all = await pool.watchAll().first;
      final last = all.last;
      await pool.setFavorite(last.id, true);
      final after = await pool.watchAll().first;
      expect(after.first.id, last.id);
      expect(after.first.isFavorite, isTrue);
    });
  });

  group('WallpaperComposer', () {
    const composer = WallpaperComposer();
    const quote = WallpaperQuote(
      text: 'The LORD is my shepherd; I shall not want.',
      reference: 'Psalm 23:1',
      translation: 'KJV',
      bookId: 19,
      chapter: 23,
      verse: 1,
    );

    for (final template in WallpaperTemplate.values) {
      test('renders ${template.name} to a PNG of the requested size', () async {
        final bg = await _solidImage(300, 500, const ui.Color(0xFF224466));
        final png = await composer.renderPng(
          WallpaperSpec(
            image: bg,
            quote: quote,
            template: template,
            size: const ui.Size(540, 960),
          ),
        );
        // PNG signature
        expect(png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
        final codec = await ui.instantiateImageCodec(png);
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 540);
        expect(frame.image.height, 960);
        frame.image.dispose();
        codec.dispose();
        bg.dispose();
      });
    }

    test('very long quote still renders without throwing', () async {
      final bg = await _solidImage(100, 100, const ui.Color(0xFF000000));
      final long = List.filled(40, quote.text).join(' ');
      final png = await composer.renderPng(
        WallpaperSpec(
          image: bg,
          quote: quote.copyWith(text: long),
          template: WallpaperTemplate.card,
          size: const ui.Size(360, 640),
        ),
      );
      expect(png, isNotEmpty);
      bg.dispose();
    });
  });

  group('UserDatabase schema', () {
    test('v2 has wallpaper_images table', () async {
      final db = UserDatabase.forTesting(NativeDatabase.memory());
      await db.insertWallpaperImage(
        WallpaperImagesCompanion.insert(
          path: '/x.webp',
          source: 'seed',
          key: 'k1',
          width: 1,
          height: 1,
          addedAt: DateTime.now(),
        ),
      );
      expect(await db.hasWallpaperImage('k1'), isTrue);
      expect(await db.hasWallpaperImage('k2'), isFalse);
      await db.close();
    });
  });
}
