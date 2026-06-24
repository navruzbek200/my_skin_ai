import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthDataSource {
  Future<void> signIn(String email, String password);
  Future<void> register(String email, String password, String? displayName);
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<void> reauthenticate(String password);
  Future<void> sendPasswordReset(String email);
  /// Returns false when user dismisses the Google account picker (not an error).
  Future<bool> signInWithGoogle();
}

class FirebaseAuthDataSource implements AuthDataSource {
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
    await FirebaseAuth.instance.currentUser?.delete();
  }

  @override
  Future<void> reauthenticate(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
