import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final void Function()? onTap;

  const MyButton(
      {super.key,
      required this.text,
      required this.enabled,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
        if (enabled) {
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Text(
            enabled ? text : "action pending",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
