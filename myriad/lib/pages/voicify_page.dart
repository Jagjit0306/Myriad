import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:myriad/components/banner_1.dart';
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
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  List<ChatMessage> messages = [];
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  final TextEditingController _textController = TextEditingController();

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
    _initializeTts();
    _getChats();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
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

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to speak text')),
        );
      }
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
      }
    });
  }

  Future<void> _getChats() async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    String dataString = localPrefs.getString("voicify_chats") ?? "";
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
    localPrefs.setString('voicify_chats', jsonEncode(messages));
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
                  // messages.add(message);
                  messages = [message, ...messages];
                });
                _speak(message.text);
                _saveChats();
              },
              messageOptions: MessageOptions(
                  currentUserContainerColor:
                      Theme.of(context).colorScheme.inversePrimary,
                  containerColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  textColor: Theme.of(context).colorScheme.inversePrimary,
                  currentUserTextColor: Theme.of(context).colorScheme.surface,
                  onPressMessage: (m) {
                    if (m.user.id == _currentUser.id) {
                      _speak(m.text);
                    }
                  }),
              inputOptions: InputOptions(
                cursorStyle: CursorStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                inputDecoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText: "Type something...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                sendButtonBuilder: (void Function() onSend) {
                  return GestureDetector(
                    onTap: onSend,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: _startListening,
              backgroundColor: _isListening ? Colors.red : Colors.white,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.white : Colors.black,
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
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }
}
