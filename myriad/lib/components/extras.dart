import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/auth/google_auth.dart';

class Extras extends StatelessWidget {
  const Extras({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Make the entire scaffold transparent
      extendBodyBehindAppBar: true,

      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => context.push('/extras/colorify'),
                  child: const Card(
                    child: Text("Colorify"),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/extras/hearify'),
                  child: const Card(
                    child: Text("Hearify"),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/extras/wheelify'),
                  child: const Card(
                    child: Text("Wheelify"),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/extras/medify'),
                  child: const Card(
                    child: Text("Medify"),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/extras/serenify'),
                  child: const Card(
                    child: Text("Serenify"),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/extras/Sightify'),
                  child: const Card(
                    child: Text("Sightify"),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/extras/speakify'),
                  child: const Card(
                    child: Text("Speakify"),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/extras/vibraillify'),
                  child: const Card(
                    child: Text("Vibraillify"),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/extras/Voicify'),
                  child: const Card(
                    child: Text("Voicify"),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    signOutFromGoogle();
                    context.push("/auth");
                  },
                  child: const Card(
                    child: Text("LOGOUT"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
