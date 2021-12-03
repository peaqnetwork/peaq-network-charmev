import 'package:flutter/material.dart';

class CEVTextField extends StatelessWidget {
  const CEVTextField(
      {required this.controller,
      required this.label,
      required this.onTap,
      required this.onChanged,
      this.autofocus = false,
      this.obscureText = false,
      this.readOnly = false,
      this.filled = true,
      this.keyboardType = TextInputType.text,
      this.bgColor,
      this.prefix,
      this.errorText,
      Key? key})
      : super(key: key);

  final TextEditingController controller;
  final bool autofocus;
  final bool obscureText;
  final bool readOnly;
  final bool filled;
  final String label;
  final Color? bgColor;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final String? errorText;
  final Function onTap;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        // padding: EdgeInsets.only(top:10, left:10),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: autofocus,
          obscureText: obscureText,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefix: prefix,
            labelText: label,
            filled: filled,
            isDense: false,
            fillColor: bgColor ?? Colors.white,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            errorText: errorText,
          ),
          onChanged: (value) => onChanged(value),
          onTap: () => onTap(),
        ));
  }
}
