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
      profileImage: FirebaseAuth.instance.currentUser!.photoURL);

  ChatUser geminiUser = ChatUser(
    firstName: "Therapist",
    id: '1',
    profileImage:
        "https://res.cloudinary.com/startup-grind/image/upload/c_fill,dpr_2.0,f_auto,g_center,h_1080,q_100,w_1080/v1/gcs/platform-data-goog/events/IMG_20240224_201158.jpg",
  );

  String _chatPrompt(String input) {
    List<String> instructions = [
      // TODO: add a list of conditions faced by the user
      'you are an AI assistant designed to give motivation to people with special needs',
      'Send Messages like you are having a conversation with the person',
      'Respond like a human',
      'Do not deny that you are a therapist',
      'You may even ask the person how their day went and if they want to talk about something that is on their mind',
      'Do not use bold text',
      'Your purpose is to provide emotional support to the user.',
    ];

    return "FOLLOW THE INSTRUCTIONS AND RESPOND TO THE PROMPT->\n"
        "instructions->"
        "$instructions"
        "\n"
        "prompt->'$input'";
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      gemini.streamGenerateContent(_chatPrompt(question)).listen(
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
            hintText: "Chat with Therapist...",
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
