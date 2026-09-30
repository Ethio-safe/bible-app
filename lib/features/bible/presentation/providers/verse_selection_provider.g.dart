// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$verseSelectionHash() => r'3288864b65d4fb6534f3b175dcd695f9de0cb8ee';

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

abstract class _$VerseSelection extends BuildlessAutoDisposeNotifier<Set<int>> {
  late final ChapterId id;

  Set<int> build(ChapterId id);
}

/// Verses currently selected in a chapter (verse numbers). Scoped per chapter
/// so swiping to another page starts with an empty selection.
///
/// Copied from [VerseSelection].
@ProviderFor(VerseSelection)
const verseSelectionProvider = VerseSelectionFamily();

/// Verses currently selected in a chapter (verse numbers). Scoped per chapter
/// so swiping to another page starts with an empty selection.
///
/// Copied from [VerseSelection].
class VerseSelectionFamily extends Family<Set<int>> {
  /// Verses currently selected in a chapter (verse numbers). Scoped per chapter
  /// so swiping to another page starts with an empty selection.
  ///
  /// Copied from [VerseSelection].
  const VerseSelectionFamily();

  /// Verses currently selected in a chapter (verse numbers). Scoped per chapter
  /// so swiping to another page starts with an empty selection.
  ///
  /// Copied from [VerseSelection].
  VerseSelectionProvider call(ChapterId id) {
    return VerseSelectionProvider(id);
  }

  @override
  VerseSelectionProvider getProviderOverride(
    covariant VerseSelectionProvider provider,
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
  String? get name => r'verseSelectionProvider';
}

/// Verses currently selected in a chapter (verse numbers). Scoped per chapter
/// so swiping to another page starts with an empty selection.
///
/// Copied from [VerseSelection].
class VerseSelectionProvider
    extends AutoDisposeNotifierProviderImpl<VerseSelection, Set<int>> {
  /// Verses currently selected in a chapter (verse numbers). Scoped per chapter
  /// so swiping to another page starts with an empty selection.
  ///
  /// Copied from [VerseSelection].
  VerseSelectionProvider(ChapterId id)
    : this._internal(
        () => VerseSelection()..id = id,
        from: verseSelectionProvider,
        name: r'verseSelectionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$verseSelectionHash,
        dependencies: VerseSelectionFamily._dependencies,
        allTransitiveDependencies:
            VerseSelectionFamily._allTransitiveDependencies,
        id: id,
      );

  VerseSelectionProvider._internal(
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
  Set<int> runNotifierBuild(covariant VerseSelection notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(VerseSelection Function() create) {
    return ProviderOverride(
      origin: this,
      override: VerseSelectionProvider._internal(
        () => create()..id = id,
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
  AutoDisposeNotifierProviderElement<VerseSelection, Set<int>> createElement() {
    return _VerseSelectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VerseSelectionProvider && other.id == id;
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
mixin VerseSelectionRef on AutoDisposeNotifierProviderRef<Set<int>> {
  /// The parameter `id` of this provider.
  ChapterId get id;
}

class _VerseSelectionProviderElement
    extends AutoDisposeNotifierProviderElement<VerseSelection, Set<int>>
    with VerseSelectionRef {
  _VerseSelectionProviderElement(super.provider);

  @override
  ChapterId get id => (origin as VerseSelectionProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
