import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/helper/isolate_functions.dart';
import 'package:myriad/helper/tts_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart'; // Add this import
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoicifyPage extends StatefulWidget {
  const VoicifyPage({super.key});

  @override
  State<VoicifyPage> createState() => _VoicifyPageState();
}

class _VoicifyPageState extends State<VoicifyPage> {
  final SpeechToText _speech = SpeechToText();
  final TTS tts = TTS();
  List<ChatMessage> messages = [];
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  bool hasText = false;
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
    _initializeSpeech();
    tts.initTTS();
    _getChats();
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (errorNotification) {
          print('Speech recognition error: $errorNotification');
          if (mounted) {
            setState(() => _isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Speech recognition error: ${errorNotification.errorMsg}')),
            );
          }
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done' && mounted) {
            setState(() => _isListening = false);
          }
        },
      );
      setState(() {});
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      _speechEnabled = false;
      setState(() {});
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      await _initializeSpeech(); // Try to reinitialize if not enabled
      if (!_speechEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition not available')),
        );
        return;
      }
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        localeId: "en_US",
        cancelOnError: true,
        partialResults: false,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
    _saveChats();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = "$_lastWords${result.recognizedWords} ";
      _textController.text = _lastWords;

      if (result.recognizedWords.isNotEmpty) {
        messages = [
          ChatMessage(
            user: _botUser,
            text: result.recognizedWords,
            createdAt: DateTime.now(),
          ),
          ...messages,
        ];
      }
    });
  }

  Future<void> _getChats() async {
    try {
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      String dataString = localPrefs.getString("voicify_chats") ?? "";

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
      await localPrefs.setString('voicify_chats', jsonEncode(messages));
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
        title: const Text('Voicify'),
        centerTitle: true,
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
          if (messages.isEmpty) Banner1(bannerIcon: Icons.loop),
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messages: messages,
              onSend: (ChatMessage message) {
                setState(() {
                  messages = [message, ...messages];
                });
                tts.speak(message.text);
                _saveChats();
              },
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
                    if (m.user.id == _currentUser.id) {
                      tts.speak(m.text);
                    }
                  }),
              inputOptions: InputOptions(
                onTextChange: (v) {
                  setState(() {
                    if (v.isNotEmpty && !hasText) {
                      hasText = true;
                    } else if (v.isEmpty && hasText) {
                      hasText = false;
                    }
                  });
                },
                cursorStyle: CursorStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                alwaysShowSend: true,
                inputDecoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText: "Type something...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                sendButtonBuilder: (void Function() onSend) {
                  return Row(
                    children: [
                      if (hasText)
                        GestureDetector(
                          onTap: onSend,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                            child: Icon(
                              Icons.record_voice_over,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              size: 35, // Icon color
                            ),
                          ),
                        ),
                      if (!hasText)
                        GestureDetector(
                          onTap: _startListening,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                            child: Icon(
                              !_isListening ? Icons.mic : Icons.mic_none,
                              color: !_isListening
                                  ? Theme.of(context).colorScheme.inversePrimary
                                  : Colors.red,
                              size: 35, // Icon color
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    tts.dispose();
    _textController.dispose();
    super.dispose();
  }
}
