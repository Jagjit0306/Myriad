import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Add a small delay to prevent rapid redirects
          Future.delayed(const Duration(milliseconds: 100), () {
            if (snapshot.hasData) {
              context.go('/home');
            } else {
              context.go('/login');
            }
          });

          // Return loading indicator while redirecting
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}