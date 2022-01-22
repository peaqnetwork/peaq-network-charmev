import 'package:flutter/material.dart';

class CEVRaisedButton extends StatelessWidget {
  const CEVRaisedButton({
    Key? key,
    this.icon,
    this.text = "",
    this.iconColor,
    this.textColor,
    this.isTextBold = false,
    this.borderColor,
    this.borderWidth,
    this.bgColor,
    this.iconSize,
    this.isIconRight = false,
    this.spacing,
    this.padding,
    this.textSize,
    this.elevation,
    this.radius,
    this.onPressed,
  }) : super(key: key);

  final IconData? icon;
  final String text;
  final Color? iconColor;
  final Color? bgColor;
  final Color? textColor;
  final bool isTextBold;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsets? padding;
  final double? iconSize;
  final bool isIconRight;
  final double? spacing;
  final double? textSize;
  final MaterialStateProperty<double>? elevation;
  final void Function()? onPressed;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: elevation,
          backgroundColor:
              MaterialStateProperty.all(bgColor ?? Colors.transparent),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              side: BorderSide(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth ?? 0.0),
              borderRadius: BorderRadius.all(Radius.circular(radius ?? 5.0)))),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (!isIconRight) ? buildIcon() : const SizedBox(),
              (spacing != null && !isIconRight)
                  ? SizedBox(width: spacing)
                  : const SizedBox(),
              buildText(),
              (spacing != null && isIconRight)
                  ? SizedBox(width: spacing)
                  : const SizedBox(),
              (isIconRight) ? buildIcon() : const SizedBox(),
            ],
          ),
        ));
  }

  Widget buildIcon() {
    return (icon != null)
        ? Flexible(
            child: Icon(
              icon,
              size: iconSize ?? 18.0,
              color: iconColor ?? Colors.black,
            ),
          )
        : const SizedBox();
  }

  Widget buildText() {
    return (text.isNotEmpty)
        ? Flexible(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: textSize ?? 18.0,
                  color: textColor ?? Colors.black,
                  fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 0),
            ),
            flex: 6,
          )
        : const SizedBox();
  }
}

class CEVFlatButton extends StatelessWidget {
  const CEVFlatButton({
    Key? key,
    this.icon,
    this.text = "",
    this.iconColor,
    this.textColor,
    this.isTextBold = false,
    this.borderColor,
    this.borderWidth,
    this.bgColor,
    this.iconSize,
    this.isIconRight = false,
    this.spacing,
    this.padding,
    this.textSize,
    this.radius,
    this.onPressed,
  }) : super(key: key);

  final IconData? icon;
  final String text;
  final Color? iconColor;
  final Color? bgColor;
  final Color? textColor;
  final bool isTextBold;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsets? padding;
  final double? iconSize;
  final bool isIconRight;
  final double? spacing;
  final double? textSize;
  final void Function()? onPressed;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(bgColor ?? Colors.transparent),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              side: BorderSide(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth ?? 0.0),
              borderRadius: BorderRadius.all(Radius.circular(radius ?? 5.0)))),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (!isIconRight) ? buildIcon() : const SizedBox(),
              (spacing != null && !isIconRight)
                  ? SizedBox(width: spacing)
                  : const SizedBox(),
              buildText(),
              (spacing != null && isIconRight)
                  ? SizedBox(width: spacing)
                  : const SizedBox(),
              (isIconRight) ? buildIcon() : const SizedBox(),
            ],
          ),
        ));
  }

  Widget buildIcon() {
    return (icon != null)
        ? Flexible(
            child: Icon(
              icon,
              size: iconSize ?? 18.0,
              color: iconColor ?? Colors.black,
            ),
          )
        : const SizedBox();
  }

  Widget buildText() {
    return (text.isEmpty)
        ? Flexible(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: textSize ?? 18.0,
                  color: textColor ?? Colors.black,
                  fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 0),
            ),
            flex: 6,
          )
        : const SizedBox();
  }
}
