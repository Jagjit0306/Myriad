import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/community/community.dart';
import 'package:myriad/components/my_button.dart';

class CommunityComment extends StatelessWidget {
  final String commentId;
  final dynamic data;
  CommunityComment({super.key, required this.commentId, required this.data});

  final CommunityDatabase communityDatabase = CommunityDatabase();

  bool liked = false;


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      margin: EdgeInsets.all(10),
      elevation: 2.0,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Text(data['content']),
            Text("Likes -> ${data['likes']}"),
            MyButton(
              text: data['likers'].contains(FirebaseAuth.instance.currentUser!.email) ? "-" : "+",
              enabled: true,
              onTap: () {
                //call like function
                communityDatabase.likeCommunityComment(commentId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
