import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myriad/helper/isolate_functions.dart';
import 'package:myriad/pages/notify_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VbChatBotMonitor extends StatefulWidget {
  const VbChatBotMonitor({super.key});

  @override
  State<VbChatBotMonitor> createState() => _VbChatBotMonitorState();
}

class _VbChatBotMonitorState extends State<VbChatBotMonitor> {
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(
    id: "0",
    firstName: FirebaseAuth.instance.currentUser!.displayName,
    profileImage: FirebaseAuth.instance.currentUser!.photoURL,
  );

  ChatUser geminiUser = ChatUser(
    firstName: "Eva",
    id: '1',
    profileImage: "https://i.ibb.co/KxXJNzQM/myriad-AI.png",
  );

  @override
  void initState() {
    super.initState();
    _getChats();
  }

  Future<void> _getChats() async {
    try {
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      String dataString = localPrefs.getString("chats") ?? "";

      // Process data in isolate
      final List<ChatMessage> chatData = await compute(
        processChatMessages,
        ChatData(dataString),
      );

      if (mounted) {
        setState(() {
          messages = chatData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chats: $e')),
        );
      }
    }
  }

  Future<void> _saveChats() async {
    try {
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      await localPrefs.setString('chats', jsonEncode(messages));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving chats: $e')),
        );
      }
    }
  }

  Future<void> _clearChats() async {
    setState(() {
      messages = [];
      _saveChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chat History",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: (messages.isEmpty)
                    ? Center(
                        child: const Text(
                        "There is no chat history",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ))
                    : DashChat(
                        currentUser: currentUser,
                        onSend: (m) {},
                        messages: messages,
                        messageOptions: MessageOptions(
                          currentUserContainerColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          containerColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          textColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          currentUserTextColor:
                              Theme.of(context).colorScheme.surface,
                        ),
                        scrollToBottomOptions: ScrollToBottomOptions(
                          scrollToBottomBuilder: (scrollController) {
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_downward,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    onPressed: () {
                                      scrollController.animateTo(
                                        scrollController
                                            .position.minScrollExtent,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        readOnly: true,
                      ),
              ),
            ),
          ),
          NotifyPage(
            hideMediGraph: true,
          ),
        ],
      ),
    );
  }
}
