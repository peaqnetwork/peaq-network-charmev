import 'package:flutter/material.dart';

class CEVKeyboardPadding extends StatelessWidget {
  final Widget child;

  const CEVKeyboardPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
