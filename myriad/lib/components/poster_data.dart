import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/circular_image.dart';
import 'package:myriad/helper/helper_functions.dart';

class PosterData extends StatefulWidget {
  final String op;
  final Timestamp timestamp;
  const PosterData({super.key, required this.op, required this.timestamp});

  @override
  State<PosterData> createState() => _PosterDataState();
}

class _PosterDataState extends State<PosterData> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

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

  Future<dynamic> _checkUserCache() async {}

  Future<void> _updateUserCache() async {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/profile/${widget.op}');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircularImage(
                imageUrl: userData['profileLink'] ?? "",
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
                userData['username'] ?? "Name Error",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: Text(timeSince(widget.timestamp),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary)),
          ),
        ],
      ),
    );
  }
}