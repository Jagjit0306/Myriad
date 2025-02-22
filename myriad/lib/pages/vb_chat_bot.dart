import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/my_app_bar.dart';

class VbChatBot extends StatelessWidget {
  const VbChatBot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "My AI - Eva",
        hideSos: true,
        actions: [
          AppbarIcon(
            onTouch: () => context.push('/vb_settings'),
            iconData: Icons.settings,
          ),
        ],
      ),
      body: const Text("chatbot coming soon"),
    );
  }
}
