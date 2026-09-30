import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/core/database/bible_database.dart';
import 'package:bible/core/database/user_database.dart';
import 'package:bible/features/automation/domain/automation_settings.dart';
import 'package:bible/features/automation/domain/rotate_wallpaper_use_case.dart';
import 'package:bible/features/votd/domain/verse_pool.dart';
import 'package:bible/features/wallpaper/data/remote_image_source.dart';
import 'package:bible/features/wallpaper/data/wallpaper_applier.dart';
import 'package:bible/features/wallpaper/data/wallpaper_pool_manager.dart';
import 'package:bible/features/wallpaper/domain/entities/wallpaper_image.dart';
import 'package:bible/features/wallpaper/domain/wallpaper_composer.dart';

// ── helpers ─────────────────────────────────────────────────────────────────

Future<int> _addImage(
  UserDatabase db,
  Directory dir,
  String key, {
  String source = 'remote',
  bool favorite = false,
  int bytes = 1000,
  DateTime? lastUsed,
}) async {
  final f = File('${dir.path}/$key.jpg');
  await f.writeAsBytes(List.filled(bytes, 0));
  return db.insertWallpaperImage(
    WallpaperImagesCompanion.insert(
      path: f.path,
      source: source,
      key: key,
      width: 10,
      height: 20,
      sizeBytes: Value(bytes),
      addedAt: DateTime(2024, 1, 1).add(Duration(minutes: key.hashCode % 100)),
      lastUsedAt: Value(lastUsed),
      isFavorite: Value(favorite),
    ),
  );
}

WallpaperHistoryRow _hist({
  required int imageId,
  int bookId = 19,
  int chapter = 23,
  int verse = 1,
}) => WallpaperHistoryRow(
  id: 0,
  imageId: imageId,
  bookId: bookId,
  chapter: chapter,
  verse: verse,
  template: 'classic',
  target: 'lock',
  trigger: 'test',
  success: true,
  appliedAt: DateTime.now(),
);

