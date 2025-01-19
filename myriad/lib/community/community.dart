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

  Future<void> addCommunityPost(String title, String content) async {
    communityPosts.add({
      "title": title,
      "content": content,
      "timestamp": Timestamp.now(),
      "op": currentUser?.email,
      'likes': 0,
      'likers': [],
      // 'postId': "$userEmail[P]${Timestamp.now()}",
    });
  }

  Future<void> deleteCommunityPost(String postId) async {
    await communityPosts.doc(postId).delete();
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
      print(e);
    }
  }

  Stream<QuerySnapshot> getCommunityPostsStream() {
    final communityPostsStream =
        communityPosts.orderBy('timestamp', descending: true).snapshots();

    return communityPostsStream;
  }
}
