import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:myriad/themes/light_mode.dart'; // Import your theme file

class SpeakifyPage extends StatefulWidget {
  const SpeakifyPage({super.key});

  @override
  State<SpeakifyPage> createState() => _SpeakifyPageState();
}

class _SpeakifyPageState extends State<SpeakifyPage> {
  final FlutterTts _flutterTts = FlutterTts();

  ChatUser currentUser = ChatUser(
      id: "0",
      firstName: FirebaseAuth.instance.currentUser!.displayName,
      profileImage: FirebaseAuth.instance.currentUser!.photoURL);

  List<ChatMessage> messages = [];

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

//   Future<void> _checkAvailableLanguages() async {
//     var languages = await _flutterTts.getLanguages;
//     print("Available languages: $languages");
//   }

  @override
  void initState() {
    super.initState();
    _getChats();
  }

  Future<void> _getChats() async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    String dataString = localPrefs.getString("speakify_chats") ?? "";
    if (dataString.isNotEmpty) {
      final decodedJson = jsonDecode(dataString) as List;
      final castedList = decodedJson.cast<Map<String, dynamic>>();
      List<ChatMessage> chatData =
          castedList.map((e) => ChatMessage.fromJson(e)).toList();
      // final listSize = chatData.length;
      if (chatData.length > 50) {
        chatData = chatData.sublist(0, 50); //only 50 recent chats are saved
      }
      setState(() {
        messages = chatData;
      });
    }
  }

  Future<void> _saveChats() async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    localPrefs.setString('speakify_chats', jsonEncode(messages));
  }

  Future<void> _clearChats() async {
    setState(() {
      messages = [];
      _saveChats();
    });
  }

  void _sendMessage(ChatMessage newMessage) {
    setState(() {
      messages = [newMessage, ...messages];
    });
    _speak(newMessage.text);
    _saveChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speakify'),
        actions: [
          PopupMenuButton(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            onSelected: (value) {
              switch (value) {
                case 'clrcht':
                  _clearChats();
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clrcht',
                child: Text("Clear Chat"),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          if (messages.isEmpty) Banner1(bannerIcon: Icons.record_voice_over,),
          Expanded(
            child: DashChat(
              currentUser: currentUser,
              onSend: _sendMessage,
              messages: messages,
              messageOptions: MessageOptions(
                currentUserContainerColor:
                    Theme.of(context).colorScheme.inversePrimary,
                containerColor: Theme.of(context).colorScheme.onSecondaryContainer,
                textColor: Theme.of(context).colorScheme.inversePrimary,
                currentUserTextColor: Theme.of(context).colorScheme.surface,
                onPressMessage: (p0) {
                  _speak(p0.text);
                },
              ),
              inputOptions: InputOptions(
                cursorStyle: CursorStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                inputDecoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surface, // Background color of the typing field
                  hintText: "Type something...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    // borderSide: BorderSide.none,
                  ),
                ),
                sendButtonBuilder: (void Function() onSend) {
                  return GestureDetector(
                    onTap: onSend,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Icon(
                        Icons.record_voice_over,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        size: 35, // Icon color
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}