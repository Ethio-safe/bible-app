// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'f748b1ea1fffc9e4dacae1bfd1e1cb642ef35838';

/// Google account the user has optionally connected, used to identify them
/// if/when they choose to save or sync data. This is local-only: no data is
/// sent anywhere by connecting an account.
///
/// Copied from [AuthState].
@ProviderFor(AuthState)
final authStateProvider = NotifierProvider<AuthState, AuthUser?>.internal(
  AuthState.new,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthState = Notifier<AuthUser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
