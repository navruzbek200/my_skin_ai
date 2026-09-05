import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/services/local_store.dart';

/// Native Firebase email/password auth plus Google and Apple Sign-In. No Cloud
/// Functions and no backend — everything here runs on the Firebase Auth SDK
/// directly, so it works on the free Spark plan.
abstract class AuthDataSource {
  /// Uid of the signed-in account, or null when nobody is signed in. Read by
  /// the cubit so a sign-up can be marked as one this build created — see
  /// [LocalStore.markGatedSignup].
  String? get currentUid;

  /// Address of the signed-in account, or null when nobody is signed in.
  ///
  /// Behind the interface rather than read from `FirebaseAuth.instance` at the
  /// call site: the cubit needs it, and reaching for the singleton there would
  /// make the cubit untestable without a live Firebase app.
  String? get currentEmail;

  /// True when the signed-in account has Google as its only sign-in provider,
  /// so it re-authenticates through the picker instead of a password.
  bool get isGoogleOnly;

  /// True when this account signed up with a password and has not confirmed
  /// its address yet. Google accounts are excluded: Google already vouched for
  /// the address, and there is no password for a reset link to reach anyway.
  bool get needsEmailVerification;

  Future<void> signIn(String email, String password);
  Future<void> register(String email, String password, String? displayName);
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<void> reauthenticate(String password);
  Future<void> sendPasswordReset(String email);

  /// Mails the verification link to the signed-in address. No-op when the
  /// address is already verified, so a stray tap cannot spam the inbox.
  Future<void> sendEmailVerification();

  /// Re-reads the account from the server and reports whether the address is
  /// confirmed now. The link is opened in a mail client or a browser, so
  /// nothing tells the app about it — the cached user has to be refreshed on
  /// demand.
  Future<bool> refreshEmailVerified();

  /// Returns false when user dismisses the Google account picker (not an error).
  Future<bool> signInWithGoogle();

  /// Re-runs the Google picker to prove ownership before a sensitive action.
  /// Returns false if the user dismisses it.
  Future<bool> reauthenticateWithGoogle();

  // ── Sign in with Apple ────────────────────────────────────────

  /// Whether this device can show the Apple sheet at all. False on Android and
  /// on iOS versions below 13, so the button can be hidden rather than offered
  /// and then failing.
  Future<bool> isAppleSignInAvailable();

  /// True when the signed-in account has Apple as its only sign-in provider,
  /// so it re-authenticates through the Apple sheet instead of a password.
  bool get isAppleOnly;

  /// Returns false when the user dismisses the Apple sheet (not an error).
  ///
  /// Apple hands over the name only on the *first* authorisation for this app,
  /// so it is written onto the Firebase profile there and then — a later
  /// sign-in returns nulls and there would be nothing left to save.
  Future<bool> signInWithApple();

  /// Re-runs the Apple sheet to prove ownership before a sensitive action.
  ///
  /// Returns Apple's single-use `authorizationCode` on success and null when
  /// the user dismisses the sheet. The code is what [revokeAppleToken] needs:
  /// Apple requires the token to be revoked when the account is deleted, and
  /// the code is only valid for a few minutes, so it cannot be fetched ahead
  /// of time and stored.
  Future<String?> reauthenticateWithApple();

  /// Tells Apple to forget this app's authorisation. Required by App Store
  /// Review Guideline 5.1.1(v) for any app offering Sign in with Apple: without
  /// it the app stays listed under Settings → Apple ID → Sign in with Apple
  /// after the account is gone.
  Future<void> revokeAppleToken(String authorizationCode);

  /// True when the person has revoked this app in iOS Settings since they last
  /// signed in. Nothing is pushed to the device when that happens, so it has to
  /// be asked for.
  Future<bool> isAppleCredentialRevoked();
}

class FirebaseAuthDataSource implements AuthDataSource {
  @override
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  String? get currentEmail => FirebaseAuth.instance.currentUser?.email;

