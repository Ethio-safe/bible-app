/// Minimal representation of a signed-in Google account.
class AuthUser {
  const AuthUser({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  final String displayName;
  final String email;
  final String? photoUrl;
}
