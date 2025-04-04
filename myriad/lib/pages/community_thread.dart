import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/community_post.dart';
import 'package:myriad/components/my_textfield.dart';
import 'package:myriad/database/community.dart';
import 'package:myriad/components/community_comment.dart';

class CommunityThread extends StatelessWidget {
  final String postId;
  final String op;

  CommunityThread({
    super.key,
    required this.postId,
    required this.op,
  });

  final CommunityDatabase communityDatabase = CommunityDatabase();

  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Thread"),
        actions: [
          CommunityThreadDeleteOption(
            currUser: op,
            postId: postId,
            communityDatabase: communityDatabase,
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Post Section
            StreamBuilder(
              stream: communityDatabase.getCommunityPostStream(postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data != null) {
                  DocumentSnapshot postData = snapshot.data!;
                  if (postData.exists) {
                    return CommunityPost(
                      postId: postId,
                      data: postData,
                      disableClick: true,
                    );
                  }
                }
                return const Center(child: Text("Post not found"));
              },
            ),

            /// Comment Input Field (Fixed Position)
            CommentThreadCommentField(
              postId: postId,
              communityDatabase: communityDatabase,
            ),

            /// Comments Section (Scrollable inside SingleChildScrollView)
            StreamBuilder(
              stream: communityDatabase.getCommunityCommentsStream(postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else if (snapshot.hasData && snapshot.data != null) {
                  List allCommunityPostComments = snapshot.data!.docs;
                  if (allCommunityPostComments.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No comments yet"),
                    ));
                  }
                  return ListView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                    shrinkWrap: true, // Make ListView take only needed space
                    itemCount: allCommunityPostComments.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot communityPostComment =
                          allCommunityPostComments[index];
                      return CommunityComment(
                        commentId: communityPostComment.id,
                        data: communityPostComment.data(),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No comments found"));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityThreadDeleteOption extends StatefulWidget {
  final String currUser;
  final String postId;
  final CommunityDatabase communityDatabase;
  const CommunityThreadDeleteOption(
      {super.key,
      required this.currUser,
      required this.postId,
      required this.communityDatabase});

  @override
  State<CommunityThreadDeleteOption> createState() =>
      _CommunityThreadDeleteOptionState();
}

class _CommunityThreadDeleteOptionState
    extends State<CommunityThreadDeleteOption> {
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
        ? PopupMenuButton(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            onSelected: (value) {
              switch (value) {
                case "dltpst":
                  widget.communityDatabase.deleteCommunityPost(widget.postId);
                  Navigator.pop(context);
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'dltpst',
                child: const Text("Delete Post"),
              )
            ],
          )
        : Container();
  }
}

class CommentThreadCommentField extends StatefulWidget {
  final String postId;
  final CommunityDatabase communityDatabase;

  const CommentThreadCommentField({
    super.key,
    required this.postId,
    required this.communityDatabase,
  });

  @override
  State<CommentThreadCommentField> createState() =>
      _CommentThreadCommentFieldState();
}

class _CommentThreadCommentFieldState extends State<CommentThreadCommentField> {
  final TextEditingController commentController = TextEditingController();
  final ValueNotifier<bool> emptyState = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              hintText: 'Join the conversation!',
              obscureText: false,
              controller: commentController,
              onChanged: (val) {
                emptyState.value = val.isEmpty;
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: emptyState,
            builder: (context, isEmpty, child) {
              if (isEmpty) return SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () {
                    widget.communityDatabase.addCommunityComment(
                      widget.postId,
                      commentController.text.trim(),
                    );
                    commentController.clear();
                    emptyState.value = true; // Reset empty state
                    FocusScope.of(context).unfocus();
                  },
                  child: Icon(Icons.send),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
