import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/round_button.dart';
import 'package:myriad/helper/isolate_functions.dart';
import 'package:myriad/helper/speech_functions.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:dash_chat_2/dash_chat_2.dart';

class HearifyPage extends StatefulWidget {
  const HearifyPage({super.key});

  @override
  State<HearifyPage> createState() => _HearifyPageState();
}

class _HearifyPageState extends State<HearifyPage> {
  final SpeechService _speechService = SpeechService();
  List<ChatMessage> messages = [];
  String _lastWords = '';
  final TextEditingController _textController = TextEditingController();

  final ChatUser _currentUser = ChatUser(
    id: '0',
    firstName: 'User',
  );

  final ChatUser _botUser = ChatUser(
    id: '1',
    firstName: 'Partner',
    profileImage:
        "https://cdn.pixabay.com/photo/2012/04/18/00/07/silhouette-of-a-man-36181_640.png",
  );

  @override
  void initState() {
    super.initState();
    _speechService.initialize(context);
    _getChats();
  }

  void _handleSpeechResult(String recognizedWords) {
    setState(() {
      _lastWords = "$_lastWords$recognizedWords ";
      _textController.text = _lastWords;

      messages = [
        ChatMessage(
          user: _botUser,
          text: recognizedWords,
          createdAt: DateTime.now(),
        ),
        ...messages,
      ];
      _saveChats();
    });
  }

  Future<void> _getChats() async {
    try {
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      String dataString = localPrefs.getString("hearify_chats") ?? "";

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
      print('Error loading chats: $e');
    }
  }

  Future<void> _saveChats() async {
    try {
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      await localPrefs.setString('hearify_chats', jsonEncode(messages));
    } catch (e) {
      print('Error saving chats: $e');
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Hearify'),
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
          if (messages.isEmpty) Banner1(bannerIcon: Icons.hearing),
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messages: messages,
              onSend: (ChatMessage message) {},
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
                              .inversePrimary, // White bubble
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2), // Shadow effect
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_downward, // Change the icon if needed
                            color: Theme.of(context)
                                .colorScheme
                                .surface, // Black icon
                          ),
                          onPressed: () {
                            scrollController.animateTo(
                              scrollController.position.minScrollExtent,
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
              messageOptions: MessageOptions(
                currentUserContainerColor:
                    Theme.of(context).colorScheme.inversePrimary,
                containerColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                textColor: Theme.of(context).colorScheme.inversePrimary,
                currentUserTextColor: Theme.of(context).colorScheme.surface,
                showCurrentUserAvatar: true,
              ),
              readOnly: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListenableBuilder(
              listenable: _speechService,
              builder: (context, child) {
                return RoundButton(
                  iconColor: _speechService.isListening
                      ? Colors.red
                      : Theme.of(context).colorScheme.inversePrimary,
                  icon: _speechService.isListening ? Icons.mic : Icons.mic_none,
                  onPressed: () => _speechService.toggleListening(
                      context, _handleSpeechResult),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speechService.dispose();
    _textController.dispose();
    super.dispose();
  }
}
