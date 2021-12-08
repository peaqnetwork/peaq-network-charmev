import 'package:flutter/material.dart';

class CEVCountdown extends StatelessWidget {
  const CEVCountdown(
      {required this.displayChild,
      required this.maxCount,
      this.onTimeout,
      Key? key})
      : super(key: key);

  final int maxCount;
  final Function? onTimeout;
  final Widget Function(int) displayChild;

  @override
  Widget build(BuildContext context) {
    int count = 0;
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          count += 1;

          bool isTimeout = false;
          if (count >= maxCount) {
            isTimeout = true;
          }
          if (count == (maxCount - 2)) {
            if (onTimeout != null) {
              Future.delayed(const Duration(seconds: 2), () {
                onTimeout!();
              });
            }
          }

          return !isTimeout ? displayChild(count) : displayChild(maxCount);
        });
  }
}
