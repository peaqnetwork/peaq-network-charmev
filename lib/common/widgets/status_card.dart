import 'package:charmev/common/models/enum.dart';
import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';

import 'buttons.dart';

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
                    padding: const EdgeInsets.only(top: 10),
                    margin: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: status == LoadingStatus.error
                          ? Colors.redAccent
                          : status == LoadingStatus.success
                              ? CEVTheme.successColor
                              : Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: CEVTheme.bgColor,
                            borderRadius: status == LoadingStatus.error ||
                                    status == LoadingStatus.success
                                ? const BorderRadius.all(Radius.circular(0))
                                : const BorderRadius.all(Radius.circular(10)),
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
                                          : status == LoadingStatus.success
                                              ? CEVTheme.successColor
                                              : Colors.white)
                                  : const SizedBox(),
                              const SizedBox(height: 16),
                              Text(
                                text,
                                textAlign: TextAlign.center,
                                style: CEVTheme.titleLabelStyle.copyWith(
                                    // fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white),
                              ),
                              status != LoadingStatus.loading
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          vertical: 8),
                                      child: CEVRaisedButton(
                                          text: "Ok",
                                          bgColor: CEVTheme.dialogBgColor,
                                          textColor: Colors.white,
                                          radius: 10,
                                          padding: const EdgeInsets.all(0),
                                          spacing: 0,
                                          isTextBold: false,
                                          onPressed: onTap))
                                  : const SizedBox()
                            ])))
              ],
            ))));
  }
}
