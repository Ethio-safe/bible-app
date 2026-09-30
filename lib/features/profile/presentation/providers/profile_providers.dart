import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/preferences_provider.dart';

part 'profile_providers.g.dart';

const _profilePhotoUrlKey = 'profile_photo_url';
const _profileEmailKey = 'profile_email';

final profilePhotoUrlProvider = StateProvider<String>((ref) {
  return ref.watch(sharedPreferencesProvider).getString(_profilePhotoUrlKey) ?? '';
});

final profileEmailProvider = StateProvider<String>((ref) {
  return ref.watch(sharedPreferencesProvider).getString(_profileEmailKey) ?? '';
});

Future<void> syncGoogleProfile({
  required Ref ref,
  required String? displayName,
  required String? email,
  required String? photoUrl,
}) async {
  final prefs = ref.read(sharedPreferencesProvider);

  final nextDisplayName = (displayName ?? '').trim();
  if (nextDisplayName.isNotEmpty) {
    await ref.read(displayNameProvider.notifier).set(nextDisplayName);
  } else if ((email ?? '').trim().isNotEmpty) {
    await ref.read(displayNameProvider.notifier).set(email!);
  }

  final nextEmail = (email ?? '').trim();
  if (nextEmail.isNotEmpty) {
    await prefs.setString(_profileEmailKey, nextEmail);
    ref.read(profileEmailProvider.notifier).state = nextEmail;
  } else {
    await prefs.remove(_profileEmailKey);
    ref.read(profileEmailProvider.notifier).state = '';
  }

  final nextPhotoUrl = (photoUrl ?? '').trim();
  if (nextPhotoUrl.isNotEmpty) {
    await prefs.setString(_profilePhotoUrlKey, nextPhotoUrl);
    ref.read(profilePhotoUrlProvider.notifier).state = nextPhotoUrl;
  } else {
    await prefs.remove(_profilePhotoUrlKey);
    ref.read(profilePhotoUrlProvider.notifier).state = '';
  }
}

/// Display name shown in greetings and on the You tab.
@Riverpod(keepAlive: true)
class DisplayName extends _$DisplayName {
  static const _key = 'profile_name';

  @override
  String build() => ref.watch(sharedPreferencesProvider).getString(_key) ?? '';

  Future<void> set(String name) async {
    final trimmed = name.trim();
    state = trimmed;
    final p = ref.read(sharedPreferencesProvider);
    if (trimmed.isEmpty) {
      await p.remove(_key);
    } else {
      await p.setString(_key, trimmed);
    }
  }
}

/// Time-of-day greeting, e.g. "Good Morning".
String greetingFor(DateTime now) {
  final h = now.hour;
  if (h < 12) return 'Good Morning';
  if (h < 17) return 'Good Afternoon';
  return 'Good Evening';
}
