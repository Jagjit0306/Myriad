import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoToHome extends StatefulWidget {
  const GoToHome({super.key});

  @override
  State<GoToHome> createState() => _GoToHomeState();
}

class _GoToHomeState extends State<GoToHome> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 800), () {
      context.go('/home_configurator');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator.adaptive(),
      ],
    );
  }
}
