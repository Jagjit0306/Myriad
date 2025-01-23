import 'package:flutter/material.dart';
import 'package:myriad/database/community.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';

class CommunityNewComment extends StatefulWidget {
  final String postId;
  const CommunityNewComment({super.key, required this.postId});

  @override
  State<CommunityNewComment> createState() => _CommunityNewCommentState();
}

class _CommunityNewCommentState extends State<CommunityNewComment> {
  final TextEditingController commentController = TextEditingController();

  final CommunityDatabase communityDatabase = CommunityDatabase();

  bool commentEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Comment"),
      ),
      body: Column(
        children: [
          MyTextfield(
            hintText: 'Comment',
            obscureText: false,
            controller: commentController,
            onChanged: (val) {
              setState(() {
                commentEmpty = val.isEmpty;
              });
            },
          ),
          MyButton(
            text: 'Upload',
            enabled: !commentEmpty,
            onTap: () {
              communityDatabase.addCommunityComment(
                  widget.postId, commentController.text);
              commentController.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
