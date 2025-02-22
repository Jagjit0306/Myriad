import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/circular_image.dart';
import 'package:myriad/components/community_post.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/database/community.dart';
import 'package:intl/intl.dart';

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
    final CollectionReference users = FirebaseFirestore.instance.collection("Users");
    final currentUser = await users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();
    
    if (currentUser.docs.isNotEmpty && mounted) {
      setState(() {
        userData = currentUser.docs.first.data() as Map<String, dynamic>;
      });
    }
  }

  String _formatJoinDate(Timestamp? timestamp) {
    if (timestamp == null) return "Join date unavailable";
    final DateTime date = timestamp.toDate();
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Profile',
        actions: [
          AppbarIcon(
            onTouch: () => context.push('/settings'),
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
                                  FirebaseAuth.instance.currentUser?.displayName ?? "Name not set",
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
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              _buildStatColumn('1', 'Following'),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.grey,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              _buildStatColumn('1', 'Followers'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: null,
                            child: const Text('Follow'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Joined ${_formatJoinDate(userData!['joinDate'] as Timestamp?)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: communityDatabase.getUserPostsStream(
                      userData!['email'] ?? FirebaseAuth.instance.currentUser?.email ?? "",
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: Text('No posts yet')),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            DocumentSnapshot post = snapshot.data!.docs[index];
                            return CommunityPost(
                              postId: post.id,
                              data: post.data() as Map<String, dynamic>,
                            );
                          },
                          childCount: snapshot.data!.docs.length,
                        ),
                      );
                    },
                  ),
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
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
