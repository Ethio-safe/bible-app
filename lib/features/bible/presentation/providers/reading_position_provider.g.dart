// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_position_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lastReadChapterHash() => r'410a7541c45895f719cceee3331b8226aa69f2ba';

/// Tracks the chapter the user is currently reading.
///
/// The chapter reference is mirrored to SharedPreferences (synchronous read →
/// used to pick the initial route at startup); the scroll offset lives in the
/// user database, keyed by translation.
///
/// Copied from [LastReadChapter].
@ProviderFor(LastReadChapter)
final lastReadChapterProvider =
    NotifierProvider<LastReadChapter, ChapterId?>.internal(
      LastReadChapter.new,
      name: r'lastReadChapterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lastReadChapterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LastReadChapter = Notifier<ChapterId?>;
String _$scrollPositionSaverHash() =>
    r'd8d19090cff7ce287909604971dc37dd989f1f51';

/// Persists the scroll offset for the current chapter/translation.
///
/// Copied from [ScrollPositionSaver].
@ProviderFor(ScrollPositionSaver)
final scrollPositionSaverProvider =
    NotifierProvider<ScrollPositionSaver, void>.internal(
      ScrollPositionSaver.new,
      name: r'scrollPositionSaverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scrollPositionSaverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ScrollPositionSaver = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
