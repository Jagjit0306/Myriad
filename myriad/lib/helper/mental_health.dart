import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';
import 'dart:async';
import 'package:dash_chat_2/dash_chat_2.dart';

class MentalHealthAnalyzer {
  final Gemini gemini = Gemini.instance;
  static const String _chatStorageKey = 'chats';
  Future<int> analyzeMentalHealth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String chatData = prefs.getString('chats') ?? '';
    
    if (chatData.isEmpty) {
      return 0;
    }

    final decodedJson = jsonDecode(chatData) as List;
    final List<ChatMessage> messages = decodedJson
        .cast<Map<String, dynamic>>()
        .map((e) => ChatMessage.fromJson(e))
        .toList();

    // Extract only user messages
    final userMessages = messages
        .where((msg) => msg.user.id == '0')
        .map((msg) => msg.text)
        .join('\n');

    try {
      final response = await gemini.text(
        '''Analyze the following chat messages and provide a mental health score from 0 to 100. 
           Consider factors like positivity, engagement, emotional state, and overall well-being.
           Return only the numeric score.
           
           Messages: $userMessages''');

      if (response?.content != null && response?.content!.parts != null ) {
        final part = response?.content!.parts![0];
        
        if (part is TextPart) {
          final rawResponse = part.text;
          final match = RegExp(r'^\d+$').firstMatch(rawResponse.trim());
          if (match != null) {
            final score = int.parse(match.group(0)!).clamp(0, 100);
            return score;
          } else {
            print('No valid whole number found in response: "$rawResponse"');
          }
        } else {
          print('Expected TextPart but got: ${part.runtimeType}');
        }
      } else {
        print('No valid content received from Gemini.');
      }
    } catch (e) {
      print('Error analyzing mental health: $e');
    }
    return 0; 
  }

  Future<List<ChatMessage>> getChatMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatData = prefs.getString(_chatStorageKey);
      
      if (chatData == null || chatData.isEmpty) {
        return [];
      }

      final List<dynamic> decodedJson = jsonDecode(chatData);
      return decodedJson
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing chat messages: $e');
      return [];
    }
  } 
}