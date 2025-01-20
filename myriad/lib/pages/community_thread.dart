import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/community/community.dart';
import 'package:myriad/components/community_comment.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/pages/community_new_comment.dart';

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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.edit_note_rounded),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CommunityNewComment(postId: postId);
            }));
          },
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
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
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "C O M M E N T S",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              StreamBuilder(
                stream: communityDatabase.getCommunityCommentsStream(postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    List allCommunityPostComments = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: allCommunityPostComments.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot communityPostComment =
                            allCommunityPostComments[index];
                        return CommunityComment(
                            commentId: communityPostComment.id,
                            data: communityPostComment.data());
                      },
                    );
                  } else {
                    return const Text("NODATA");
                  }
                },
              ),
            ],
          ),
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
