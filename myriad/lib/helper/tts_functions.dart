import 'package:flutter_tts/flutter_tts.dart';

class TTS {
  late final FlutterTts _flutterTts;

  TTS() {
    _flutterTts = FlutterTts();
  }

  void initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }

  void speak(String text) {
    _flutterTts.stop();
    _flutterTts.speak(text);
  }

  void dispose() {
    _flutterTts.stop();
  }
}
