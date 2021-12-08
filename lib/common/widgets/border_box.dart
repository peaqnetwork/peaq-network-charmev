import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';

class CEVBorderBox extends StatelessWidget {
  const CEVBorderBox(
      {required this.child,
      this.width,
      this.padding = 32,
      this.margin = 1,
      this.boxMargin,
      this.radius = 20,
      Key? key})
      : super(key: key);

  final Widget child;
  final double? width;
  final double padding;
  final double margin;
  final double radius;
  final EdgeInsets? boxMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: boxMargin,
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(radius))),
        child: Container(
          width: width,
          margin: EdgeInsets.all(margin),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
              color: CEVTheme.bgColor,
              borderRadius: BorderRadius.all(Radius.circular(radius))),
          child: child,
        ));
  }
}
