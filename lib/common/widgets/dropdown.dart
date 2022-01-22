import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';

class CEVDropDown extends StatelessWidget {
  const CEVDropDown({required this.items, this.onTap, Key? key})
      : super(key: key);

  final List<String> items;
  final Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(52, 78, 52, 0),
      decoration: BoxDecoration(
        border: Border.all(color: CEVTheme.accentColor, width: 2),
        color: CEVTheme.dialogBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildNodeList(),
    );
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
                        .copyWith(fontSize: 14, color: CEVTheme.textFadeColor),
                    overflow: TextOverflow.ellipsis,
                  )));
        });
  }
}
