import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/community_post.dart';
import 'package:myriad/database/community.dart';

// ignore: must_be_immutable
class CommunityComment extends StatelessWidget {
  final String commentId;
  final dynamic data;
  CommunityComment({super.key, required this.commentId, required this.data});

  final CommunityDatabase communityDatabase = CommunityDatabase();

  bool liked = false;

  @override
  Widget build(BuildContext context) {
    final bool likeState =
        (data['likers'].contains(FirebaseAuth.instance.currentUser!.email));
    return Card(
      // color: Theme.of(context).colorScheme.primary,
      margin: EdgeInsets.all(10),
      elevation: 2.0,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PosterData(
                op: data['op'],
                timestamp: data['timestamp'],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['content']),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              communityDatabase.likeCommunityComment(commentId);
                            },
                            child: Icon(
                              likeState
                                  ? Icons.thumb_up_off_alt_rounded
                                  : Icons.thumb_up_off_alt_outlined,
                              color: likeState
                                  ? const Color(0xFF4267B2)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("${data['likes']}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // MyButton(
              //   text: data['likers'].contains(FirebaseAuth.instance.currentUser!.email) ? "-" : "+",
              //   enabled: true,
              //   onTap: () {
              //     //call like function
              //     communityDatabase.likeCommunityComment(commentId);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
