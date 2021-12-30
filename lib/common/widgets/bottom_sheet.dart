import 'package:flutter/material.dart';
import 'package:charmev/theme.dart';

class CEVBottomSheet extends StatelessWidget {
  const CEVBottomSheet({
    Key? key,
    required this.children,
    this.header,
    this.height,
    this.bgColor,
    this.boxPadding,
    this.childrenFlexSize,
    this.childrenBGcolor,
    this.childrenPaddingTop,
  }) : super(key: key);

  final Widget? header;
  final List<Widget> children;
  final double? height;
  final double? boxPadding;
  final double? childrenPaddingTop;
  final Color? bgColor;
  final Color? childrenBGcolor;
  final int? childrenFlexSize;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: height ?? MediaQuery.of(context).size.height / 2.2,
        margin: EdgeInsets.fromLTRB(boxPadding ?? 16, 16, boxPadding ?? 16, 0),
        decoration: BoxDecoration(
          color: bgColor ?? CEVTheme.bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: <Widget>[
            header != null
                ? Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: header,
                    ),
                  )
                : const Padding(padding: EdgeInsets.only(top: 16.0)),
            Flexible(
                flex: childrenFlexSize ?? 4,
                child: Container(
                  color: childrenBGcolor ?? CEVTheme.bgColor,
                  padding: EdgeInsets.fromLTRB(
                      16.0, childrenPaddingTop ?? 16.0, 16.0, 0.0),
                  child: ListView(
                    children: children,
                  ),
                )),
          ],
        ));
  }
}
