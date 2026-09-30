import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/database/bible_database.dart';
import '../../../../core/database/bundled_bibles.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../votd/domain/verse_pool.dart';
import '../../../votd/presentation/providers/votd_providers.dart';
import '../../../votd/domain/edition_verse_pool.dart';
import '../../data/wallpaper_applier.dart';
import '../../data/wallpaper_pool_manager.dart';
import '../../domain/entities/wallpaper_image.dart';
import '../../domain/wallpaper_composer.dart';

part 'wallpaper_providers.g.dart';

// ── Pool ────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Future<WallpaperPoolManager> wallpaperPool(Ref ref) async {
  final docs = await getApplicationDocumentsDirectory();
  final manager = WallpaperPoolManager(
    db: ref.watch(userDatabaseProvider),
    documentsDir: docs,
  );
  await manager.seedPool();
  return manager;
}

@riverpod
Stream<List<WallpaperImage>> wallpaperImages(Ref ref) async* {
  final pool = await ref.watch(wallpaperPoolProvider.future);
  yield* pool.watchAll();
}

@riverpod
Future<WallpaperImage?> wallpaperImage(Ref ref, int id) async {
  final pool = await ref.watch(wallpaperPoolProvider.future);
  return pool.byId(id);
}

/// Decoded, cached background image (kept alive while watched).
@riverpod
Future<ui.Image> decodedWallpaperImage(Ref ref, String path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  ref.onDispose(frame.image.dispose);
  return frame.image;
}

// ── Quote selection ─────────────────────────────────────────────────────────

@riverpod
Future<WallpaperQuote> quoteFromPool(Ref ref, PoolVerse pool) async {
  final language = ref.watch(wallpaperVerseLanguageControllerProvider);
  final key = language == WallpaperVerseLanguage.english ? 'eot_en' : 'eot_am';
  final dir = await ref.watch(bibleDbDirectoryProvider.future);
  final db = BibleDatabase.open(p.join(dir.path, BundledBibles.files[key]!));
  try {
    final editionPool = await EditionVersePool.load(db);
    final resolved = editionPool.resolve(pool);
    final book = await db.bookById(resolved.bookId);
    if (book == null) throw StateError('Unknown wallpaper book');
    final end = resolved.endVerse ?? resolved.verse;
    final parts = <String>[];
    for (var verse = resolved.verse; verse <= end; verse++) {
      final row = await db.singleVerse(
        resolved.bookId,
        resolved.chapter,
        verse,
      );
      if (row == null || row.body.trim().isEmpty) {
        throw StateError('Wallpaper verse is unavailable');
      }
      parts.add(row.body.trim());
    }
    final meta = await db.readMeta();
    final suffix = resolved.endVerse == null ? '' : '-${resolved.endVerse}';
    return WallpaperQuote(
      text: parts.join(' '),
      reference: '${book.name} ${resolved.chapter}:${resolved.verse}$suffix',
      translation: meta['abbreviation'] ?? key.toUpperCase(),
      bookId: resolved.bookId,
      chapter: resolved.chapter,
      verse: resolved.verse,
    );
  } finally {
    await db.close();
  }
}

/// Quote built from an explicit verse range (from the reader).
@riverpod
Future<WallpaperQuote> quoteFromRange(
  Ref ref, {
  required int bookId,
  required int chapter,
  required int start,
  required int end,
}) async {
  final repo = await ref.watch(bibleRepositoryProvider.future);
  final translation = await ref.watch(currentTranslationProvider.future);
  final book = await repo.getBook(bookId);
  if (book == null)
    throw StateError(
      'This passage is unavailable in the selected edition. Choose another verse.',
    );
  final parts = <String>[];
  for (var v = start; v <= end; v++) {
    final verse = await repo.getVerse(bookId, chapter, v);
    if (verse == null || verse.text.trim().isEmpty)
      throw StateError(
        'This verse range is unavailable in the selected edition.',
      );
    parts.add(verse.text.trim());
  }
  final refLabel = start == end ? '$chapter:$start' : '$chapter:$start-$end';
  return WallpaperQuote(
    text: parts.join(' '),
    reference: '${book.name} $refLabel',
    translation: translation.abbreviation,
    bookId: bookId,
    chapter: chapter,
    verse: start,
  );
}

PoolVerse randomPoolVerse([Random? rng]) =>
    versePool[(rng ?? Random()).nextInt(versePool.length)];

