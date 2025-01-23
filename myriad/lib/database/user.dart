import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDatabase {
  final CollectionReference users =
      FirebaseFirestore.instance.collection("Users");

  Future<void> UserCosmeticSync() async {
    final user = await users
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();
    if (user.docs.isNotEmpty) {
      final docId = user.docs.first.id;
      users.doc(docId).update({
        "profileLink": FirebaseAuth.instance.currentUser!.photoURL,
      });
    }
  }
}
