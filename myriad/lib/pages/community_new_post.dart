import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myriad/database/community.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_chips.dart';
import 'package:myriad/components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool isButtonEnabled = false;

  Future<void> _getPrefs() async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    setState(() {
      categories = jsonDecode(localPrefs.getString('prefs') ?? "")
          .where((map) => map.values.first == true)
          .map((map) => {map.keys.first: false})
          .toList();
      categories.insert(0, {"General": true});
      _updateButtonState();
    });
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = titleController.text.isNotEmpty &&
          contentController.text.isNotEmpty &&
          categories.any((category) => category.values.first == true);
    });
  }

  @override
  void initState() {
    super.initState();
    _getPrefs();
    titleController.addListener(_updateButtonState);
    contentController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    titleController.removeListener(_updateButtonState);
    contentController.removeListener(_updateButtonState);
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.newThread),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Text(
                l10n.authorNewPost,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            MyTextfield(
                hintText: l10n.postTitle,
                obscureText: false,
                onChanged: (xyz) {},
                controller: titleController),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Text(
                l10n.tags,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            MyChips(
              categories: categories,
              updateChips: (currCat, index) {
                setState(() {
                  categories[index] = {
                    currCat.keys.first: !currCat.values.first
                  };
                  _updateButtonState();
                });
              },
            ),
            MyTextfield(
                hintText: l10n.postContent,
                obscureText: false,
                inputType: TextInputType.multiline,
                onChanged: (xyz) {},
                minLines: 10,
                controller: contentController),
            SizedBox(
              height: 10,
            ),
            MyButton(
              text: l10n.postToMyriad,
              onTap: () {
                communityDatabase.addCommunityPost(
                    titleController.text, contentController.text, categories);
                titleController.clear();
                contentController.clear();
                Navigator.pop(context);
              },
              enabled: isButtonEnabled,
            ),
          ],
        ),
      ),
    );
  }
}
