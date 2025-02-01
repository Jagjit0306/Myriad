import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart'; // Add this import
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HearifyPage extends StatefulWidget {
  const HearifyPage({super.key});

  @override
  State<HearifyPage> createState() => _HearifyPageState();
}

class _HearifyPageState extends State<HearifyPage> {
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
    String dataString = localPrefs.getString("hearify_chats") ?? "";
    if (dataString.isNotEmpty) {
      final decodedJson = jsonDecode(dataString) as List;
      final castedList = decodedJson.cast<Map<String, dynamic>>();
      List<ChatMessage> chatData =
          castedList.map((e) => ChatMessage.fromJson(e)).toList();
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
    localPrefs.setString('hearify_chats', jsonEncode(messages));
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
              messageOptions: MessageOptions(
                currentUserContainerColor:
                    Theme.of(context).colorScheme.inversePrimary,
                containerColor: Theme.of(context).colorScheme.onSecondaryContainer,
                textColor: Theme.of(context).colorScheme.inversePrimary,
                currentUserTextColor: Theme.of(context).colorScheme.surface,
                showCurrentUserAvatar: true,
              ),
              readOnly: true,
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
    _textController.dispose();
    super.dispose();
  }
}
