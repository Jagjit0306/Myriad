import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/auth/google_auth.dart';
import 'package:myriad/database/user.dart';

class HomeConfigurator extends StatefulWidget {
  const HomeConfigurator({super.key});

  @override
  State<HomeConfigurator> createState() => _HomeConfiguratorState();
}

class _HomeConfiguratorState extends State<HomeConfigurator> {
  final UserDatabase userDatabase = UserDatabase();

  @override
  void initState() {
    super.initState();
    selectHome();
  }

  void selectHome() async {
    // TODO: try to save the home_screen pref to local. And when logging in using /auth, use that data
    List<dynamic>? config = await userDatabase.getConfig();
    // if (config == null) {
    //   // If config is null, it means the user is not logged in or no config exists
    //   // ScaffoldMessenger.of(context).showSnackBar(
    //   //   SnackBar(
    //   //     content: Text('Please log in to continue'),
    //   //   ),
    //   // );
    //   // context.go('/auth');
    //   // signOutFromGoogle();
    //   return;
    // }
    if (config!.isNotEmpty) {
      final Map<String, bool> c =
          config.fold({}, (acc, map) => {...acc, ...map});
      if (c["Vision Support"] == true && c["Hearing Support"] == true) {
        context.go('/vb_chat_bot');
      } else {
        context.go('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error configuring home'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator.adaptive(),
      ],
    );
  }
}
