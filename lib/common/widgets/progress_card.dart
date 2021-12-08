import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';

class CEVProgressCard extends StatelessWidget {
  const CEVProgressCard(
      {this.label = "",
      this.size = 20,
      this.progress = .80,
      this.color = Colors.white,
      this.bgColor = Colors.grey,
      this.borderColor = Colors.green,
      this.margin = const EdgeInsets.all(16),
      this.child = const SizedBox(),
      Key? key})
      : super(key: key);
  final double size;
  final double progress;
  final Color color;
  final Color bgColor;
  final String label;
  final Color borderColor;
  final EdgeInsetsGeometry margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    ThemeData _progressThemeData = Theme.of(context).copyWith(
        colorScheme:
            ColorScheme.fromSwatch().copyWith(primary: CEVTheme.successColor));
    Color _fadeColor = Theme.of(context).colorScheme.secondary.withOpacity(.2);

    var progressText = (progress * 100).round();
    var chargedAmount = (progressText * 5.3).roundToDouble();

    return Container(
      margin: margin,
      child: Column(
        children: [
          Stack(alignment: Alignment.center, children: <Widget>[
            SizedBox(
                height: size,
                width: size,
                child: Theme(
                    data: _progressThemeData,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: _fadeColor,
                      strokeWidth: 8,
                    ))),
            child,
          ]),
          const SizedBox(
            height: 16,
          ),
          Text(
            "$progressText% Charged",
            style: CEVTheme.titleLabelStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          Text(
            "$chargedAmount kWh",
            style: CEVTheme.labelStyle.copyWith(fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
