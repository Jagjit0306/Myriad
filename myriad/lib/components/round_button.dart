import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final IconData icon;
  final double size;
  // final Color backgroundColor;
  // final Color iconColor;
  final VoidCallback onPressed;

  const RoundButton({
    Key? key,
    required this.icon,
    this.size = 100.0,
    // this.backgroundColor;,
    // this.iconColor = Colors.white,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
        onPressed();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
          border: Border.all(
              width: 5, color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: size * 0.5, // Icon size relative to the button size
          ),
        ),
      ),
    );
  }
}
