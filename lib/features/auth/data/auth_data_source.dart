import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Native Firebase email/password auth plus Google Sign-In. No Cloud Functions
/// and no backend — everything here runs on the Firebase Auth SDK directly, so
/// it works on the free Spark plan.
abstract class AuthDataSource {
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

  /// Returns false when user dismisses the Google account picker (not an error).
  Future<bool> signInWithGoogle();

  /// Re-runs the Google picker to prove ownership before a sensitive action.
  /// Returns false if the user dismisses it.
  Future<bool> reauthenticateWithGoogle();
}

class FirebaseAuthDataSource implements AuthDataSource {
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
    // Clear Google session so the account picker shows on next sign-in.
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      // google_sign_in v7: singleton + authenticate() (throws on cancel/error).
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return false;
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow; // surface real errors to AuthCubit
    }
  }

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
    if (user == null) return false;
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return false;
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await user.reauthenticateWithCredential(credential);
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
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
}
