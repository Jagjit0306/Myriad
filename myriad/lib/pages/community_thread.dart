import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/community/community.dart';
import 'package:myriad/components/my_button.dart';

class CommunityThread extends StatelessWidget {
  final String title;
  final String postId;

  CommunityThread({super.key, required this.title, required this.postId});

  final CommunityDatabase communityDatabase = CommunityDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: [
            StreamBuilder(
              stream: communityDatabase.getCommunityPostStream(postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data != null) {
                  DocumentSnapshot postData = snapshot.data!;
                  if (postData.exists) {
                    return Column(
                      children: [
                        Text(postData['title']),
                        Text(postData['content']),
                        Text(postData['op']),
                        Text("LIKES -> ${postData['likes']}"),
                        Text(jsonEncode(postData['likers'])),
                        // MyButton(
                        //   text: (postData is List &&
                        //           postData['likers'].contains(
                        //               FirebaseAuth.instance.currentUser!.email))
                        //       ? "UNLIKE"
                        //       : "LIKE",
                        //   onTap: () {
                        //     communityDatabase.likeCommunityPost(postId);
                        //   },
                        // ),
                        CommunityThreadLikeButton(
                          postId: postId,
                          likers: postData['likers'],
                          communityDatabase: communityDatabase,
                        ),
                        CommunityThreadDeleteButton(
                            currUser: postData['op'],
                            postId: postId,
                            communityDatabase: communityDatabase),
                      ],
                    );
                  } else {
                    return Text("Post not found");
                  }
                } else {
                  return Text("Post not found");
                }
              },
            ),
            Text("COMMMENTS TO BE IMPLEMENTED SOON"),
          ],
        ));
  }
}

class CommunityThreadLikeButton extends StatefulWidget {
  final String postId;
  final List likers;
  final CommunityDatabase communityDatabase;
  const CommunityThreadLikeButton(
      {super.key,
      required this.postId,
      required this.likers,
      required this.communityDatabase});

  @override
  State<CommunityThreadLikeButton> createState() =>
      _CommunityThreadLikeButtonState();
}

class _CommunityThreadLikeButtonState extends State<CommunityThreadLikeButton> {
  bool liked = false;

  @override
  void initState() {
    super.initState();
    if (widget.likers.contains(FirebaseAuth.instance.currentUser!.email)) {
      setState(() {
        liked = true;
      });
    } else {
      setState(() {
        liked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyButton(
      text: liked ? "UNLIKE" : "LIKE",
      onTap: () {
        widget.communityDatabase.likeCommunityPost(widget.postId);
        setState(() {
          liked = !liked;
        });
      },
      enabled: true,
    );
  }
}

class CommunityThreadDeleteButton extends StatefulWidget {
  final String currUser;
  final String postId;
  final CommunityDatabase communityDatabase;
  const CommunityThreadDeleteButton(
      {super.key,
      required this.currUser,
      required this.postId,
      required this.communityDatabase});

  @override
  State<CommunityThreadDeleteButton> createState() =>
      _CommunityThreadDeleteButtonState();
}

class _CommunityThreadDeleteButtonState
    extends State<CommunityThreadDeleteButton> {
  bool isOP = false;

  @override
  void initState() {
    super.initState();

    if (!isOP && widget.currUser == FirebaseAuth.instance.currentUser!.email) {
      setState(() {
        isOP = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isOP
        ? MyButton(
            text: "Delete",
            onTap: () {
              widget.communityDatabase.deleteCommunityPost(widget.postId);
              Navigator.pop(context);
            },
            enabled: true,
          )
        : Container();
  }
}