/// Minimal stand-ins so the use case can be constructed without a Bible DB.
class _NoopApplier implements WallpaperApplier {
  @override
  bool get canSetDirectly => true;
  @override
  Future<ApplyOutcome> apply(Uint8List png, WallpaperTarget target) async =>
      ApplyOutcome.applied;
  @override
  Future<void> saveToGallery(Uint8List png) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutomationSettings', () {
    test('round-trips through SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const s = AutomationSettings(
        enabled: true,
        interval: RotationInterval.sixHours,
        target: WallpaperTarget.both,
        category: ImageCategory.ocean,
        wifiOnly: false,
        remoteEnabled: true,
        poolSize: 50,
        templateName: 'bold',
        excludeLast: 5,
      );
      await s.write(prefs);
      final back = AutomationSettings.read(prefs);
      expect(back.enabled, isTrue);
      expect(back.interval, RotationInterval.sixHours);
      expect(back.target, WallpaperTarget.both);
      expect(back.category, ImageCategory.ocean);
      expect(back.wifiOnly, isFalse);
      expect(back.remoteEnabled, isTrue);
      expect(back.poolSize, 50);
      expect(back.templateName, 'bold');
      expect(back.excludeLast, 5);
    });

    test('defaults are safe (disabled, wifi-only, no remote)', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AutomationSettings.read(await SharedPreferences.getInstance());
      expect(s.enabled, isFalse);
      expect(s.wifiOnly, isTrue);
      expect(s.templateName, isNull);
    });

    test('copyWith can clear templateName', () {
      const s = AutomationSettings(templateName: 'card');
      expect(s.copyWith(templateName: null).templateName, isNull);
      expect(s.copyWith(enabled: true).templateName, 'card');
    });
  });

  group('Remote source parsing', () {
    test('Unsplash accepts array and {results} shapes', () {
      final photo = {
        'id': 'abc',
        'color': '#101010',
        'urls': {'raw': 'https://img/raw'},
        'user': {
          'name': 'Jane',
          'links': {'html': 'https://unsplash.com/@jane'},
        },
        'links': {
          'html': 'https://unsplash.com/photos/abc',
          'download_location': 'https://api.unsplash.com/photos/abc/download',
        },
      };
      final a = UnsplashSource.parse([photo]);
      final b = UnsplashSource.parse({
        'results': [photo],
      });
      expect(a.single.id, 'abc');
      expect(b.single.authorName, 'Jane');
      expect(a.single.downloadUrl, contains('w=1080'));
      expect(a.single.authorUrl, contains('utm_source=bible'));
      expect(a.single.isDark, isTrue);
      expect(a.single.downloadTrackingUrl, isNotNull);
      expect(UnsplashSource.parse('garbage'), isEmpty);
    });

    test('Pexels maps src.large2x and avg_color', () {
      final list = PexelsSource.parse([
        {
          'id': 42,
          'avg_color': '#FFFFFF',
          'src': {'large2x': 'https://p/2x', 'large': 'https://p/1x'},
          'photographer': 'Bob',
          'photographer_url': 'https://www.pexels.com/@bob',
          'url': 'https://www.pexels.com/photo/42',
        },
      ]);
      expect(list.single.id, '42');
      expect(list.single.downloadUrl, 'https://p/2x');
      expect(list.single.isDark, isFalse);
      expect(list.single.provider, 'pexels');
    });

    test('sources without keys report unconfigured', () {
      expect(UnsplashSource(key: '').isConfigured, isFalse);
      expect(PexelsSource(key: 'x').isConfigured, isTrue);
    });
  });

  group('Pool eviction', () {
    late UserDatabase db;
    late Directory tmp;
    late WallpaperPoolManager pool;

    setUp(() async {
      db = UserDatabase.forTesting(NativeDatabase.memory());
      tmp = await Directory.systemTemp.createTemp('vb_evict_');
      pool = WallpaperPoolManager(db: db, documentsDir: tmp);
    });
    tearDown(() async {
      await db.close();
      await tmp.delete(recursive: true);
    });

    test('evicts LRU remote images but never seed or favorites', () async {
      final seed = await _addImage(db, tmp, 's1', source: 'seed');
      final fav = await _addImage(db, tmp, 'r_fav', favorite: true);
      final old = await _addImage(db, tmp, 'r_old', lastUsed: DateTime(2023));
      final newer = await _addImage(db, tmp, 'r_new', lastUsed: DateTime(2024));
      final never = await _addImage(db, tmp, 'r_never');

      final removed = await pool.evict(maxCount: 3, maxBytes: 1 << 20);
      expect(removed, 2);
      final left = (await db.allWallpaperImages()).map((r) => r.id).toSet();
      expect(left, containsAll([seed, fav]));
      // Never-used sorts first (NULL asc) then oldest lastUsedAt.
      expect(left.contains(never), isFalse);
      expect(left.contains(old), isFalse);
      expect(left.contains(newer), isTrue);
      expect(File('${tmp.path}/r_old.jpg').existsSync(), isFalse);
    });

    test('evicts by bytes', () async {
      await _addImage(db, tmp, 's1', source: 'seed', bytes: 100);
      await _addImage(db, tmp, 'r1', bytes: 600);
      await _addImage(db, tmp, 'r2', bytes: 600);
      final removed = await pool.evict(maxCount: 99, maxBytes: 1000);
      expect(removed, 1);
      final stats = await pool.stats();
      expect(stats.count, 2);
      expect(stats.bytes, 700);
    });

    test('no-op when under limits', () async {
      await _addImage(db, tmp, 'r1');
      expect(await pool.evict(maxCount: 5, maxBytes: 1 << 20), 0);
    });
  });

  group('RotateWallpaperUseCase selection', () {
    late UserDatabase db;
    late BibleDatabase bible;
    late Directory tmp;
    late RotateWallpaperUseCase useCase;

    setUp(() async {
      db = UserDatabase.forTesting(NativeDatabase.memory());
      bible = BibleDatabase(NativeDatabase.memory());
      tmp = await Directory.systemTemp.createTemp('vb_rot_');
      useCase = RotateWallpaperUseCase(
        userDb: db,
        bibleDb: bible, // empty; not touched by pick* helpers
        translationAbbreviation: 'KJV',
        pool: WallpaperPoolManager(db: db, documentsDir: tmp),
        applier: _NoopApplier(),
        composer: const WallpaperComposer(),
        settings: const AutomationSettings(templateName: 'bold'),
        random: Random(7),
      );
    });
    tearDown(() async {
      await db.close();
      await bible.close();
      await tmp.delete(recursive: true);
    });

    test('pickImage skips recently used images', () async {
      final a = await _addImage(db, tmp, 'a', source: 'seed');
      final b = await _addImage(db, tmp, 'b', source: 'seed');
      final c = await _addImage(db, tmp, 'c', source: 'seed');
      final history = [_hist(imageId: a), _hist(imageId: b)];
      for (var i = 0; i < 10; i++) {
        final img = await useCase.pickImage(history);
        expect(img.id, c);
      }
    });

    test('pickImage falls back when everything is recent', () async {
      final a = await _addImage(db, tmp, 'a', source: 'seed');
      final img = await useCase.pickImage([_hist(imageId: a)]);
      expect(img.id, a);
    });

    test('pickImage throws on empty pool', () {
      expect(() => useCase.pickImage([]), throwsStateError);
    });

    test('pickVerse avoids recent references', () {
      final recent = versePool
          .take(versePool.length - 1)
          .map(
            (v) => _hist(
              imageId: 1,
              bookId: v.bookId,
              chapter: v.chapter,
              verse: v.verse,
            ),
          )
          .toList();
      final only = versePool.last;
      for (var i = 0; i < 5; i++) {
        final v = useCase.pickVerse(recent);
        expect(
          (v.bookId, v.chapter, v.verse),
          (only.bookId, only.chapter, only.verse),
        );
      }
    });

    test('pickTemplate honours a fixed template', () {
      expect(useCase.pickTemplate(), WallpaperTemplate.bold);
    });
  });

  group('WallpaperHistory', () {
    test('insert, watch, prune', () async {
      final db = UserDatabase.forTesting(NativeDatabase.memory());
      for (var i = 0; i < 5; i++) {
        await db.insertWallpaperHistory(
          WallpaperHistoryCompanion.insert(
            imageId: i,
            bookId: 1,
            chapter: 1,
            verse: i + 1,
            template: 'classic',
            target: 'lock',
            trigger: 'test',
            appliedAt: DateTime(2024, 1, 1 + i),
          ),
        );
      }
      final recent = await db.recentWallpaperHistory(2);
      expect(recent.map((r) => r.verse), [5, 4]);
      await db.pruneWallpaperHistory(keep: 3);
      expect((await db.recentWallpaperHistory(10)).length, 3);
      await db.close();
    });
  });
}
