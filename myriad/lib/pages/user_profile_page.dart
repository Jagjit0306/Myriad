import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/circular_image.dart';
import 'package:myriad/components/community_post.dart';
import 'package:myriad/database/community.dart';
// import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  final String userEmail;
  
  const UserProfilePage({
    super.key,
    required this.userEmail,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final CommunityDatabase communityDatabase = CommunityDatabase();
  Map<String, dynamic>? userData;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkFollowingStatus();
  }

  Future<void> _loadUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userEmail)
        .get();
    
    if (mounted && userDoc.exists) {
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>;
      });
    }
  }

  Future<void> _checkFollowingStatus() async {
    final following = await communityDatabase.isFollowing(widget.userEmail);
    if (mounted) {
      setState(() {
        isFollowing = following;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData?['username'] ?? 'Profile'),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircularImage(
                          imageUrl: userData!['profileLink'] ?? "",
                          placeholder: const Icon(Icons.person, size: 80),
                          size: 80.0,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "@${userData!['username'] ?? 'username'}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userData!['bio'] ?? "No bio added",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatColumn(
                              (userData!['following'] ?? []).length.toString(),
                              'Following',
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            _buildStatColumn(
                              (userData!['followers'] ?? []).length.toString(),
                              'Followers',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (widget.userEmail != FirebaseAuth.instance.currentUser?.email)
                          ElevatedButton(
                            onPressed: () async {
                              if (isFollowing) {
                                await communityDatabase.unfollowUser(widget.userEmail);
                              } else {
                                await communityDatabase.followUser(widget.userEmail);
                              }
                              _checkFollowingStatus();
                              _loadUserData();
                            },
                            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                          ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: communityDatabase.getUserPostsStream(widget.userEmail),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const SliverFillRemaining(
                        child: Center(child: Text('Error loading posts')),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final posts = snapshot.data?.docs ?? [];
                    
                    if (posts.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: Text('No posts yet')),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return CommunityPost(
                            postId: post.id,
                            data: post.data() as Map<String, dynamic>,
                          );
                        },
                        childCount: posts.length,
                      ),
                    );
                  },
                ),
              ],
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
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 