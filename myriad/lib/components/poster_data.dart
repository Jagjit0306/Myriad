import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/circular_image.dart';
import 'package:myriad/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PosterData extends StatefulWidget {
  final String op; //email
  final Timestamp timestamp;
  const PosterData({super.key, required this.op, required this.timestamp});

  @override
  State<PosterData> createState() => _PosterDataState();
}

class _PosterDataState extends State<PosterData> {
  Map<String, dynamic> userData = {};
  late final SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _getUserData() async {
    await _initializePreferences();
    final Map<String, dynamic> cacheState = await _checkUserCache();
    if (cacheState["exists"]) {
      setState(() {
        userData = cacheState["data"];
      });
    } else {
      final CollectionReference users =
          FirebaseFirestore.instance.collection("Users");
      final op = await users.where('email', isEqualTo: widget.op).get();
      if (op.docs.isNotEmpty) {
        final Map<String, dynamic> fetchedData =
            op.docs.first.data() as Map<String, dynamic>;
        await _updateUserCache(fetchedData);
        setState(() {
          userData = fetchedData;
        });
      }
    }
  }

  /* 
  user cache format => 
    {
      "email0":
      {
        "validUntil": xyz-int,
        "data" : {}-object
      },
    }
  */

  Future<Map<String, dynamic>> _checkUserCache() async {
    final String userDataString = _prefs.getString("user_data_cache") ?? "";
    if (userDataString.isEmpty) {
      return {"exists": false};
    } else {
      final Map<String, dynamic> userDataSaved = jsonDecode(userDataString);
      if (userDataSaved.keys.contains(widget.op)) {
        if (userDataSaved[widget.op]["validUntil"] <
            DateTime.now().millisecondsSinceEpoch) {
          // cache has expired
          return {"exists": false};
        } else {
          return {"data": userDataSaved[widget.op]["data"], "exists": true};
        }
      } else {
        return {"exists": false};
      }
    }
  }

  Future<void> _updateUserCache(Map<String, dynamic> currUserData) async {
    final String userDataString = _prefs.getString("user_data_cache") ?? "";
    Map<String, dynamic> newUserData = {};
    if (userDataString.isNotEmpty) {
      newUserData = jsonDecode(userDataString);
    }
    newUserData[widget.op] = {
      "validUntil": DateTime.now().millisecondsSinceEpoch +
          (3600000 * 0.5), // change integer for no. of hour
      "data": currUserData
    };
    _prefs.setString("user_data_cache", jsonEncode(newUserData));
  }

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