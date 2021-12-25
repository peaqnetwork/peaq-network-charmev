import 'package:charmev/common/models/enum.dart';
import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';

class CEVStatusCard extends StatelessWidget {
  const CEVStatusCard(
      {required this.text,
      required this.status,
      this.isLinear = false,
      this.progress,
      this.strokeWidth = 2,
      this.onTap,
      Key? key})
      : super(key: key);

  final String text;
  final LoadingStatus status;
  final double? progress;
  final bool isLinear;
  final double strokeWidth;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    print("CEVStatusCard progress:: $progress");
    // String flareUrl = MDImageAssets.loader;
    return GestureDetector(
        onTap: status == LoadingStatus.loading ? null : onTap!,
        child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: CEVTheme.bgColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10.0,
                            color: CEVTheme.dialogBgColor.withOpacity(0.5),
                          ),
                        ]),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          (status == LoadingStatus.loading)
                              ? (isLinear)
                                  ? LinearProgressIndicator(value: progress)
                                  : (progress == null || progress == 0)
                                      ? CircularProgressIndicator(
                                          key: const Key("PROGRESS_BAR_1"),
                                          strokeWidth: strokeWidth)
                                      : CircularProgressIndicator(
                                          key: const Key("PROGRESS_BAR_2"),
                                          value: progress,
                                          backgroundColor: Colors.grey,
                                          semanticsValue:
                                              "${progress.toString()}%",
                                          strokeWidth: strokeWidth)
                              : const SizedBox(),
                          (status == LoadingStatus.error ||
                                  status == LoadingStatus.success)
                              ? Icon(
                                  status == LoadingStatus.error
                                      ? Icons.cancel
                                      : Icons.check_circle_outline,
                                  size: 34,
                                  color: status == LoadingStatus.error
                                      ? Colors.redAccent
                                      : CEVTheme.accentColor)
                              : const SizedBox(),
                          const SizedBox(height: 16),
                          Text(
                            text,
                            textAlign: TextAlign.center,
                            style: CEVTheme.titleLabelStyle.copyWith(
                                // fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: status == LoadingStatus.error
                                    ? Colors.redAccent
                                    : CEVTheme.accentColor),
                          )
                        ]))
              ],
            ))));
  }
}
