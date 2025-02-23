/*

  POSTS -> Title, Content, Image, Likes, Likers, postId, OP, Timestamp

  COMMENTS -> Content, OP, postId, Timestamp, Likes, Likers

*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityDatabase {
  User? currentUser = FirebaseAuth.instance.currentUser;

  final CollectionReference communityPosts =
      FirebaseFirestore.instance.collection('CommunityPosts');

  Future<void> addCommunityPost(
      String title, String content, List<dynamic> prefs) async {
    final you = await FirebaseFirestore.instance
        .collection("Users")
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();
    if (you.docs.isNotEmpty) {
      communityPosts.add({
        "title": title,
        "content": content,
        "timestamp": Timestamp.now(),
        "op": you.docs.first.id,
        'likes': 0,
        'likers': [],
        'categories': prefs
            .where((map) => map.values.first == true)
            .map((map) => map.keys.first)
            .toList(),
      });
    }
  }

  Future<void> deleteCommunityPost(String postId) async {
      await FirebaseFirestore.instance.collection('CommunityPosts').doc(postId).delete();


      var commentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }
  }

  Future<void> updateCommunityPost(
      String postId, String title, String content) async {
    await communityPosts.doc(postId).update({
      "title": title,
      "content": content,
    });
  }

  Future<void> likeCommunityPost(String postId) async {
    try {
      final String? currUserEmail = currentUser?.email;
      final currPost = communityPosts.doc(postId);
      final currPostSnapshot = await currPost.get();
      final currPostData =
          currPostSnapshot.data() as Map<String, dynamic>?; // Cast the data
      final currPostLikers =
          currPostData?['likers'] ?? []; // Safely access 'likers' field

      if (currPostLikers.contains(currUserEmail)) {
        // unlike the post
        currPost.update({
          "likes": FieldValue.increment(-1),
          "likers": FieldValue.arrayRemove([currUserEmail])
        });
      } else {
        // like the post
        currPost.update({
          "likes": FieldValue.increment(1),
          "likers": FieldValue.arrayUnion([currUserEmail]),
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  Stream<QuerySnapshot> getCommunityPostsStream() {
    final communityPostsStream =
        communityPosts.orderBy('timestamp', descending: true).snapshots();

    return communityPostsStream;
  }

  Stream<DocumentSnapshot> getCommunityPostStream(String postId) {
    return communityPosts.doc(postId).snapshots();
  }

  final CollectionReference communityComments =
      FirebaseFirestore.instance.collection("CommunityComments");

  Future<void> addCommunityComment(String postId, String content) async {
    await communityComments.add({
      "content": content,
      "op": currentUser?.email,
      "likes": 0,
      "likers": [],
      "timestamp": Timestamp.now(),
      "postId": postId,
    });
  }

  Future<void> likeCommunityComment(String commentId) async {
    try {
      final String? currUserEmail = currentUser?.email;
      final currComment = communityComments.doc(commentId);
      final currCommentSnapshot = await currComment.get();
      final currCommentData =
          currCommentSnapshot.data() as Map<String, dynamic>?; // Cast the data
      final currCommentLikers =
          currCommentData?['likers'] ?? []; // Safely access 'likers' field

      if (currCommentLikers.contains(currUserEmail)) {
        // unlike the post
        currComment.update({
          "likes": FieldValue.increment(-1),
          "likers": FieldValue.arrayRemove([currUserEmail])
        });
      } else {
        // like the post
        currComment.update({
          "likes": FieldValue.increment(1),
          "likers": FieldValue.arrayUnion([currUserEmail]),
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  Stream<QuerySnapshot> getCommunityCommentsStream(String postId) {
  return communityComments
      .where('postId', isEqualTo: postId)
      .orderBy('timestamp', descending: true)
      .snapshots();
}

Stream<QuerySnapshot> getUserPostsStream(String userEmail) {
  return communityPosts
      .where('op', isEqualTo: userEmail)
      .orderBy('timestamp', descending: true)
      .snapshots();
}

Future<void> followUser(String targetUserEmail) async {
  final String? currentUserEmail = currentUser?.email;
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
  final String? currentUserEmail = currentUser?.email;
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
  final String? currentUserEmail = currentUser?.email;
  if (currentUserEmail == null) return false;
  final userDoc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUserEmail)
      .get();
  final following = (userDoc.data()?['following'] ?? []) as List;
  return following.contains(targetUserEmail);
}
}
