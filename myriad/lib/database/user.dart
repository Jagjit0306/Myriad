import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDatabase {
  final CollectionReference users =
      FirebaseFirestore.instance.collection("Users");

  Future<void> userCosmeticSync() async {
    final user = await users
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();
    if (user.docs.isNotEmpty) {
      final docId = user.docs.first.id;
      users.doc(docId).update({
        "profileLink": FirebaseAuth.instance.currentUser!.photoURL,
        "bio": FirebaseAuth.instance.currentUser!.displayName,
      });
    }
  }

  Future<String?> getGuardianNumber() async {
    final QuerySnapshot user = await users
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();
    if (user.docs.isNotEmpty) {
      return user.docs.first['guardianPhone'];
    }
    return null;
  }

  Future<List<dynamic>?> getConfig() async {
    final QuerySnapshot user = await users
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();
    if (user.docs.isNotEmpty) {
      return user.docs.first['prefs'] as List<dynamic>;
    }
    return null;
  }
Future<void> followUser(String targetUserEmail) async {
  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserEmail == null) return;

  final userRef = FirebaseFirestore.instance.collection('Users');
  await userRef.doc(currentUserEmail).update({
    'following': FieldValue.arrayUnion([targetUserEmail])
  });
  await userRef.doc(targetUserEmail).update({
    'followers': FieldValue.arrayUnion([currentUserEmail])
  });
}

Future<void> unfollowUser(String targetUserEmail) async {
  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserEmail == null) return;

  final userRef = FirebaseFirestore.instance.collection('Users');
  await userRef.doc(currentUserEmail).update({
    'following': FieldValue.arrayRemove([targetUserEmail])
  });
  await userRef.doc(targetUserEmail).update({
    'followers': FieldValue.arrayRemove([currentUserEmail])
  });
}

Future<bool> isFollowing(String targetUserEmail) async {
  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserEmail == null) return false;
  final userDoc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUserEmail)
      .get();
  final following = (userDoc.data()?['following'] ?? []) as List;
  return following.contains(targetUserEmail);
}
}
