// ignore_for_file: deprecated_member_use

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter/material.dart';

typedef OnSpeechResultCallback = void Function(String recognizedWords);

class SpeechService extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  // Getters
  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;

  Future<void> initialize(BuildContext context) async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (errorNotification) {
          // print('Speech recognition error: $errorNotification');
          _isListening = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Speech recognition error: ${errorNotification.errorMsg}'),
            ),
          );
        },
        onStatus: (status) {
          // print('Speech recognition status: $status');
          if (status == 'done') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      notifyListeners();
    } catch (e) {
      // print('Failed to initialize speech recognition: $e');
      _speechEnabled = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to initialize speech recognition')),
        );
      }
    }
  }

  Future<void> toggleListening(
      BuildContext context, OnSpeechResultCallback onResult) async {
    if (!_speechEnabled) {
      await initialize(context);
      if (!_speechEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition not available')),
          );
        }
        return;
      }
    }

    if (!_isListening) {
      _isListening = true;
      notifyListeners();
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        localeId: "en_US",
        cancelOnError: true,
        partialResults: false,
        listenMode: ListenMode.confirmation,
      );
    } else {
      _isListening = false;
      notifyListeners();
      await _speech.stop();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
