import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  static Future<User?> loginGoogle() async {
    final googleAccount = await GoogleSignIn().signIn();

    if (googleAccount == null) {
      // El usuario canceló el inicio de sesión
      return null;
    }

    final googleAuth = await googleAccount.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    return userCredential.user;
  }
}
