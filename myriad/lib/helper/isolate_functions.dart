// Data class for isolate
import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';

class ChatData {
  final String jsonString;
  ChatData(this.jsonString);
}

// Isolate processor
Future<List<ChatMessage>> processChatMessages(ChatData data) async {
  if (data.jsonString.isEmpty) return [];

  try {
    final List<dynamic> decodedJson = jsonDecode(data.jsonString);
    final castedList = decodedJson.cast<Map<String, dynamic>>();
    List<ChatMessage> chatData =
        castedList.map((e) => ChatMessage.fromJson(e)).toList();

    if (chatData.length > 50) {
      chatData = chatData.sublist(0, 50);
    }

    return chatData;
  } catch (e) {
    print('Error in isolate processing: $e');
    return [];
  }
}