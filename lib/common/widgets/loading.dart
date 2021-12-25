import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CEVLoading extends StatelessWidget {
  const CEVLoading(this.text, this.isLinear,
      {this.progress, this.strokeWidth = 2, Key? key})
      : super(key: key);

  final String text;
  final double? progress;
  final bool isLinear;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      color: Theme.of(context).backgroundColor,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          (isLinear)
              ? LinearProgressIndicator(
                  value: progress,
                )
              : CircularProgressIndicator(
                  value: progress, strokeWidth: strokeWidth),
          const SizedBox(height: 8.0),
          Text(
            text,
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.redAccent),
          )
        ],
      ),
    ));
  }
}
