import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myriad/community/community.dart';
import 'package:myriad/components/community_post.dart';
import 'package:myriad/components/my_chips.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final CommunityDatabase communityDatabase = CommunityDatabase();

  List<dynamic> categories = [
    {'General': true}
  ];

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  Future<void> _getPrefs() async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    List<dynamic> temp =
        (jsonDecode(localPrefs.getString('prefs') ?? "") as List)
            .where((map) => map.values.first == true)
            .map((map) => {map.keys.first: false})
            .toList();
    setState(() {
      categories.insertAll(1, temp);
    });
  }

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
      body: Column(
        children: [
          MyChips(
            categories: categories,
            updateChips: (currCat, index) {
              setState(() {
                categories[index] = {currCat.keys.first: !currCat.values.first};
              });
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: communityDatabase.getCommunityPostsStream(categories
                  .where((map) => map.values.first == true)
                  .map((map) => map.keys.first)
                  .toList()),
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

                      // Verify if the 'categories' field has at least one matching category
                      List<dynamic> postCategories = data['categories'] ?? [];
                      bool hasMatchingCategory = postCategories.any(
                          (category) => categories
                              .where((map) => map.values.first == true)
                              .map((map) => map.keys.first)
                              .toList()
                              .contains(category));

                      if (!hasMatchingCategory) {
                        return const SizedBox
                            .shrink(); // Skip this post if no match
                      }

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
          ),
        ],
      ),
    );
  }
}
