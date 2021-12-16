import 'package:flutter/material.dart';
import 'package:charmev/theme.dart';

class CEVDialog extends StatelessWidget {
  const CEVDialog(
      {Key? key, this.cornerRadius = 8.0, required this.items, this.onTap})
      : super(key: key);

  final double cornerRadius;
  final Function(String)? onTap;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius)),
      child: SizedBox(
          // width: MediaQuery.of(context).size.width,
          // margin: EdgeInsets.only(top: 32),
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(items[i]),
                  tileColor: CEVTheme.dialogBgColor,
                  onTap: () => onTap!(items[i]),
                );
              })),
    );
  }
}
