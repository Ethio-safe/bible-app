// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'votd_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resolvePoolVerseHash() => r'29ef8615f0173b42b77259d4e40fb6660be81e71';

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

/// Resolves a [PoolVerse] to text using the current translation.
///
/// Copied from [resolvePoolVerse].
@ProviderFor(resolvePoolVerse)
const resolvePoolVerseProvider = ResolvePoolVerseFamily();

/// Resolves a [PoolVerse] to text using the current translation.
///
/// Copied from [resolvePoolVerse].
class ResolvePoolVerseFamily extends Family<AsyncValue<DailyVerse>> {
  /// Resolves a [PoolVerse] to text using the current translation.
  ///
  /// Copied from [resolvePoolVerse].
  const ResolvePoolVerseFamily();

  /// Resolves a [PoolVerse] to text using the current translation.
  ///
  /// Copied from [resolvePoolVerse].
  ResolvePoolVerseProvider call(PoolVerse pool) {
    return ResolvePoolVerseProvider(pool);
  }

  @override
  ResolvePoolVerseProvider getProviderOverride(
    covariant ResolvePoolVerseProvider provider,
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
  String? get name => r'resolvePoolVerseProvider';
}

/// Resolves a [PoolVerse] to text using the current translation.
///
/// Copied from [resolvePoolVerse].
class ResolvePoolVerseProvider extends AutoDisposeFutureProvider<DailyVerse> {
  /// Resolves a [PoolVerse] to text using the current translation.
  ///
  /// Copied from [resolvePoolVerse].
  ResolvePoolVerseProvider(PoolVerse pool)
    : this._internal(
        (ref) => resolvePoolVerse(ref as ResolvePoolVerseRef, pool),
        from: resolvePoolVerseProvider,
        name: r'resolvePoolVerseProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$resolvePoolVerseHash,
        dependencies: ResolvePoolVerseFamily._dependencies,
        allTransitiveDependencies:
            ResolvePoolVerseFamily._allTransitiveDependencies,
        pool: pool,
      );

  ResolvePoolVerseProvider._internal(
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
    FutureOr<DailyVerse> Function(ResolvePoolVerseRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResolvePoolVerseProvider._internal(
        (ref) => create(ref as ResolvePoolVerseRef),
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
  AutoDisposeFutureProviderElement<DailyVerse> createElement() {
    return _ResolvePoolVerseProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResolvePoolVerseProvider && other.pool == pool;
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
mixin ResolvePoolVerseRef on AutoDisposeFutureProviderRef<DailyVerse> {
  /// The parameter `pool` of this provider.
  PoolVerse get pool;
}

class _ResolvePoolVerseProviderElement
    extends AutoDisposeFutureProviderElement<DailyVerse>
    with ResolvePoolVerseRef {
  _ResolvePoolVerseProviderElement(super.provider);

  @override
  PoolVerse get pool => (origin as ResolvePoolVerseProvider).pool;
}

String _$recentVersesOfTheDayHash() =>
    r'9d3b55f3bd2db498e6afce75ca85722733f687af';

/// The verse shown [daysAgo] days before today (0 = today) plus its date —
/// powers the notification history screen.
///
/// Copied from [recentVersesOfTheDay].
@ProviderFor(recentVersesOfTheDay)
const recentVersesOfTheDayProvider = RecentVersesOfTheDayFamily();

/// The verse shown [daysAgo] days before today (0 = today) plus its date —
/// powers the notification history screen.
///
/// Copied from [recentVersesOfTheDay].
class RecentVersesOfTheDayFamily
    extends Family<AsyncValue<List<({DateTime day, DailyVerse verse})>>> {
  /// The verse shown [daysAgo] days before today (0 = today) plus its date —
  /// powers the notification history screen.
  ///
  /// Copied from [recentVersesOfTheDay].
  const RecentVersesOfTheDayFamily();

  /// The verse shown [daysAgo] days before today (0 = today) plus its date —
  /// powers the notification history screen.
  ///
  /// Copied from [recentVersesOfTheDay].
  RecentVersesOfTheDayProvider call(int count) {
    return RecentVersesOfTheDayProvider(count);
  }

  @override
  RecentVersesOfTheDayProvider getProviderOverride(
    covariant RecentVersesOfTheDayProvider provider,
  ) {
    return call(provider.count);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentVersesOfTheDayProvider';
}

/// The verse shown [daysAgo] days before today (0 = today) plus its date —
/// powers the notification history screen.
///
/// Copied from [recentVersesOfTheDay].
class RecentVersesOfTheDayProvider
    extends
        AutoDisposeFutureProvider<List<({DateTime day, DailyVerse verse})>> {
  /// The verse shown [daysAgo] days before today (0 = today) plus its date —
  /// powers the notification history screen.
  ///
  /// Copied from [recentVersesOfTheDay].
  RecentVersesOfTheDayProvider(int count)
    : this._internal(
        (ref) => recentVersesOfTheDay(ref as RecentVersesOfTheDayRef, count),
        from: recentVersesOfTheDayProvider,
        name: r'recentVersesOfTheDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentVersesOfTheDayHash,
        dependencies: RecentVersesOfTheDayFamily._dependencies,
        allTransitiveDependencies:
            RecentVersesOfTheDayFamily._allTransitiveDependencies,
        count: count,
      );

  RecentVersesOfTheDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.count,
  }) : super.internal();

  final int count;

  @override
  Override overrideWith(
    FutureOr<List<({DateTime day, DailyVerse verse})>> Function(
      RecentVersesOfTheDayRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentVersesOfTheDayProvider._internal(
        (ref) => create(ref as RecentVersesOfTheDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        count: count,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<({DateTime day, DailyVerse verse})>>
  createElement() {
    return _RecentVersesOfTheDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentVersesOfTheDayProvider && other.count == count;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, count.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentVersesOfTheDayRef
    on AutoDisposeFutureProviderRef<List<({DateTime day, DailyVerse verse})>> {
  /// The parameter `count` of this provider.
  int get count;
}

class _RecentVersesOfTheDayProviderElement
    extends
        AutoDisposeFutureProviderElement<
          List<({DateTime day, DailyVerse verse})>
        >
    with RecentVersesOfTheDayRef {
  _RecentVersesOfTheDayProviderElement(super.provider);

  @override
  int get count => (origin as RecentVersesOfTheDayProvider).count;
}

String _$verseOfTheDayHash() => r'1fc019c79e7c1c9582a7fede5eb6bfbdf2426fea';

/// Today's verse (local calendar day). Also refreshes the OS home/lock-screen
/// widget so it shows today's verse even when automation is off.
///
/// Copied from [verseOfTheDay].
@ProviderFor(verseOfTheDay)
final verseOfTheDayProvider = AutoDisposeFutureProvider<DailyVerse>.internal(
  verseOfTheDay,
  name: r'verseOfTheDayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$verseOfTheDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VerseOfTheDayRef = AutoDisposeFutureProviderRef<DailyVerse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
