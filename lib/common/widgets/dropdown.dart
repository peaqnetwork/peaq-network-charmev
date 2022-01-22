import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';

class CEVDropDown extends StatelessWidget {
  const CEVDropDown(
      {required this.items,
      this.margin = const EdgeInsets.fromLTRB(52, 54, 52, 0),
      this.padding = const EdgeInsets.all(2),
      this.borderColor,
      this.radius,
      this.onTap,
      Key? key})
      : super(key: key);

  final List<String> items;
  final EdgeInsets margin;
  final Color? borderColor;
  final EdgeInsets padding;
  final BorderRadiusGeometry? radius;
  final Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: radius ?? BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: CEVTheme.dialogBgColor,
            borderRadius: radius ?? BorderRadius.circular(10),
          ),
          child: _buildNodeList(),
        ));
  }

  Widget _buildNodeList() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        // itemExtent: 4,
        itemCount: items.length,
        // reverse: true,
        itemBuilder: (context, i) {
          return GestureDetector(
              onTap: () => onTap!(items[i]),
              child: Container(
                  width: double.infinity,
                  color: CEVTheme.dialogBgColor,
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                  child: Text(
                    items[i],
                    style: CEVTheme.labelStyle
                        .copyWith(fontSize: 14, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  )));
        });
  }
}
