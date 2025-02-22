import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/components/round_button.dart';
import 'package:myriad/helper/isolate_functions.dart';
import 'package:myriad/helper/speech_functions.dart';
import 'package:myriad/helper/vibraille_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class VibraillifyPage extends StatefulWidget {
  const VibraillifyPage({super.key});

  @override
  State<VibraillifyPage> createState() => _VibraillifyPageState();
}

class _VibraillifyPageState extends State<VibraillifyPage> {
  final SpeechService _speechService = SpeechService();
  List<ChatMessage> messages = [];
  String _lastWords = '';
  double speed = 1.0;
  final TextEditingController _textController = TextEditingController();

  final Vibraille vibraille = Vibraille();

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
    _speechService.initialize(context);
    _getChats();
  }

  void activateVibraille(String text) {
    vibraille.convertToVibraille(text, speed);
  }

  void _handleSpeechResult(String recognizedWords) {
    setState(() {
      _lastWords = "$_lastWords$recognizedWords ";
      _textController.text = _lastWords;

      messages = [
        ChatMessage(
          user: _botUser,
          text: recognizedWords,
          createdAt: DateTime.now(),
        ),
        ...messages,
      ];
      _saveChats();
      activateVibraille(recognizedWords);
    });
  }

  Future<void> _getChats() async {
    try {
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      String dataString = localPrefs.getString("vibraillify_chats") ?? "";

      // Process data in isolate
      final List<ChatMessage> chatData = await compute(
        processChatMessages,
        ChatData(dataString),
      );

      if (mounted) {
        setState(() {
          messages = chatData;
        });
      }
    } catch (e) {
      print('Error loading chats: $e');
    }
  }

  Future<void> _saveChats() async {
    try {
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      await localPrefs.setString('vibraillify_chats', jsonEncode(messages));
    } catch (e) {
      print('Error saving chats: $e');
    }
  }

  Future<void> _clearChats() async {
    setState(() {
      messages = [];
      _saveChats();
    });
    vibraille.stopVib();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Vibraillify',
        hideSos: true,
        actions: [
          AppbarIcon(
            onTouch: () => context.push('/vb_settings'),
            iconData: Icons.settings,
          ),
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
          ),
        ],
      ),
      body: Column(
        children: [
          if (messages.isEmpty) Banner1(bannerIcon: Icons.drag_indicator),
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messages: messages,
              onSend: (ChatMessage message) {},
              scrollToBottomOptions: ScrollToBottomOptions(
                scrollToBottomBuilder: (scrollController) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .inversePrimary, // White bubble
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2), // Shadow effect
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_downward, // Change the icon if needed
                            color: Theme.of(context)
                                .colorScheme
                                .surface, // Black icon
                          ),
                          onPressed: () {
                            scrollController.animateTo(
                              scrollController.position.minScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              messageOptions: MessageOptions(
                onPressMessage: (m) => activateVibraille(m.text),
                currentUserContainerColor:
                    Theme.of(context).colorScheme.inversePrimary,
                containerColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                textColor: Theme.of(context).colorScheme.inversePrimary,
                currentUserTextColor: Theme.of(context).colorScheme.surface,
                showCurrentUserAvatar: true,
              ),
              readOnly: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ListenableBuilder(
              listenable: _speechService,
              builder: (context, child) {
                return RoundButton(
                  iconColor: _speechService.isListening
                      ? Colors.red
                      : Theme.of(context).colorScheme.inversePrimary,
                  icon: _speechService.isListening ? Icons.mic : Icons.mic_none,
                  onPressed: () => _speechService.toggleListening(
                      context, _handleSpeechResult),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Slider(
              activeColor: Theme.of(context).colorScheme.secondary,
              inactiveColor: Theme.of(context).colorScheme.primary,
              thumbColor: Theme.of(context).colorScheme.inversePrimary,
              value: speed,
              min: 0.1,
              max: 1.9,
              onChanged: (double value) {
                setState(() {
                  speed = value;
                });
                vibraille.stopVib();
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speechService.dispose();
    _textController.dispose();
    vibraille.stopVib();
    super.dispose();
  }
}
