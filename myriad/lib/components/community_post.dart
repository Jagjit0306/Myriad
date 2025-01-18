import 'package:flutter/material.dart';
import 'package:myriad/pages/community_thread.dart';

class CommunityPost extends StatelessWidget {
  final String postId;
  final String title;
  final String content;
  const CommunityPost(
      {super.key,
      required this.postId,
      required this.title,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return CommunityThread(title: title, postId: postId);
        },
      )),
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        margin: EdgeInsets.all(10),
        elevation: 2.0,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '$title -> $postId',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(content),
                Text(content),
                Text(content),
                Text(content),
                Text(content),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
