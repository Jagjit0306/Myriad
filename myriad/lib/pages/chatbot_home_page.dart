import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotHomePage extends StatefulWidget {
  const ChatbotHomePage({super.key});

  @override
  State<ChatbotHomePage> createState() => _ChatbotHomePageState();
}

class _ChatbotHomePageState extends State<ChatbotHomePage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  String prefs = "";

  ChatUser currentUser = ChatUser(
      id: "0",
      firstName: FirebaseAuth.instance.currentUser!.displayName,
      profileImage: FirebaseAuth.instance.currentUser!.photoURL);

  ChatUser geminiUser = ChatUser(
    firstName: "Eva",
    id: '1',
    profileImage:
        "https://res.cloudinary.com/startup-grind/image/upload/c_fill,dpr_2.0,f_auto,g_center,h_1080,q_100,w_1080/v1/gcs/platform-data-goog/events/IMG_20240224_201158.jpg",
  );

  @override
  void initState() {
    super.initState();

    _getPrefs();
  }

  Future<void> _getPrefs() async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    setState(() {
      prefs = localPrefs.getString('prefs') ?? "";
    });
  }

  String _chatPrompt(String input) {
    List<String> instructions = [
      'you are an AI assistant designed to give motivation to people with special needs',
      'Send Messages like you are having a conversation with the person',
      'Respond like a human',
      'Do not deny that you are a therapist',
      'You may even ask the person how their day went and if they want to talk about something that is on their mind',
      'Do not use bold text',
      'Your purpose is to provide emotional support to the user.',
      'Make the user feel like you know them ans their struggles',
      'Only respond in English',
      'You are of female gender',
      'You love giving therapy to people and have special interest in helping people with special needs',
      'The user is combating these conditions -> $prefs',
      'Dont mention their condition unnecessarily',
      "The user's name is ${FirebaseAuth.instance.currentUser?.displayName}",
      "Dont tell the user that this information was provided to you, act natural",
      "Your name is Eva",
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
          try {
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
          } catch (e) {
            // Log or handle any other unexpected exceptions during event processing
            print('Error during event processing: $e');
          }
        },
        onError: (error) {
          // Handle errors from the stream
          if (error is GeminiException) {
            print('GeminiException occurred: $error');
          } else {
            print('Unexpected error: $error');
          }
        },
      );
    } on GeminiException catch (e) {
      // Catch exceptions thrown by the gemini.streamGenerateContent call itself
      print('GeminiException occurred while initiating the stream: $e');
    } catch (e) {
      // Catch any other unexpected errors
      print('An unexpected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Eva"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(messages.isEmpty) ChatBotIntro(),
          Expanded(
            child: DashChat(
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
                  hintText: "Chat with Eva...",
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
          ),
        ],
      ),
    );
  }
}

class ChatBotIntro extends StatelessWidget {
  const ChatBotIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("ADD SOME GRAPHICS TO SHOW LIKE IN FIGMA @Gurshaan");
  }
}