// ── Preview state ───────────────────────────────────────────────────────────

/// Where the quote for the preview comes from.
sealed class QuoteSource {
  const QuoteSource();
}

class VotdQuoteSource extends QuoteSource {
  const VotdQuoteSource();
}

class PoolQuoteSource extends QuoteSource {
  const PoolQuoteSource(this.verse);
  final PoolVerse verse;
}

class RangeQuoteSource extends QuoteSource {
  const RangeQuoteSource({
    required this.bookId,
    required this.chapter,
    required this.start,
    required this.end,
  });
  final int bookId, chapter, start, end;
}

enum WallpaperVerseLanguage { english, amharic }

@Riverpod(keepAlive: true)
class WallpaperVerseLanguageController
    extends _$WallpaperVerseLanguageController {
  @override
  WallpaperVerseLanguage build() => WallpaperVerseLanguage.english;

  void set(WallpaperVerseLanguage language) => state = language;
}

class PreviewState {
  const PreviewState({
    required this.imageId,
    required this.template,
    required this.source,
    this.watermark = true,
  });

  final int imageId;
  final WallpaperTemplate template;
  final QuoteSource source;
  final bool watermark;

  PreviewState copyWith({
    int? imageId,
    WallpaperTemplate? template,
    QuoteSource? source,
    bool? watermark,
  }) => PreviewState(
    imageId: imageId ?? this.imageId,
    template: template ?? this.template,
    source: source ?? this.source,
    watermark: watermark ?? this.watermark,
  );
}

@Riverpod(keepAlive: true)
class PreviewController extends _$PreviewController {
  @override
  PreviewState build() => const PreviewState(
    imageId: 0,
    template: WallpaperTemplate.classic,
    source: VotdQuoteSource(),
  );

  void start({
    required int imageId,
    QuoteSource? source,
    WallpaperTemplate? template,
  }) => state = PreviewState(
    imageId: imageId,
    template: template ?? state.template,
    source: source ?? state.source,
    watermark: state.watermark,
  );

  void setImage(int id) => state = state.copyWith(imageId: id);
  void setTemplate(WallpaperTemplate t) => state = state.copyWith(template: t);
  void setSource(QuoteSource s) => state = state.copyWith(source: s);
  void shuffleVerse() =>
      state = state.copyWith(source: PoolQuoteSource(randomPoolVerse()));
  void toggleWatermark() => state = state.copyWith(watermark: !state.watermark);
}

@riverpod
Future<WallpaperQuote> previewQuote(Ref ref) {
  final source = ref.watch(previewControllerProvider.select((s) => s.source));
  return switch (source) {
    VotdQuoteSource() => ref.watch(
      quoteFromPoolProvider(verseForDate(DateTime.now())).future,
    ),
    PoolQuoteSource(:final verse) => ref.watch(
      quoteFromPoolProvider(verse).future,
    ),
    RangeQuoteSource(:final bookId, :final chapter, :final start, :final end) =>
      ref.watch(
        quoteFromRangeProvider(
          bookId: bookId,
          chapter: chapter,
          start: start,
          end: end,
        ).future,
      ),
  };
}

// ── Rendering / applying ────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
WallpaperComposer wallpaperComposer(Ref ref) => const WallpaperComposer();

@Riverpod(keepAlive: true)
WallpaperApplier wallpaperApplier(Ref ref) => WallpaperApplier.forPlatform();

/// Renders the current preview at [size] physical pixels.
class PreviewRenderer {
  PreviewRenderer(this._ref);
  final Ref _ref;

  Future<Uint8List> render(Size size) async {
    final state = _ref.read(previewControllerProvider);
    final image = await _ref.read(wallpaperImageProvider(state.imageId).future);
    if (image == null) throw StateError('Image ${state.imageId} not found');
    final bg = await _ref.read(
      decodedWallpaperImageProvider(image.path).future,
    );
    final quote = await _ref.read(previewQuoteProvider.future);
    return _ref
        .read(wallpaperComposerProvider)
        .renderPng(
          WallpaperSpec(
            image: bg,
            quote: quote,
            template: state.template,
            size: size,
            watermark: state.watermark,
          ),
        );
  }
}

@Riverpod(keepAlive: true)
PreviewRenderer previewRenderer(Ref ref) => PreviewRenderer(ref);
