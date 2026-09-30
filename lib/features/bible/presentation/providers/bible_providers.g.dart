// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$translationsHash() => r'8f55ab6041045be4baa1274381d947fdab9e2451';

/// All bundled translations with metadata read from each DB's `meta` table.
///
/// Copied from [translations].
@ProviderFor(translations)
final translationsProvider = FutureProvider<List<Translation>>.internal(
  translations,
  name: r'translationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$translationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TranslationsRef = FutureProviderRef<List<Translation>>;
String _$currentTranslationHash() =>
    r'c87020b0d44938ca7532a1df5ae885085083cdc6';

/// Resolved [Translation] for the current key.
///
/// Copied from [currentTranslation].
@ProviderFor(currentTranslation)
final currentTranslationProvider =
    AutoDisposeFutureProvider<Translation>.internal(
      currentTranslation,
      name: r'currentTranslationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentTranslationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentTranslationRef = AutoDisposeFutureProviderRef<Translation>;
String _$currentBibleDatabaseHash() =>
    r'28580b12a3aa98332d2690a8bb73e55940f936ba';

/// Open connection to the current translation's DB. Re-created (and the old
/// one closed) whenever the translation changes.
///
/// Copied from [currentBibleDatabase].
@ProviderFor(currentBibleDatabase)
final currentBibleDatabaseProvider = FutureProvider<BibleDatabase>.internal(
  currentBibleDatabase,
  name: r'currentBibleDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBibleDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentBibleDatabaseRef = FutureProviderRef<BibleDatabase>;
String _$bibleRepositoryHash() => r'3b2c0fdc9a8b00936ce4107343b1885967ccdef3';

/// See also [bibleRepository].
@ProviderFor(bibleRepository)
final bibleRepositoryProvider = FutureProvider<BibleRepository>.internal(
  bibleRepository,
  name: r'bibleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bibleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BibleRepositoryRef = FutureProviderRef<BibleRepository>;
String _$booksHash() => r'384712f9d19f75db830c4176cda40260049bbe08';

/// See also [books].
@ProviderFor(books)
final booksProvider = AutoDisposeFutureProvider<List<Book>>.internal(
  books,
  name: r'booksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$booksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BooksRef = AutoDisposeFutureProviderRef<List<Book>>;
String _$bookHash() => r'b594788a4e7dcdb6f58b1704d0ee6a03bcffcefb';

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

/// See also [book].
@ProviderFor(book)
const bookProvider = BookFamily();

/// See also [book].
class BookFamily extends Family<AsyncValue<Book?>> {
  /// See also [book].
  const BookFamily();

  /// See also [book].
  BookProvider call(int bookId) {
    return BookProvider(bookId);
  }

  @override
  BookProvider getProviderOverride(covariant BookProvider provider) {
    return call(provider.bookId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookProvider';
}

/// See also [book].
class BookProvider extends AutoDisposeFutureProvider<Book?> {
  /// See also [book].
  BookProvider(int bookId)
    : this._internal(
        (ref) => book(ref as BookRef, bookId),
        from: bookProvider,
        name: r'bookProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookHash,
        dependencies: BookFamily._dependencies,
        allTransitiveDependencies: BookFamily._allTransitiveDependencies,
        bookId: bookId,
      );

  BookProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookId,
  }) : super.internal();

  final int bookId;

  @override
  Override overrideWith(FutureOr<Book?> Function(BookRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: BookProvider._internal(
        (ref) => create(ref as BookRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookId: bookId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Book?> createElement() {
    return _BookProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookProvider && other.bookId == bookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BookRef on AutoDisposeFutureProviderRef<Book?> {
  /// The parameter `bookId` of this provider.
  int get bookId;
}

class _BookProviderElement extends AutoDisposeFutureProviderElement<Book?>
    with BookRef {
  _BookProviderElement(super.provider);

  @override
  int get bookId => (origin as BookProvider).bookId;
}

String _$chapterHash() => r'552646ba3a6cc2701a7ffaf51c3eab753255b530';

/// See also [chapter].
@ProviderFor(chapter)
const chapterProvider = ChapterFamily();

/// See also [chapter].
class ChapterFamily extends Family<AsyncValue<Chapter>> {
  /// See also [chapter].
  const ChapterFamily();

  /// See also [chapter].
  ChapterProvider call(ChapterId id) {
    return ChapterProvider(id);
  }

  @override
  ChapterProvider getProviderOverride(covariant ChapterProvider provider) {
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
  String? get name => r'chapterProvider';
}

/// See also [chapter].
class ChapterProvider extends AutoDisposeFutureProvider<Chapter> {
  /// See also [chapter].
  ChapterProvider(ChapterId id)
    : this._internal(
        (ref) => chapter(ref as ChapterRef, id),
        from: chapterProvider,
        name: r'chapterProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chapterHash,
        dependencies: ChapterFamily._dependencies,
        allTransitiveDependencies: ChapterFamily._allTransitiveDependencies,
        id: id,
      );

  ChapterProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final ChapterId id;

  @override
  Override overrideWith(
    FutureOr<Chapter> Function(ChapterRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterProvider._internal(
        (ref) => create(ref as ChapterRef),
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
  AutoDisposeFutureProviderElement<Chapter> createElement() {
    return _ChapterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterProvider && other.id == id;
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
mixin ChapterRef on AutoDisposeFutureProviderRef<Chapter> {
  /// The parameter `id` of this provider.
  ChapterId get id;
}

class _ChapterProviderElement extends AutoDisposeFutureProviderElement<Chapter>
    with ChapterRef {
  _ChapterProviderElement(super.provider);

  @override
  ChapterId get id => (origin as ChapterProvider).id;
}

String _$currentTranslationKeyHash() =>
    r'06f5a3dc63e20f7d2afc503cde9d51f4645dc02d';

/// The user-selected translation key (`kjv`, `web`, `asv`), persisted.
///
/// Copied from [CurrentTranslationKey].
@ProviderFor(CurrentTranslationKey)
final currentTranslationKeyProvider =
    NotifierProvider<CurrentTranslationKey, String>.internal(
      CurrentTranslationKey.new,
      name: r'currentTranslationKeyProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentTranslationKeyHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentTranslationKey = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
