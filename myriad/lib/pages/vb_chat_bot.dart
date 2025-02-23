import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/components/round_button.dart';
import 'package:myriad/helper/isolate_functions.dart';
import 'package:myriad/helper/speech_functions.dart';
import 'package:myriad/helper/vibraille_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VbChatBot extends StatefulWidget {
  const VbChatBot({super.key});

  @override
  State<VbChatBot> createState() => _VbChatBotState();
}

class _VbChatBotState extends State<VbChatBot> {
  final Gemini gemini = Gemini.instance;
  final SpeechService _speechService = SpeechService();
  List<ChatMessage> messages = [];
  String _lastWords = '';
  final TextEditingController _textController = TextEditingController();
  final String prefs = "Visually and Hearing Challenged";
  double speed = 1.0;
  final Vibraille vibraille = Vibraille();

  ChatUser currentUser = ChatUser(
      id: "0",
      firstName: FirebaseAuth.instance.currentUser!.displayName,
      profileImage: FirebaseAuth.instance.currentUser!.photoURL);

  ChatUser geminiUser = ChatUser(
    firstName: "Eva",
    id: '1',
    profileImage: "https://i.ibb.co/KxXJNzQM/myriad-AI.png",
  );

  @override
  void initState() {
    super.initState();
    _speechService.initialize(context);
    _getChats();
  }

  void activateVibraille(String text) {
    vibraille.convertToVibraille(text, speed);
  }

  void _handleSpeechResult(String recognizedWords) {
    setState(() {
      _lastWords = "$_lastWords$recognizedWords ";
      _textController.text = _lastWords;

      _sendMessage(ChatMessage(
        user: currentUser,
        text: recognizedWords,
        createdAt: DateTime.now(),
      ));
    });
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

  String _chatPrompt() {
    List<String> instructions = [
      'you are an AI assistant designed to give motivation to people with special needs',
      'Send Messages like you are having a conversation with the person',
      'Respond like a human',
      'Do not deny that you are a therapist',
      'You may even ask the person how their day went and if they want to talk about something that is on their mind',
      'Do not use bold text',
      'Your purpose is to provide emotional support to the user.',
      'Make the user feel like you know them and their struggles',
      'respond in English, NO EXCEPTIONS',
      'You are of female gender',
      'You love giving therapy to people and have special interest in helping people with special needs',
      'The user is combating these conditions -> $prefs',
      "The user's name is ${FirebaseAuth.instance.currentUser?.displayName}",
      "Dont tell the user that this information was provided to you, act natural",
      "Your name is Eva",
      "You are an AI friend/therapist in the app Myriad in India.",
      "Keep the responses extremely concise because user will be using a vibraille medium to listen to you"
    ];

    return "FOLLOW THE INSTRUCTIONS AND RESPOND TO THE PROMPTS->\n"
        "instructions->"
        "$instructions";
  }

  List<Content> getChats() {
    List<Content> chatList = [];
    for (var element in messages) {
      chatList.insert(
          0,
          Content(
            parts: [Part.text(element.text)],
            role: element.user == geminiUser ? "model" : "user",
          ));
    }
    chatList.insert(
        0, Content(parts: [Part.text(_chatPrompt())], role: "user"));
    return chatList;
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      gemini.chat(getChats()).then(
        (value) {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: value?.output ?? "Please try again later.",
          );
          // if (widget.voiceOutput == true) {
          //   tts.speak(message.text);
          // }
          // TODO: add vibraille response
          // print("GEMINI RESPONSE");
          // print(message.text);
          activateVibraille(message.text);
          setState(() {
            messages = [message, ...messages];
          });
          _saveChats();
        },
      ).catchError((e) {
        ChatMessage message = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: "Please try again later.",
        );
        setState(() {
          messages = [message, ...messages];
        });
      });
    } catch (e) {
      ChatMessage message = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: 'Please try again later.',
      );
      setState(() {
        messages = [message, ...messages];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "My AI - Eva",
        hideSos: true,
        actions: [
          AppbarIcon(
            onTouch: () => context.push('/vb_settings'),
            iconData: Icons.settings,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: ListenableBuilder(
              listenable: _speechService,
              builder: (context, child) {
                return RoundButton(
                  iconColor: _speechService.isListening
                      ? Colors.red
                      : Theme.of(context).colorScheme.inversePrimary,
                  icon: _speechService.isListening ? Icons.mic : Icons.mic_none,
                  onPressed: () {
                    vibraille.stopVib();
                    _speechService.toggleListening(
                        context, _handleSpeechResult);
                  },
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Slider(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  inactiveColor: Theme.of(context).colorScheme.primary,
                  thumbColor: Theme.of(context).colorScheme.inversePrimary,
                  value: speed,
                  min: 0.1,
                  max: 1.9,
                  onChanged: (double value) {
                    setState(() {
                      speed = value;
                    });
                    vibraille.stopVib();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    vibraille.stopVib();
    super.dispose();
  }
}
