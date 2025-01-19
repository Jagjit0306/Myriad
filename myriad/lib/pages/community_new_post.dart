import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myriad/community/community.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityNewPost extends StatefulWidget {
  const CommunityNewPost({super.key});

  @override
  State<CommunityNewPost> createState() => _CommunityNewPostState();
}

class _CommunityNewPostState extends State<CommunityNewPost> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController contentController = TextEditingController();

  final CommunityDatabase communityDatabase = CommunityDatabase();

  List<dynamic> categories = [];

  Future<void> _getPrefs() async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    // print('UR PREFS ARE');
    // print(localPrefs.getString('prefs'));
    setState(() {
      categories = jsonDecode(localPrefs.getString('prefs') ?? "")
          .where((map) => map.values.first == true)
          .map((map) => {map.keys.first: false})
          .toList();
      categories.insert(0, {"General": false});
    });
  }

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Thread'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Author a new post',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          MyTextfield(
              hintText: 'Post title',
              obscureText: false,
              onChanged: (xyz) {},
              controller: titleController),
          SizedBox(
            height: 10,
          ),
          Text(
            "Tags",
            style: TextStyle(fontSize: 16),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.0),
            height: 50,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                Map<dynamic, bool> currCat = categories[index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        categories[index] = {
                          currCat.keys.first: !currCat.values.first
                        };
                      });
                    },
                    child: Chip(
                      label: Text(currCat.keys.first),
                      backgroundColor: currCat.values.first
                          ? Colors.blue.shade200
                          : Colors.transparent,
                      elevation: 4,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
              child: MyTextfield(
                  hintText: 'Post content',
                  obscureText: false,
                  onChanged: (xyz) {},
                  controller: contentController)),
          SizedBox(
            height: 10,
          ),
          MyButton(
            text: 'Post to Myriad',
            onTap: () {
              communityDatabase.addCommunityPost(
                  titleController.text, contentController.text, categories);
              titleController.clear();
              contentController.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
