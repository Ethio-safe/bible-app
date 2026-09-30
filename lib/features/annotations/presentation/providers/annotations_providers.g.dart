// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotations_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$annotationsRepositoryHash() =>
    r'88cc03d433a9f2fc9f21a78aaf84c8439f985a49';

/// See also [annotationsRepository].
@ProviderFor(annotationsRepository)
final annotationsRepositoryProvider = Provider<AnnotationsRepository>.internal(
  annotationsRepository,
  name: r'annotationsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$annotationsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnnotationsRepositoryRef = ProviderRef<AnnotationsRepository>;
String _$chapterHighlightsHash() => r'352be2daa8491d30f4e7bb7ab7300856286dc050';

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

/// See also [chapterHighlights].
@ProviderFor(chapterHighlights)
const chapterHighlightsProvider = ChapterHighlightsFamily();

/// See also [chapterHighlights].
class ChapterHighlightsFamily extends Family<AsyncValue<List<Highlight>>> {
  /// See also [chapterHighlights].
  const ChapterHighlightsFamily();

  /// See also [chapterHighlights].
  ChapterHighlightsProvider call(ChapterId id) {
    return ChapterHighlightsProvider(id);
  }

  @override
  ChapterHighlightsProvider getProviderOverride(
    covariant ChapterHighlightsProvider provider,
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
  String? get name => r'chapterHighlightsProvider';
}

/// See also [chapterHighlights].
class ChapterHighlightsProvider
    extends AutoDisposeStreamProvider<List<Highlight>> {
  /// See also [chapterHighlights].
  ChapterHighlightsProvider(ChapterId id)
    : this._internal(
        (ref) => chapterHighlights(ref as ChapterHighlightsRef, id),
        from: chapterHighlightsProvider,
        name: r'chapterHighlightsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chapterHighlightsHash,
        dependencies: ChapterHighlightsFamily._dependencies,
        allTransitiveDependencies:
            ChapterHighlightsFamily._allTransitiveDependencies,
        id: id,
      );

  ChapterHighlightsProvider._internal(
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
    Stream<List<Highlight>> Function(ChapterHighlightsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterHighlightsProvider._internal(
        (ref) => create(ref as ChapterHighlightsRef),
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
  AutoDisposeStreamProviderElement<List<Highlight>> createElement() {
    return _ChapterHighlightsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterHighlightsProvider && other.id == id;
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
mixin ChapterHighlightsRef on AutoDisposeStreamProviderRef<List<Highlight>> {
  /// The parameter `id` of this provider.
  ChapterId get id;
}

class _ChapterHighlightsProviderElement
    extends AutoDisposeStreamProviderElement<List<Highlight>>
    with ChapterHighlightsRef {
  _ChapterHighlightsProviderElement(super.provider);

  @override
  ChapterId get id => (origin as ChapterHighlightsProvider).id;
}

String _$chapterBookmarksHash() => r'12d98e632a879f7167539e6ecf355d8232c7eac6';

/// See also [chapterBookmarks].
@ProviderFor(chapterBookmarks)
const chapterBookmarksProvider = ChapterBookmarksFamily();

/// See also [chapterBookmarks].
class ChapterBookmarksFamily extends Family<AsyncValue<List<Bookmark>>> {
  /// See also [chapterBookmarks].
  const ChapterBookmarksFamily();

  /// See also [chapterBookmarks].
  ChapterBookmarksProvider call(ChapterId id) {
    return ChapterBookmarksProvider(id);
  }

  @override
  ChapterBookmarksProvider getProviderOverride(
    covariant ChapterBookmarksProvider provider,
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
  String? get name => r'chapterBookmarksProvider';
}

/// See also [chapterBookmarks].
class ChapterBookmarksProvider
    extends AutoDisposeStreamProvider<List<Bookmark>> {
  /// See also [chapterBookmarks].
  ChapterBookmarksProvider(ChapterId id)
    : this._internal(
        (ref) => chapterBookmarks(ref as ChapterBookmarksRef, id),
        from: chapterBookmarksProvider,
        name: r'chapterBookmarksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chapterBookmarksHash,
        dependencies: ChapterBookmarksFamily._dependencies,
        allTransitiveDependencies:
            ChapterBookmarksFamily._allTransitiveDependencies,
        id: id,
      );

  ChapterBookmarksProvider._internal(
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
    Stream<List<Bookmark>> Function(ChapterBookmarksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterBookmarksProvider._internal(
        (ref) => create(ref as ChapterBookmarksRef),
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
  AutoDisposeStreamProviderElement<List<Bookmark>> createElement() {
    return _ChapterBookmarksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterBookmarksProvider && other.id == id;
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
mixin ChapterBookmarksRef on AutoDisposeStreamProviderRef<List<Bookmark>> {
  /// The parameter `id` of this provider.
  ChapterId get id;
}

class _ChapterBookmarksProviderElement
    extends AutoDisposeStreamProviderElement<List<Bookmark>>
    with ChapterBookmarksRef {
  _ChapterBookmarksProviderElement(super.provider);

  @override
  ChapterId get id => (origin as ChapterBookmarksProvider).id;
}

String _$chapterNotesHash() => r'78e3249cb773a148de70af0ec6637b677eb2127d';

/// See also [chapterNotes].
@ProviderFor(chapterNotes)
const chapterNotesProvider = ChapterNotesFamily();

/// See also [chapterNotes].
class ChapterNotesFamily extends Family<AsyncValue<List<Note>>> {
  /// See also [chapterNotes].
  const ChapterNotesFamily();

  /// See also [chapterNotes].
  ChapterNotesProvider call(ChapterId id) {
    return ChapterNotesProvider(id);
  }

  @override
  ChapterNotesProvider getProviderOverride(
    covariant ChapterNotesProvider provider,
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
  String? get name => r'chapterNotesProvider';
}

/// See also [chapterNotes].
class ChapterNotesProvider extends AutoDisposeStreamProvider<List<Note>> {
  /// See also [chapterNotes].
  ChapterNotesProvider(ChapterId id)
    : this._internal(
        (ref) => chapterNotes(ref as ChapterNotesRef, id),
        from: chapterNotesProvider,
        name: r'chapterNotesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chapterNotesHash,
        dependencies: ChapterNotesFamily._dependencies,
        allTransitiveDependencies:
            ChapterNotesFamily._allTransitiveDependencies,
        id: id,
      );

  ChapterNotesProvider._internal(
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
    Stream<List<Note>> Function(ChapterNotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterNotesProvider._internal(
        (ref) => create(ref as ChapterNotesRef),
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
  AutoDisposeStreamProviderElement<List<Note>> createElement() {
    return _ChapterNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterNotesProvider && other.id == id;
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
mixin ChapterNotesRef on AutoDisposeStreamProviderRef<List<Note>> {
  /// The parameter `id` of this provider.
  ChapterId get id;
}

class _ChapterNotesProviderElement
    extends AutoDisposeStreamProviderElement<List<Note>>
    with ChapterNotesRef {
  _ChapterNotesProviderElement(super.provider);

  @override
  ChapterId get id => (origin as ChapterNotesProvider).id;
}

String _$allHighlightsHash() => r'270a55b942273e4a4047acba641cb0f8bc0f524e';

/// See also [allHighlights].
@ProviderFor(allHighlights)
final allHighlightsProvider =
    AutoDisposeStreamProvider<List<Highlight>>.internal(
      allHighlights,
      name: r'allHighlightsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allHighlightsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllHighlightsRef = AutoDisposeStreamProviderRef<List<Highlight>>;
String _$allBookmarksHash() => r'0f04163613910797bed6d560b2d8ebad38d33e97';

/// See also [allBookmarks].
@ProviderFor(allBookmarks)
final allBookmarksProvider = AutoDisposeStreamProvider<List<Bookmark>>.internal(
  allBookmarks,
  name: r'allBookmarksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allBookmarksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllBookmarksRef = AutoDisposeStreamProviderRef<List<Bookmark>>;
String _$allNotesHash() => r'b152eb1a6de9da8d37fe24f0c59994c0c2896b36';

/// See also [allNotes].
@ProviderFor(allNotes)
final allNotesProvider = AutoDisposeStreamProvider<List<Note>>.internal(
  allNotes,
  name: r'allNotesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllNotesRef = AutoDisposeStreamProviderRef<List<Note>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
