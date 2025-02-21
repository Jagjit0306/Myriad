import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/round_button.dart';
import 'package:myriad/helper/isolate_functions.dart';
import 'package:myriad/helper/vibraille_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart'; // Add this import
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VibraillifyPage extends StatefulWidget {
  const VibraillifyPage({super.key});

  @override
  State<VibraillifyPage> createState() => _VibraillifyPageState();
}

class _VibraillifyPageState extends State<VibraillifyPage> {
  final SpeechToText _speech = SpeechToText();
  List<ChatMessage> messages = [];
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  double speed = 1.0;
  final TextEditingController _textController = TextEditingController();

  final Vibraille vibraille = Vibraille();

  final ChatUser _currentUser = ChatUser(
    id: '0',
    firstName: 'User',
  );

  final ChatUser _botUser = ChatUser(
    id: '1',
    firstName: 'Partner',
  );

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _getChats();
  }

  void activateVibraille(String text) {
    vibraille.convertToVibraille(text, speed);
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
    // _saveChats();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = "${_lastWords}${result.recognizedWords} ";
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
        _saveChats();
        activateVibraille(result.recognizedWords);
      }
    });
  }

  Future<void> _getChats() async {
    try {
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      String dataString = localPrefs.getString("vibraillify_chats") ?? "";

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
      await localPrefs.setString('vibraillify_chats', jsonEncode(messages));
    } catch (e) {
      print('Error saving chats: $e');
    }
  }

  Future<void> _clearChats() async {
    setState(() {
      messages = [];
      _saveChats();
    });
    vibraille.stopVib();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibraillify'),
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
          if (messages.isEmpty) Banner1(bannerIcon: Icons.drag_indicator),
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
                onPressMessage: (m) => activateVibraille(m.text),
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
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: RoundButton(
              icon: _isListening ? Icons.mic : Icons.mic_none,
              iconColor: _isListening ? Colors.red : Colors.white,
              onPressed: _startListening,
            ),
          ),
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
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _textController.dispose();
    vibraille.stopVib();
    super.dispose();
  }
}
