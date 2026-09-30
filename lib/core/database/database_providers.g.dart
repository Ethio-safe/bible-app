// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assetDbInstallerHash() => r'1b24655efdcc43ebf2917b4ccfe98ecb303b98ad';

/// See also [assetDbInstaller].
@ProviderFor(assetDbInstaller)
final assetDbInstallerProvider = Provider<AssetDbInstaller>.internal(
  assetDbInstaller,
  name: r'assetDbInstallerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$assetDbInstallerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssetDbInstallerRef = ProviderRef<AssetDbInstaller>;
String _$bibleDbDirectoryHash() => r'244ab126578d68b6acb59e6df0992ec10eddd42a';

/// Resolves once the bundled Bible DBs are guaranteed to be on disk.
///
/// Copied from [bibleDbDirectory].
@ProviderFor(bibleDbDirectory)
final bibleDbDirectoryProvider = FutureProvider<Directory>.internal(
  bibleDbDirectory,
  name: r'bibleDbDirectoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bibleDbDirectoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BibleDbDirectoryRef = FutureProviderRef<Directory>;
String _$userDatabaseHash() => r'4c328db0315454caa2ff5e884766ce5eced24ae7';

/// See also [userDatabase].
@ProviderFor(userDatabase)
final userDatabaseProvider = Provider<UserDatabase>.internal(
  userDatabase,
  name: r'userDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserDatabaseRef = ProviderRef<UserDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
