import 'dart:convert';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/components/round_button.dart';
import 'package:myriad/helper/isolate_functions.dart';
import 'package:myriad/helper/speech_functions.dart';
import 'package:myriad/helper/tts_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotHomePage extends StatefulWidget {
  final bool voiceInput;
  final bool voiceOutput;
  const ChatbotHomePage({
    super.key,
    this.voiceInput = false,
    this.voiceOutput = false,
  });

  @override
  State<ChatbotHomePage> createState() => _ChatbotHomePageState();
}

class _ChatbotHomePageState extends State<ChatbotHomePage> {
  final Gemini gemini = Gemini.instance;
  final SpeechService _speechService = SpeechService();
  final TTS tts = TTS();
  List<ChatMessage> messages = [];
  String _lastWords = '';
  final TextEditingController _textController = TextEditingController();
  String prefs = "";

  ChatUser currentUser = ChatUser(
      id: "0",
      firstName: FirebaseAuth.instance.currentUser!.displayName,
      profileImage: FirebaseAuth.instance.currentUser!.photoURL,);

  ChatUser geminiUser = ChatUser(
    firstName: "Eva",
    id: '1',
    profileImage: "https://i.ibb.co/KxXJNzQM/myriad-AI.png",
  );

  @override
  void initState() {
    super.initState();
    _getPrefs();
    if (widget.voiceInput) {
      _speechService.initialize(context);
    }
    if (widget.voiceOutput) {
      tts.initTTS();
    }
    _getChats();
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

  Future<void> _getPrefs() async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    setState(() {
      prefs = localPrefs.getString('prefs') ?? "";
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

  Future<void> _clearChats() async {
    setState(() {
      messages = [];
      _saveChats();
    });
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
      "You are an AI friend/therapist in the app Myriad in India."
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
          if (widget.voiceOutput == true) {
            tts.speak(message.text);
          }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (Platform.isAndroid) {
          SystemNavigator.pop(); // Exits to home screen on Android
        } else if (Platform.isIOS) {
          exit(0); // Force quit app on iOS (not recommended for production)
        }
      },
      child: Scaffold(
        appBar: MyAppBar(
          title: "My AI - Eva",
          disableBack: true,
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
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (messages.isEmpty) Banner1(bannerIcon: Icons.auto_awesome, desc: "My AI\nYour always and everything companion",),
            Expanded(
              child: DashChat(
                messages: messages,
                onSend: _sendMessage,
                currentUser: currentUser,
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
                  onPressMessage: (m) {
                    if (widget.voiceOutput) {
                      tts.speak("${m.user.getFullName()} said ${m.text}");
                    }
                  },
                ),
                readOnly: widget.voiceInput,
                inputOptions: InputOptions(
                  cursorStyle: CursorStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: "Chat with Eva...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  sendButtonBuilder: (void Function() onSend) {
                    return GestureDetector(
                      onTap: onSend,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                        child: Transform.rotate(
                          angle: -0.42,
                          child: Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            size: 35,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (widget.voiceInput)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ListenableBuilder(
                  listenable: _speechService,
                  builder: (context, child) {
                    return RoundButton(
                      iconColor: _speechService.isListening
                          ? Colors.red
                          : Theme.of(context).colorScheme.inversePrimary,
                      icon: _speechService.isListening
                          ? Icons.mic
                          : Icons.mic_none,
                      onPressed: () => _speechService.toggleListening(
                          context, _handleSpeechResult),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speechService.dispose();
    tts.dispose();
    super.dispose();
  }
}