  @override
  bool get isGoogleOnly {
    final providers = FirebaseAuth.instance.currentUser?.providerData
            .map((p) => p.providerId) ??
        const Iterable<String>.empty();
    return providers.contains('google.com') && !providers.contains('password');
  }

  @override
  bool get needsEmailVerification {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.emailVerified) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  @override
  Future<void> signIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> register(String email, String password, String? displayName) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null) {
      await cred.user?.updateDisplayName(displayName);
    }
  }

  @override
  Future<void> signOut() async {
    // Three independent teardown steps — logged individually so a failure
    // partway through (Google's own sign-out call is the one most likely to
    // throw on a flaky network) shows exactly which one it was, rather than
    // one opaque "signOut failed" covering all three.
    await GoogleSignIn.instance.signOut();
    AppLogger.info('[Auth] ds.signOut: Google session cleared');
    // Dropped with the session, not kept with the device: the next person to
    // sign in here may be somebody else, and a stale identifier would have the
    // revocation check asking Apple about an account that is no longer ours.
    await LocalStore.instance.clearAppleUserId();
    await FirebaseAuth.instance.signOut();
    AppLogger.info('[Auth] ds.signOut: Firebase session cleared');
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      AppLogger.info('[Auth] ds.signInWithGoogle: opening account picker');
      // google_sign_in v7: singleton + authenticate() (throws on cancel/error).
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        AppLogger.error('[Auth] ds.signInWithGoogle: no idToken on the account');
        return false;
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      AppLogger.info('[Auth] ds.signInWithGoogle: exchanging credential with Firebase');
      await FirebaseAuth.instance.signInWithCredential(credential);
      AppLogger.info('[Auth] ds.signInWithGoogle: Firebase accepted it, uid=${FirebaseAuth.instance.currentUser?.uid}');
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        AppLogger.info('[Auth] ds.signInWithGoogle: picker cancelled');
        return false;
      }
      AppLogger.error('[Auth] ds.signInWithGoogle: GoogleSignInException (${e.code})', e);
      rethrow; // surface real errors to AuthCubit
    }
  }

  // ── Sign in with Apple ────────────────────────────────────────

  /// Scopes asked for on every request. Apple only ever answers them on the
  /// first authorisation, but they have to be asked for every time: dropping
  /// them would mean a person who deleted their account and signed up again
  /// gets no name back on the second first-time.
  static const _appleScopes = [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ];

  @override
  Future<bool> isAppleSignInAvailable() async {
    // Android would fall back to a web flow that needs a Services ID and a
    // redirect URL this project deliberately does not have — Google Sign-In is
    // the third-party option there. Guarded before the plugin call so no
    // MissingPluginException can reach the UI.
    if (!Platform.isIOS && !Platform.isMacOS) {
      AppLogger.info('[Auth] isAppleSignInAvailable: false (not iOS/macOS)');
      return false;
    }
    try {
      final available = await SignInWithApple.isAvailable();
      AppLogger.info('[Auth] isAppleSignInAvailable: $available');
      return available;
    } catch (e, st) {
      AppLogger.error('[Auth] isAppleSignInAvailable: plugin call threw', e, st);
      return false;
    }
  }

  @override
  bool get isAppleOnly {
    final providers = FirebaseAuth.instance.currentUser?.providerData
            .map((p) => p.providerId) ??
        const Iterable<String>.empty();
    return providers.contains('apple.com') && !providers.contains('password');
  }

  @override
  Future<bool> signInWithApple() async {
    try {
      AppLogger.info('[Auth] ds.signInWithApple: requesting Apple ID credential');
      final rawNonce = generateNonce();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: _appleScopes,
        // Apple embeds the *hash* in the identity token; Firebase re-hashes the
        // raw value and compares. Sending the raw nonce to Apple instead would
        // make every sign-in fail with `invalid-credential`.
        nonce: _sha256(rawNonce),
      );
      AppLogger.info(
          '[Auth] ds.signInWithApple: Apple returned a credential (userIdentifier=${credential.userIdentifier}, hasIdentityToken=${credential.identityToken != null}, hasGivenName=${credential.givenName != null})');

      final idToken = credential.identityToken;
      if (idToken == null) {
        // Apple accepted the authorisation but returned no token to prove it
        // with. Nothing the person did causes this, and silently returning
        // "cancelled" would leave them tapping a button that does nothing.
        AppLogger.error('[Auth] ds.signInWithApple: no identityToken');
        throw FirebaseAuthException(
          code: 'apple-no-identity-token',
          message: 'Apple returned no identity token',
        );
      }

      final oauth = _appleCredential(idToken, rawNonce, credential);
      AppLogger.info('[Auth] ds.signInWithApple: exchanging credential with Firebase');
      final result = await FirebaseAuth.instance.signInWithCredential(oauth);
      AppLogger.info('[Auth] ds.signInWithApple: Firebase accepted it, uid=${result.user?.uid}');

      // Kept for the revocation check on later launches — see
      // [isAppleCredentialRevoked].
      final appleUserId = credential.userIdentifier;
      if (appleUserId != null) {
        await LocalStore.instance.setAppleUserId(appleUserId);
      }

      await _applyAppleName(result.user, credential);
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      // `canceled` covers every way the person backs out, the cancel button
      // and the swipe-down alike — that is a decision, not a failure.
      if (e.code == AuthorizationErrorCode.canceled) return false;
      // Everything else is a real fault, and `unknown` is the one that matters
      // most: it is what iOS reports when the entitlement is missing from the
      // signed build or the provisioning profile does not carry the
      // capability. Swallowing it as a cancel leaves a button that visibly
      // does nothing and says nothing, which is the hardest kind of failure to
      // diagnose from a bug report.
      AppLogger.error('[Auth] ds.signInWithApple: authorisation failed (${e.code})', e);
      rethrow;
    }
  }

  /// Writes Apple's name onto the Firebase profile, once.
  ///
  /// Apple returns `givenName`/`familyName` only on the very first
  /// authorisation for this app — every sign-in after that has nulls there,
  /// for ever. Firebase does not capture it on our behalf, so if it is not
  /// saved here it is gone. An existing display name is never overwritten:
  /// the person may have signed in with Google first and linked later, and
  /// their own name should win over a stale one from Apple.
  Future<void> _applyAppleName(
    User? user,
    AuthorizationCredentialAppleID credential,
  ) async {
    if (user == null) return;
    if ((user.displayName ?? '').isNotEmpty) return;
    final name = [credential.givenName, credential.familyName]
        .whereType<String>()
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join(' ');
    if (name.isEmpty) return;
    try {
      await user.updateDisplayName(name);
    } catch (e, st) {
      // Cosmetic. The account exists and the person is signed in; a name that
      // did not stick is not worth failing the sign-in over.
      AppLogger.error('[Auth] applyAppleName: could not save display name', e, st);
    }
  }

  @override
  Future<String?> reauthenticateWithApple() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.info('[Auth] ds.reauthenticateWithApple: no current user');
      return null;
    }
    try {
      AppLogger.info('[Auth] ds.reauthenticateWithApple: requesting Apple ID credential');
      final rawNonce = generateNonce();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: _appleScopes,
        nonce: _sha256(rawNonce),
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        AppLogger.info('[Auth] ds.reauthenticateWithApple: no identityToken');
        return null;
      }
      final oauth = _appleCredential(idToken, rawNonce, credential);
      await user.reauthenticateWithCredential(oauth);
      AppLogger.info('[Auth] ds.reauthenticateWithApple: re-auth ok, authorizationCode obtained');
      return credential.authorizationCode;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Same split as signInWithApple: only an explicit cancel is silent. A
      // fault here matters more, not less — this is the path that deletes an
      // account, and a silent no-op would look identical to a refused
      // deletion.
      if (e.code == AuthorizationErrorCode.canceled) return null;
      AppLogger.error('[Auth] ds.reauthenticateWithApple: authorisation failed (${e.code})', e);
      rethrow;
    }
  }

  @override
  Future<void> revokeAppleToken(String authorizationCode) async {
    AppLogger.info('[Auth] ds.revokeAppleToken: calling Firebase');
    await FirebaseAuth.instance
        .revokeTokenWithAuthorizationCode(authorizationCode);
    AppLogger.info('[Auth] ds.revokeAppleToken: Firebase call returned');
  }

  @override
  Future<bool> isAppleCredentialRevoked() async {
    final appleUserId = LocalStore.instance.appleUserId;
    if (appleUserId == null) {
      AppLogger.info('[Auth] ds.isAppleCredentialRevoked: no stored Apple user id');
      return false;
    }
    if (!Platform.isIOS && !Platform.isMacOS) return false;
    try {
      final state = await SignInWithApple.getCredentialState(appleUserId);
      AppLogger.info('[Auth] ds.isAppleCredentialRevoked: state=$state');
      // `notFound` is deliberately not treated as revoked: it is also what a
      // fresh install or a restored backup reports, and signing somebody out
      // of a working session on that evidence is the worse mistake.
      return state == CredentialState.revoked;
    } catch (e, st) {
      AppLogger.error('[Auth] ds.isAppleCredentialRevoked: check failed', e, st);
      return false;
    }
  }

  /// Hex SHA-256, the encoding Apple expects for the nonce.
  static String _sha256(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  /// Builds the Firebase credential over Apple's *dedicated* path.
  ///
  /// `OAuthProvider('apple.com').credential(...)` looks equivalent and is what
  /// most examples show, but it routes through the plugin's generic OAuth
  /// branch — `credentialWithProviderID:IDToken:rawNonce:accessToken:` with a
  /// nil access token — and Firebase rejects the result as
  /// `invalid-credential` / "Invalid OAuth response from apple.com" even
  /// though the token itself is valid. Verified here: the same token and nonce
  /// were accepted by the Identity Toolkit REST endpoint while the generic
  /// path failed. [AppleAuthProvider.credentialWithIDToken] reaches
  /// `appleCredentialWithIDToken:rawNonce:fullName:`, which is the branch
  /// Apple sign-in actually works on — and it carries the name through, which
  /// Apple only ever sends on the very first authorisation.
  static OAuthCredential _appleCredential(
    String idToken,
    String rawNonce,
    AuthorizationCredentialAppleID credential,
  ) =>
      AppleAuthProvider.credentialWithIDToken(
        idToken,
        rawNonce,
        AppleFullPersonName(
          givenName: credential.givenName,
          familyName: credential.familyName,
        ),
      );

  @override
  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    // Not a no-op. The caller treats a clean return as proof the account is
    // gone: it wipes local data and tells the user so. Returning quietly when
    // there is no session would report a deletion that never happened, and
    // the account would still be sitting on the server.
    if (user == null) throw FirebaseAuthException(code: 'no-current-user');
    await user.delete();
  }

  @override
  Future<bool> reauthenticateWithGoogle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.info('[Auth] ds.reauthenticateWithGoogle: no current user');
      return false;
    }
    try {
      AppLogger.info('[Auth] ds.reauthenticateWithGoogle: opening account picker');
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        AppLogger.error('[Auth] ds.reauthenticateWithGoogle: no idToken on the account');
        return false;
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await user.reauthenticateWithCredential(credential);
      AppLogger.info('[Auth] ds.reauthenticateWithGoogle: re-auth ok');
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        AppLogger.info('[Auth] ds.reauthenticateWithGoogle: picker cancelled');
        return false;
      }
      AppLogger.error('[Auth] ds.reauthenticateWithGoogle: GoogleSignInException (${e.code})', e);
      rethrow;
    }
  }

  @override
  Future<void> reauthenticate(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    // Same reasoning as deleteAccount: silence here reads as "identity
    // confirmed" to the caller, which is the opposite of what happened.
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.emailVerified) return;
    await user.sendEmailVerification();
  }

  @override
  Future<bool> refreshEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    await user.reload();
    // `reload()` refreshes the SDK's copy but leaves this handle stale, so the
    // answer has to be read off the instance rather than off `user`.
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }
}
