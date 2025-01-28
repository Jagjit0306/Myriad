import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  final TextEditingController _textController = TextEditingController();
  
  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'User',
  );
  
  final ChatUser _botUser = ChatUser(
    id: '2',
    firstName: 'Assistant',
  );

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
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
              SnackBar(content: Text('Speech recognition error: ${errorNotification.errorMsg}')),
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
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = "${_lastWords}${result.recognizedWords} ";
      _textController.text = _lastWords;
      _messages.add(
        ChatMessage(
          user: _currentUser,
          text: result.recognizedWords,
          createdAt: DateTime.now(),
        ),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messages: _messages,
              onSend: (ChatMessage message) {
                setState(() {
                  _messages.add(message);
                });
                _speak(message.text);
              },
              messageOptions: MessageOptions(
                showTime: true,
                containerColor: Theme.of(context).colorScheme.inversePrimary,
                textColor: Colors.white,
                currentUserContainerColor: Theme.of(context).colorScheme.primary,
                currentUserTextColor: Colors.white,
              ),
              inputOptions: InputOptions(
                cursorStyle: CursorStyle(
                  color: Colors.red,
                ),
                inputDecoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText: "Type your message...",
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