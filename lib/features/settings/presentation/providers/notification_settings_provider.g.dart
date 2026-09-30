// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$votdSchedulerHash() => r'eabb9db2d5a7a0bba8af52bcb89f018cce8c6cbe';

/// See also [votdScheduler].
@ProviderFor(votdScheduler)
final votdSchedulerProvider = Provider<VotdScheduler>.internal(
  votdScheduler,
  name: r'votdSchedulerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$votdSchedulerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VotdSchedulerRef = ProviderRef<VotdScheduler>;
String _$notificationSettingsNotifierHash() =>
    r'f2d0486b2b1bdaf35501ac9bc5a1ad744791ceee';

/// See also [NotificationSettingsNotifier].
@ProviderFor(NotificationSettingsNotifier)
final notificationSettingsNotifierProvider =
    NotifierProvider<
      NotificationSettingsNotifier,
      NotificationSettings
    >.internal(
      NotificationSettingsNotifier.new,
      name: r'notificationSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationSettingsNotifier = Notifier<NotificationSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
