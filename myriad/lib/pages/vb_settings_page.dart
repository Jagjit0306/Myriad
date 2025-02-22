import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/auth/google_auth.dart';
import 'package:myriad/components/extras.dart';

class VbSettingsPage extends StatelessWidget {
  const VbSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExtraButton(
            path: "/onboarding",
            iconData: Icons.star,
            name: "ONBOARDING",
            color: Colors.green,
          ),
          ExtraButton(
            path: "",
            customCallback: () {
              signOutFromGoogle();
              context.push("/auth");
            },
            iconData: Icons.logout,
            color: Colors.red,
            name: "LOGOUT",
          ),
        ],
      ),
    );
  }
}
