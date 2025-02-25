import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final void Function()? onTap;
  final double fontSize;

  const MyButton(
      {super.key,
      this.fontSize = 18,
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Card(
          elevation: 4,
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  " ",
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: enabled
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
                Text(
                  // enabled ? " " : "[actions are pending]",
                  " ",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
