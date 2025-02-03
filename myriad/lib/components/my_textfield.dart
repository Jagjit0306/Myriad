import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextInputType inputType;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MyTextfield(
      {super.key,
      required this.hintText,
      this.inputType = TextInputType.text,
      required this.obscureText,
      required this.controller,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: TextField(
        keyboardType: inputType,
        onChanged: onChanged,
        controller: controller,
        scrollPhysics: BouncingScrollPhysics(),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }
}
