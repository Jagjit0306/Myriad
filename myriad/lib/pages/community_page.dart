import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/database/community.dart';
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
            .map((map) => {map.keys.first: true})
            .toList();
    setState(() {
      categories.insertAll(1, temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Community'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: Icon(
          Icons.edit_square,
          color: Theme.of(context).colorScheme.surface,
        ),
        onPressed: () {
          // Navigator.pushNamed(context, '/new_thread');
          context.push('/community/new_thread');
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(), // Enable bouncing physics
              slivers: [
                SliverToBoxAdapter(
                  child: Image.asset(
                    'assets/community_asset.png',
                    height: 300,
                  ),
                ),
                // Add Community Posts
                StreamBuilder(
                  stream: communityDatabase.getCommunityPostsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      List allCommunityPosts = snapshot.data!.docs;
                      List filteredPosts = allCommunityPosts.where((post) {
                        Map<String, dynamic> data =
                            post.data() as Map<String, dynamic>;
                        List<dynamic> postCategories = data['categories'] ?? [];
                        return postCategories.any((category) => categories
                            .where((map) => map.values.first == true)
                            .map((map) => map.keys.first)
                            .toList()
                            .contains(category));
                      }).toList();

                      if (filteredPosts.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child:
                                Text('No Posts match the selected categories.'),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            DocumentSnapshot communityPost =
                                filteredPosts[index];
                            Map<String, dynamic> data =
                                communityPost.data() as Map<String, dynamic>;

                            return CommunityPost(
                              postId: communityPost.id,
                              data: data,
                            );
                          },
                          childCount: filteredPosts.length,
                        ),
                      );
                    } else {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text('No Posts were found...'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
