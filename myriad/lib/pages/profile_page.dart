import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/circular_image.dart';
import 'package:myriad/components/community_post.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/database/community.dart';
import 'package:intl/intl.dart';
import 'package:myriad/helper/helper_functions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final CommunityDatabase communityDatabase = CommunityDatabase();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    final currentUser = await users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();

    if (currentUser.docs.isNotEmpty && mounted) {
      setState(() {
        userData = currentUser.docs.first.data() as Map<String, dynamic>;
      });
    }
  }

  // String _formatJoinDate(Timestamp? timestamp) {
  //   if (timestamp == null) return "Join date unavailable";
  //   final DateTime date = timestamp.toDate();
  //   return DateFormat('MMMM yyyy').format(date);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Profile',
        actions: [
          AppbarIcon(
            onTouch: () => context.push('/extras/settings'),
            iconData: Icons.settings,
          ),
        ],
      ),
      body: SafeArea(
        child: userData == null
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircularImage(
                            imageUrl: userData!['profileLink'] ?? "",
                            placeholder: const Icon(Icons.person, size: 80),
                            size: 80.0,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FirebaseAuth
                                          .instance.currentUser?.displayName ??
                                      "Name not set",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "@${userData!['username'] ?? 'username'}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userData!['bio'] ?? "No bio added",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatColumn(
                                  (userData!['following'] as List<dynamic>)
                                      .length
                                      .toString(),
                                  'Following'),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.grey,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              _buildStatColumn(
                                  (userData!['followers'] as List<dynamic>)
                                      .length
                                      .toString(),
                                  'Followers'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Joined ${timeSince(Timestamp.fromDate(FirebaseAuth.instance.currentUser?.metadata.creationTime ?? DateTime.now()))} ago',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: communityDatabase.getUserPostsStream(
                      userData!['email'] ??
                          FirebaseAuth.instance.currentUser?.email ??
                          "",
                    ),
                    builder: (context, snapshot) {
                      // Add detailed error logging
                      if (snapshot.hasError) {
                        print("Stream error: ${snapshot.error}");
                        print(
                            "Stream error stack trace: ${snapshot.stackTrace}");
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Error loading posts'),
                                if (snapshot.error != null)
                                  Text(
                                    'Error details: ${snapshot.error}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Handle initial loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // Get the documents if they exist
                      final docs = snapshot.data?.docs;

                      // Check if we have any documents
                      if (docs == null || docs.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: Text('No posts yet')),
                        );
                      }

                      // If we have documents, display them
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            DocumentSnapshot post = docs[index];
                            Map<String, dynamic> postData =
                                post.data() as Map<String, dynamic>;

                            return CommunityPost(
                              postId: post.id,
                              data: postData,
                            );
                          },
                          childCount: docs.length,
                        ),
                      );
                    },
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
