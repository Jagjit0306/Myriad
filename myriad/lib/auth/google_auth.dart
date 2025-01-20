import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myriad/helper/helper_functions.dart';

Future<dynamic> signInWithGoogle(context) async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on Exception catch (e) {
    displayMessageToUser("ERROR WHILE SIGNING IN -> $e", context);
  }
}

Future<bool> signOutFromGoogle() async {
  try {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut(); // Stop remembering last used account;
    return true;
  } on Exception catch (_) {
    return false;
  }
}
