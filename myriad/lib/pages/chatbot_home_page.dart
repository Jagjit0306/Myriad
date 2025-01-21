import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatbotHomePage extends StatefulWidget {
  const ChatbotHomePage({super.key});

  @override
  State<ChatbotHomePage> createState() => _ChatbotHomePageState();
}

class _ChatbotHomePageState extends State<ChatbotHomePage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(
    id: "0",
    firstName: FirebaseAuth.instance.currentUser!.displayName,
  );

  ChatUser geminiUser = ChatUser(
    firstName: "Therapist",
    id: '1',
  );

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      gemini.streamGenerateContent(question).listen(
        (event) {
          ChatMessage? lastMessage = messages.firstOrNull;
          if (lastMessage != null && lastMessage.user == geminiUser) {
            lastMessage = messages.removeAt(0);
            String response = event.content?.parts?.fold(
                    "", (previous, current) => "$previous ${current.text}") ??
                "";
            lastMessage.text += response;
            setState(() {
              messages = [lastMessage!, ...messages];
            });
          } else {
            String response = event.content?.parts?.fold(
                    "", (previous, current) => "$previous ${current.text}") ??
                "";
            ChatMessage message = ChatMessage(
              text: response,
              user: geminiUser,
              createdAt: DateTime.now(),
            );
            setState(() {
              messages = [message, ...messages];
            });
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot"),
      ),
      body: DashChat(
        messages: messages,
        onSend: _sendMessage,
        currentUser: currentUser,
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.pink.shade100,
          containerColor: Colors.grey,
          textColor: Colors.white,
          currentUserTextColor: Colors.black,
        ),
        inputOptions: InputOptions(
          inputDecoration: InputDecoration(
            filled: true,
            fillColor: Colors.black, // Background color of the typing field
            hintText: "Type your message...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              // borderSide: BorderSide.none,
            ),
          ),
          sendButtonBuilder: (void Function() onSend) {
            return GestureDetector(
              onTap: onSend,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue, // Background color of the send button
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.send,
                  color: Colors.white, // Icon color
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
