import 'package:flutter/material.dart';
import 'package:myriad/community/community.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';

class CommunityNewPost extends StatelessWidget {
  CommunityNewPost({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final CommunityDatabase communityDatabase = CommunityDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Thread'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('Author a new post'),
          SizedBox(
            height: 10,
          ),
          Text('Title'),
          SizedBox(
            height: 10,
          ),
          MyTextfield(
              hintText: 'Post title',
              obscureText: false,
              controller: titleController),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: MyTextfield(
                  hintText: 'Post content',
                  obscureText: false,
                  controller: contentController)),
          SizedBox(
            height: 10,
          ),
          MyButton(
            text: 'Post to Myriad',
            onTap: () {
              communityDatabase.addCommunityPost(
                titleController.text,
                contentController.text,
              );
              titleController.clear();
              contentController.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
