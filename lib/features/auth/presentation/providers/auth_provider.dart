import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/auth_user.dart';

part 'auth_provider.g.dart';

final _googleSignIn = GoogleSignIn(scopes: const ['email']);

String _safePreview(String? value) {
  if (value == null || value.isEmpty) return 'null';
  if (value.length <= 12) return value;
  return '${value.substring(0, 6)}...${value.substring(value.length - 4)}';
}

Future<void> _logGoogleAccountDetails(GoogleSignInAccount? account) async {
  if (account == null) {
    debugPrint('Google sign-in account is null.');
    return;
  }

  final auth = await account.authentication;

  debugPrint('Google account payload: '
      'id=${account.id}, '
      'email=${account.email}, '
      'displayName=${account.displayName}, '
      'photoUrl=${account.photoUrl}, '
      'serverAuthCode=${_safePreview(account.serverAuthCode)}');

  debugPrint('Google auth response: '
      'idTokenPresent=${auth.idToken != null}, '
      'accessTokenPresent=${auth.accessToken != null}, '
      'idTokenPreview=${_safePreview(auth.idToken)}, '
      'accessTokenPreview=${_safePreview(auth.accessToken)}');
}

/// Google account the user has optionally connected, used to identify them
/// if/when they choose to save or sync data. This is local-only: no data is
/// sent anywhere by connecting an account.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  AuthUser? build() {
    final sub = _googleSignIn.onCurrentUserChanged.listen(_onAccountChanged);
    ref.onDispose(sub.cancel);
    _googleSignIn.signInSilently().then((account) async {
      await _logGoogleAccountDetails(account);
      if (account != null) {
        await syncGoogleProfile(
          ref: ref,
          displayName: account.displayName,
          email: account.email,
          photoUrl: account.photoUrl,
        );
      }
    }).catchError((Object error, StackTrace stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'auth_provider',
          context: ErrorDescription('Google sign-in silently failed'),
        ),
      );
      return null;
    });
    return _fromAccount(_googleSignIn.currentUser);
  }

  void _onAccountChanged(GoogleSignInAccount? account) {
    _logGoogleAccountDetails(account);
    if (account == null) {
      ref.read(displayNameProvider.notifier).set('');
      ref.read(profilePhotoUrlProvider.notifier).state = '';
      ref.read(profileEmailProvider.notifier).state = '';
      state = null;
      return;
    }

    unawaited(
      syncGoogleProfile(
        ref: ref,
        displayName: account.displayName,
        email: account.email,
        photoUrl: account.photoUrl,
      ),
    );
    state = _fromAccount(account);
  }

  static AuthUser? _fromAccount(GoogleSignInAccount? account) {
    if (account == null) return null;
    return AuthUser(
      displayName: account.displayName ?? account.email,
      email: account.email,
      photoUrl: account.photoUrl,
    );
  }

  /// Prompts the Google sign-in flow. No-ops if the user cancels.
  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint('Google sign-in was cancelled by the user.');
        return;
      }

      await _logGoogleAccountDetails(account);
      await syncGoogleProfile(
        ref: ref,
        displayName: account.displayName,
        email: account.email,
        photoUrl: account.photoUrl,
      );
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'auth_provider',
          context: ErrorDescription('Google sign-in failed during interactive flow'),
        ),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await ref.read(displayNameProvider.notifier).set('');
    ref.read(profilePhotoUrlProvider.notifier).state = '';
    ref.read(profileEmailProvider.notifier).state = '';
    state = null;
  }
}
