// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wallpaperPoolHash() => r'3563d0c882ada869c411dedcbca0c729d5802969';

/// See also [wallpaperPool].
@ProviderFor(wallpaperPool)
final wallpaperPoolProvider = FutureProvider<WallpaperPoolManager>.internal(
  wallpaperPool,
  name: r'wallpaperPoolProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wallpaperPoolHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WallpaperPoolRef = FutureProviderRef<WallpaperPoolManager>;
String _$wallpaperImagesHash() => r'acf23733e680d5b0b094ea9b9b46f31e0a588093';

/// See also [wallpaperImages].
@ProviderFor(wallpaperImages)
final wallpaperImagesProvider =
    AutoDisposeStreamProvider<List<WallpaperImage>>.internal(
      wallpaperImages,
      name: r'wallpaperImagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wallpaperImagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WallpaperImagesRef = AutoDisposeStreamProviderRef<List<WallpaperImage>>;
String _$wallpaperImageHash() => r'f45af9d3481d9c82562d3a1636db456b7c2b0a9e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [wallpaperImage].
@ProviderFor(wallpaperImage)
const wallpaperImageProvider = WallpaperImageFamily();

/// See also [wallpaperImage].
class WallpaperImageFamily extends Family<AsyncValue<WallpaperImage?>> {
  /// See also [wallpaperImage].
  const WallpaperImageFamily();

  /// See also [wallpaperImage].
  WallpaperImageProvider call(int id) {
    return WallpaperImageProvider(id);
  }

  @override
  WallpaperImageProvider getProviderOverride(
    covariant WallpaperImageProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'wallpaperImageProvider';
}

/// See also [wallpaperImage].
class WallpaperImageProvider
    extends AutoDisposeFutureProvider<WallpaperImage?> {
  /// See also [wallpaperImage].
  WallpaperImageProvider(int id)
    : this._internal(
        (ref) => wallpaperImage(ref as WallpaperImageRef, id),
        from: wallpaperImageProvider,
        name: r'wallpaperImageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$wallpaperImageHash,
        dependencies: WallpaperImageFamily._dependencies,
        allTransitiveDependencies:
            WallpaperImageFamily._allTransitiveDependencies,
        id: id,
      );

  WallpaperImageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<WallpaperImage?> Function(WallpaperImageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WallpaperImageProvider._internal(
        (ref) => create(ref as WallpaperImageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WallpaperImage?> createElement() {
    return _WallpaperImageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WallpaperImageProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WallpaperImageRef on AutoDisposeFutureProviderRef<WallpaperImage?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _WallpaperImageProviderElement
    extends AutoDisposeFutureProviderElement<WallpaperImage?>
    with WallpaperImageRef {
  _WallpaperImageProviderElement(super.provider);

  @override
  int get id => (origin as WallpaperImageProvider).id;
}

String _$decodedWallpaperImageHash() =>
    r'63c29376182a00702e95e7b194a42a86f63b8fe6';

/// Decoded, cached background image (kept alive while watched).
///
/// Copied from [decodedWallpaperImage].
@ProviderFor(decodedWallpaperImage)
const decodedWallpaperImageProvider = DecodedWallpaperImageFamily();

/// Decoded, cached background image (kept alive while watched).
///
/// Copied from [decodedWallpaperImage].
class DecodedWallpaperImageFamily extends Family<AsyncValue<ui.Image>> {
  /// Decoded, cached background image (kept alive while watched).
  ///
  /// Copied from [decodedWallpaperImage].
  const DecodedWallpaperImageFamily();

  /// Decoded, cached background image (kept alive while watched).
  ///
  /// Copied from [decodedWallpaperImage].
  DecodedWallpaperImageProvider call(String path) {
    return DecodedWallpaperImageProvider(path);
  }

  @override
  DecodedWallpaperImageProvider getProviderOverride(
    covariant DecodedWallpaperImageProvider provider,
  ) {
    return call(provider.path);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'decodedWallpaperImageProvider';
}

/// Decoded, cached background image (kept alive while watched).
///
/// Copied from [decodedWallpaperImage].
class DecodedWallpaperImageProvider
    extends AutoDisposeFutureProvider<ui.Image> {
  /// Decoded, cached background image (kept alive while watched).
  ///
  /// Copied from [decodedWallpaperImage].
  DecodedWallpaperImageProvider(String path)
    : this._internal(
        (ref) => decodedWallpaperImage(ref as DecodedWallpaperImageRef, path),
        from: decodedWallpaperImageProvider,
        name: r'decodedWallpaperImageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$decodedWallpaperImageHash,
        dependencies: DecodedWallpaperImageFamily._dependencies,
        allTransitiveDependencies:
            DecodedWallpaperImageFamily._allTransitiveDependencies,
        path: path,
      );

  DecodedWallpaperImageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  Override overrideWith(
    FutureOr<ui.Image> Function(DecodedWallpaperImageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DecodedWallpaperImageProvider._internal(
        (ref) => create(ref as DecodedWallpaperImageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ui.Image> createElement() {
    return _DecodedWallpaperImageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DecodedWallpaperImageProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DecodedWallpaperImageRef on AutoDisposeFutureProviderRef<ui.Image> {
  /// The parameter `path` of this provider.
  String get path;
}

class _DecodedWallpaperImageProviderElement
    extends AutoDisposeFutureProviderElement<ui.Image>
    with DecodedWallpaperImageRef {
  _DecodedWallpaperImageProviderElement(super.provider);

  @override
  String get path => (origin as DecodedWallpaperImageProvider).path;
}

String _$quoteFromPoolHash() => r'490f2e4e123030197a5c9c7fbf66fd9eeeccbf1b';

/// See also [quoteFromPool].
@ProviderFor(quoteFromPool)
const quoteFromPoolProvider = QuoteFromPoolFamily();

/// See also [quoteFromPool].
class QuoteFromPoolFamily extends Family<AsyncValue<WallpaperQuote>> {
  /// See also [quoteFromPool].
  const QuoteFromPoolFamily();

  /// See also [quoteFromPool].
  QuoteFromPoolProvider call(PoolVerse pool) {
    return QuoteFromPoolProvider(pool);
  }

  @override
  QuoteFromPoolProvider getProviderOverride(
    covariant QuoteFromPoolProvider provider,
  ) {
    return call(provider.pool);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'quoteFromPoolProvider';
}

/// See also [quoteFromPool].
class QuoteFromPoolProvider extends AutoDisposeFutureProvider<WallpaperQuote> {
  /// See also [quoteFromPool].
  QuoteFromPoolProvider(PoolVerse pool)
    : this._internal(
        (ref) => quoteFromPool(ref as QuoteFromPoolRef, pool),
        from: quoteFromPoolProvider,
        name: r'quoteFromPoolProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$quoteFromPoolHash,
        dependencies: QuoteFromPoolFamily._dependencies,
        allTransitiveDependencies:
            QuoteFromPoolFamily._allTransitiveDependencies,
        pool: pool,
      );

  QuoteFromPoolProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pool,
  }) : super.internal();

  final PoolVerse pool;

  @override
  Override overrideWith(
    FutureOr<WallpaperQuote> Function(QuoteFromPoolRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuoteFromPoolProvider._internal(
        (ref) => create(ref as QuoteFromPoolRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pool: pool,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WallpaperQuote> createElement() {
    return _QuoteFromPoolProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuoteFromPoolProvider && other.pool == pool;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pool.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuoteFromPoolRef on AutoDisposeFutureProviderRef<WallpaperQuote> {
  /// The parameter `pool` of this provider.
  PoolVerse get pool;
}

class _QuoteFromPoolProviderElement
    extends AutoDisposeFutureProviderElement<WallpaperQuote>
    with QuoteFromPoolRef {
  _QuoteFromPoolProviderElement(super.provider);

  @override
  PoolVerse get pool => (origin as QuoteFromPoolProvider).pool;
}

String _$quoteFromRangeHash() => r'09cd2f61b09fb0c1df71868bf6f6059b0e5cc0b3';

/// Quote built from an explicit verse range (from the reader).
///
/// Copied from [quoteFromRange].
@ProviderFor(quoteFromRange)
const quoteFromRangeProvider = QuoteFromRangeFamily();

/// Quote built from an explicit verse range (from the reader).
///
/// Copied from [quoteFromRange].
class QuoteFromRangeFamily extends Family<AsyncValue<WallpaperQuote>> {
  /// Quote built from an explicit verse range (from the reader).
  ///
  /// Copied from [quoteFromRange].
  const QuoteFromRangeFamily();

  /// Quote built from an explicit verse range (from the reader).
  ///
  /// Copied from [quoteFromRange].
  QuoteFromRangeProvider call({
    required int bookId,
    required int chapter,
    required int start,
    required int end,
  }) {
    return QuoteFromRangeProvider(
      bookId: bookId,
      chapter: chapter,
      start: start,
      end: end,
    );
  }

  @override
  QuoteFromRangeProvider getProviderOverride(
    covariant QuoteFromRangeProvider provider,
  ) {
    return call(
      bookId: provider.bookId,
      chapter: provider.chapter,
      start: provider.start,
      end: provider.end,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'quoteFromRangeProvider';
}

/// Quote built from an explicit verse range (from the reader).
///
/// Copied from [quoteFromRange].
class QuoteFromRangeProvider extends AutoDisposeFutureProvider<WallpaperQuote> {
  /// Quote built from an explicit verse range (from the reader).
  ///
  /// Copied from [quoteFromRange].
  QuoteFromRangeProvider({
    required int bookId,
    required int chapter,
    required int start,
    required int end,
  }) : this._internal(
         (ref) => quoteFromRange(
           ref as QuoteFromRangeRef,
           bookId: bookId,
           chapter: chapter,
           start: start,
           end: end,
         ),
         from: quoteFromRangeProvider,
         name: r'quoteFromRangeProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$quoteFromRangeHash,
         dependencies: QuoteFromRangeFamily._dependencies,
         allTransitiveDependencies:
             QuoteFromRangeFamily._allTransitiveDependencies,
         bookId: bookId,
         chapter: chapter,
         start: start,
         end: end,
       );

  QuoteFromRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookId,
    required this.chapter,
    required this.start,
    required this.end,
  }) : super.internal();

  final int bookId;
  final int chapter;
  final int start;
  final int end;

  @override
  Override overrideWith(
    FutureOr<WallpaperQuote> Function(QuoteFromRangeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuoteFromRangeProvider._internal(
        (ref) => create(ref as QuoteFromRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookId: bookId,
        chapter: chapter,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WallpaperQuote> createElement() {
    return _QuoteFromRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuoteFromRangeProvider &&
        other.bookId == bookId &&
        other.chapter == chapter &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);
    hash = _SystemHash.combine(hash, chapter.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuoteFromRangeRef on AutoDisposeFutureProviderRef<WallpaperQuote> {
  /// The parameter `bookId` of this provider.
  int get bookId;

  /// The parameter `chapter` of this provider.
  int get chapter;

  /// The parameter `start` of this provider.
  int get start;

  /// The parameter `end` of this provider.
  int get end;
}

class _QuoteFromRangeProviderElement
    extends AutoDisposeFutureProviderElement<WallpaperQuote>
    with QuoteFromRangeRef {
  _QuoteFromRangeProviderElement(super.provider);

  @override
  int get bookId => (origin as QuoteFromRangeProvider).bookId;
  @override
  int get chapter => (origin as QuoteFromRangeProvider).chapter;
  @override
  int get start => (origin as QuoteFromRangeProvider).start;
  @override
  int get end => (origin as QuoteFromRangeProvider).end;
}

String _$previewQuoteHash() => r'd4aa37c4adf29cd825a79dbdeb78a6cb6d63ed51';

/// See also [previewQuote].
@ProviderFor(previewQuote)
final previewQuoteProvider = AutoDisposeFutureProvider<WallpaperQuote>.internal(
  previewQuote,
  name: r'previewQuoteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$previewQuoteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreviewQuoteRef = AutoDisposeFutureProviderRef<WallpaperQuote>;
String _$wallpaperComposerHash() => r'2c0e4e76bb9c9ac29fe7c2a26b5fc2f1ed375e82';

/// See also [wallpaperComposer].
@ProviderFor(wallpaperComposer)
final wallpaperComposerProvider = Provider<WallpaperComposer>.internal(
  wallpaperComposer,
  name: r'wallpaperComposerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wallpaperComposerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WallpaperComposerRef = ProviderRef<WallpaperComposer>;
String _$wallpaperApplierHash() => r'45c510eb111c1545ce81953f1d4c14efc1d43edd';

/// See also [wallpaperApplier].
@ProviderFor(wallpaperApplier)
final wallpaperApplierProvider = Provider<WallpaperApplier>.internal(
  wallpaperApplier,
  name: r'wallpaperApplierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wallpaperApplierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WallpaperApplierRef = ProviderRef<WallpaperApplier>;
String _$previewRendererHash() => r'1cd93fa98342eb3eda696aee8b97c4f8a71dcbbd';

/// See also [previewRenderer].
@ProviderFor(previewRenderer)
final previewRendererProvider = Provider<PreviewRenderer>.internal(
  previewRenderer,
  name: r'previewRendererProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$previewRendererHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreviewRendererRef = ProviderRef<PreviewRenderer>;
String _$wallpaperVerseLanguageControllerHash() =>
    r'5286d3dd8b2516ce9dc3c36be880b552f6fffd07';

/// See also [WallpaperVerseLanguageController].
@ProviderFor(WallpaperVerseLanguageController)
final wallpaperVerseLanguageControllerProvider =
    NotifierProvider<
      WallpaperVerseLanguageController,
      WallpaperVerseLanguage
    >.internal(
      WallpaperVerseLanguageController.new,
      name: r'wallpaperVerseLanguageControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wallpaperVerseLanguageControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WallpaperVerseLanguageController = Notifier<WallpaperVerseLanguage>;
String _$previewControllerHash() => r'25a4d456838bdd5c0665f434bdbc55ee7173695c';

/// See also [PreviewController].
@ProviderFor(PreviewController)
final previewControllerProvider =
    NotifierProvider<PreviewController, PreviewState>.internal(
      PreviewController.new,
      name: r'previewControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$previewControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PreviewController = Notifier<PreviewState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
