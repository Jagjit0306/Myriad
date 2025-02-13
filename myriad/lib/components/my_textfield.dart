import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final String hintText2;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int minLines;
  final TextInputType inputType;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MyTextfield(
      {super.key,
      required this.hintText,
      this.readOnly = false,
      this.enabled = true,
      this.hintText2 = "Type something...",
      this.inputType = TextInputType.text,
      this.minLines = 1,
      this.obscureText = false,
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
        enabled: enabled,
        readOnly: readOnly,
        scrollPhysics: BouncingScrollPhysics(),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hintText2,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        obscureText: obscureText,
        minLines: minLines,
        maxLines: inputType == TextInputType.multiline ? null : 1,
      ),
    );
  }
}
