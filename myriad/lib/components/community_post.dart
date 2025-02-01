import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/circular_image.dart';
import 'package:myriad/database/community.dart';
import 'package:myriad/helper/helper_functions.dart';
import 'package:myriad/pages/community_thread.dart';

class CommunityPost extends StatelessWidget {
  final String postId;
  final dynamic data;
  CommunityPost({super.key, required this.postId, required this.data});

  final CommunityDatabase communityDatabase = CommunityDatabase();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return CommunityThread(
              title: data['title'],
              postId: postId,
              op: data['op'],
            );
          },
        ));
      },
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        margin: EdgeInsets.all(10),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PosterData(
                op: data['op'],
                timestamp: data['timestamp'],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['categories'] != null && (data['categories'] as List).isNotEmpty)
                      Container(
                        height: 30,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (data['categories'] as List).length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                // color: Theme.of(context).colorScheme.primary,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data['categories'][index].toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 1.0),
                      child: Text(
                        data['title'],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(data['content'],
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            // color: Theme.of(context).colorScheme.bodyColor
                            )),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Feedback.forTap(context);
                            communityDatabase.likeCommunityPost(postId);
                          },
                          child: Icon(
                            Icons.favorite,
                            size: 35,
                            color: (data['likers'] is List &&
                                    data['likers'].contains(FirebaseAuth
                                        .instance.currentUser?.email))
                                ? Theme.of(context).colorScheme.inversePrimary
                                : Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text('${data["likes"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PosterData extends StatefulWidget {
  final String op;
  final Timestamp timestamp;
  const PosterData({super.key, required this.op, required this.timestamp});

  @override
  State<PosterData> createState() => _PosterDataState();
}

class _PosterDataState extends State<PosterData> {
  // ignore: prefer_typing_uninitialized_variables
  var userData;

  Future<void> _getUserData() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    final op = await users.where('email', isEqualTo: widget.op).get();
    if (op.docs.isNotEmpty && mounted) {
      setState(() {
        userData = op.docs.first.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserData();
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircularImage(
              imageUrl: userData != null ? userData['profileLink'] ?? "" : "",
              placeholder: Icon(
                Icons.person,
                size: 40,
              ),
              size: 40.0,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              userData != null
                  ? userData['username'] ?? "Name Error"
                  : "Loading...",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: Text(timeSince(widget.timestamp),
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
