import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/circular_image.dart';
import 'package:myriad/helper/helper_functions.dart';
import 'package:myriad/pages/community_thread.dart';

class CommunityPost extends StatelessWidget {
  final String postId;
  final dynamic data;
  const CommunityPost({super.key, required this.postId, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return CommunityThread(title: data['title'], postId: postId);
          },
        ));
      },
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        margin: EdgeInsets.all(10),
        elevation: 2.0,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PosterData(email: data['op']),
                    Text(timeSince(data['timestamp']),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                        child: Text(
                          data['title'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(data['content'],
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary)),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 35,
                            color: Theme.of(context).colorScheme.inversePrimary,
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
      ),
    );
  }
}

class PosterData extends StatefulWidget {
  final String email;
  const PosterData({super.key, required this.email});

  @override
  State<PosterData> createState() => _PosterDataState();
}

class _PosterDataState extends State<PosterData> {
  var userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    final op = await users.where('email', isEqualTo: widget.email).get();
    if (op.docs.isNotEmpty) {
      setState(() {
        userData = op.docs.first.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
