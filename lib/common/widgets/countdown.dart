import 'package:flutter/material.dart';

class CEVCountdown extends StatelessWidget {
  const CEVCountdown({required this.displayChild, Key? key}) : super(key: key);

  final Widget Function(int) displayChild;

  @override
  Widget build(BuildContext context) {
    int count = 0;
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          count += 1;
          return displayChild(count);
        });
  }
}
