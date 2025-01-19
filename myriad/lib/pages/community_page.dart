import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myriad/community/community.dart';
import 'package:myriad/components/community_post.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({super.key});

  final List<List<String>> tempList = [
    ['abc', 'title', 'This is the content of the post'],
    ['bcd', 'title', 'This is the content of the post'],
    ['cde', 'title', 'This is the content of the post'],
    ['def', 'title', 'This is the content of the post'],
    ['efg', 'title', 'This is the content of the post'],
  ];

  final CommunityDatabase communityDatabase = CommunityDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit_square),
        onPressed: () {
          Navigator.pushNamed(context, '/new_thread');
        },
      ),
      // body: ListView.builder(
      //   itemCount: tempList.length,
      //   itemBuilder: (context, index) {
      //     return CommunityPost(
      //       postId: tempList[index][0],
      //       title: tempList[index][1],
      //       content: tempList[index][2],
      //     );
      //   },
      // ),
      body: StreamBuilder(
        stream: communityDatabase.getCommunityPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            List allCommunityPosts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: allCommunityPosts.length,
              itemBuilder: (context, index) {
                DocumentSnapshot communityPost = allCommunityPosts[index];
                Map<String, dynamic> data =
                    communityPost.data() as Map<String, dynamic>;
                return CommunityPost(
                  postId: communityPost.id,
                  data: data,
                );
              },
            );
          } else {
            return const Text('No Data');
          }
        },
      ),
    );
  }
}
