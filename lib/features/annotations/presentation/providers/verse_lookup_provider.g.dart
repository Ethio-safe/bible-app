// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_lookup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$verseLookupHash() => r'2ea44b765763747cedaeaff6cc4c30efafd86876';

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

/// Human-readable reference + text for a verse (or range) in the current
/// translation. Used by "My Stuff" list items.
///
/// Copied from [verseLookup].
@ProviderFor(verseLookup)
const verseLookupProvider = VerseLookupFamily();

/// Human-readable reference + text for a verse (or range) in the current
/// translation. Used by "My Stuff" list items.
///
/// Copied from [verseLookup].
class VerseLookupFamily
    extends Family<AsyncValue<({String reference, String text})>> {
  /// Human-readable reference + text for a verse (or range) in the current
  /// translation. Used by "My Stuff" list items.
  ///
  /// Copied from [verseLookup].
  const VerseLookupFamily();

  /// Human-readable reference + text for a verse (or range) in the current
  /// translation. Used by "My Stuff" list items.
  ///
  /// Copied from [verseLookup].
  VerseLookupProvider call(VerseRef verseRef, {int? verseEnd}) {
    return VerseLookupProvider(verseRef, verseEnd: verseEnd);
  }

  @override
  VerseLookupProvider getProviderOverride(
    covariant VerseLookupProvider provider,
  ) {
    return call(provider.verseRef, verseEnd: provider.verseEnd);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'verseLookupProvider';
}

/// Human-readable reference + text for a verse (or range) in the current
/// translation. Used by "My Stuff" list items.
///
/// Copied from [verseLookup].
class VerseLookupProvider
    extends AutoDisposeFutureProvider<({String reference, String text})> {
  /// Human-readable reference + text for a verse (or range) in the current
  /// translation. Used by "My Stuff" list items.
  ///
  /// Copied from [verseLookup].
  VerseLookupProvider(VerseRef verseRef, {int? verseEnd})
    : this._internal(
        (ref) =>
            verseLookup(ref as VerseLookupRef, verseRef, verseEnd: verseEnd),
        from: verseLookupProvider,
        name: r'verseLookupProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$verseLookupHash,
        dependencies: VerseLookupFamily._dependencies,
        allTransitiveDependencies: VerseLookupFamily._allTransitiveDependencies,
        verseRef: verseRef,
        verseEnd: verseEnd,
      );

  VerseLookupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.verseRef,
    required this.verseEnd,
  }) : super.internal();

  final VerseRef verseRef;
  final int? verseEnd;

  @override
  Override overrideWith(
    FutureOr<({String reference, String text})> Function(
      VerseLookupRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VerseLookupProvider._internal(
        (ref) => create(ref as VerseLookupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        verseRef: verseRef,
        verseEnd: verseEnd,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<({String reference, String text})>
  createElement() {
    return _VerseLookupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VerseLookupProvider &&
        other.verseRef == verseRef &&
        other.verseEnd == verseEnd;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, verseRef.hashCode);
    hash = _SystemHash.combine(hash, verseEnd.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VerseLookupRef
    on AutoDisposeFutureProviderRef<({String reference, String text})> {
  /// The parameter `verseRef` of this provider.
  VerseRef get verseRef;

  /// The parameter `verseEnd` of this provider.
  int? get verseEnd;
}

class _VerseLookupProviderElement
    extends AutoDisposeFutureProviderElement<({String reference, String text})>
    with VerseLookupRef {
  _VerseLookupProviderElement(super.provider);

  @override
  VerseRef get verseRef => (origin as VerseLookupProvider).verseRef;
  @override
  int? get verseEnd => (origin as VerseLookupProvider).verseEnd;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
