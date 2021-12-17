import 'package:charmev/common/providers/charge_provider.dart';
import 'package:charmev/keys.dart';
import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:charmev/common/widgets/buttons.dart';
import 'package:charmev/common/widgets/progress_card.dart';
import 'package:charmev/common/widgets/border_box.dart';
import 'package:charmev/common/widgets/bottom_sheet.dart';
import 'package:charmev/common/widgets/keyboard_padding.dart';
import 'package:charmev/common/widgets/countdown.dart';
import 'package:charmev/common/models/detail.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/assets.dart';
import 'package:provider/provider.dart' as provider;

class CharginSessionScreen extends StatefulWidget {
  const CharginSessionScreen({Key? key}) : super(key: key);

  @override
  _CharginSessionScreenState createState() => _CharginSessionScreenState();
}

class _CharginSessionScreenState extends State<CharginSessionScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Detail> _transactions = [
    Detail("Pay Station", "7.0 PEAQ"),
    Detail("Refund", "3.0 PEAQ"),
    Detail("Total", "10.0 PEAQ"),
  ];

  String qrcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Material(color: Colors.white, child: _buildMain(context)));
  }

  Widget _buildMain(BuildContext context) {
    return provider.Consumer<CEVChargeProvider>(builder: (context, model, _) {
      return Stack(children: <Widget>[
        Scaffold(
            backgroundColor: CEVTheme.bgColor,
            appBar: AppBar(
              title: _buildAppBarTitle(),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: CEVTheme.appBarBgColor,
              iconTheme: const IconThemeData(color: CEVTheme.textFadeColor),
            ),
            body: GestureDetector(
              onTap: () => {},
              child: _buildScreen(context, model),
            )),
      ]);
    });
  }

  Widget _buildScreen(BuildContext context, CEVChargeProvider chargeProvider) {
    final boxW = MediaQuery.of(context).size.width / 1.2;
    final _totalTimeInSeconds = 10;

    return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 32.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CEVCountdown(
                          maxCount: _totalTimeInSeconds,
                          onTimeout: () =>
                              _openAuthorizePaymentBottomSheet(context),
                          displayChild: (counter) {
                            var percent = counter / _totalTimeInSeconds;
                            double progress = (percent <= 1) ? percent : 1;

                            return CEVProgressCard(
                              progress: progress,
                              child: _buildPump(context),
                              size: 172,
                              margin: const EdgeInsets.all(32),
                            );
                          }),
                      _buildDetails(boxW, chargeProvider),
                      const SizedBox(
                        height: 50.0,
                      ),
                      SizedBox(
                        child: Column(
                          children: <Widget>[
                            const Text(
                              "3.21 PEAQ",
                              style: TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  color: CEVTheme.accentColor,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            _buildStopButton(context),
                            const SizedBox(
                              height: 100.0,
                            ),
                          ],
                        ),
                      ),

                      // _buildImportButton(),
                    ]))));
  }

  Widget _buildAppBarTitle() {
    return Text(
      "Sohn EV Charge Station",
      style: CEVTheme.appTitleStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDetails(double boxWidth, CEVChargeProvider chargeProvider) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: boxWidth, // custom wrap size
            child: CEVBorderBox(
              width: boxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildDetailTitleAndValue(chargeProvider),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPump(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 32, 0.0, 32.0),
        height: 150,
        child: Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: SizedBox(
                height: 70,
                width: 70,
                child: SvgPicture.asset(
                  CEVImageAssets.pump,
                ),
              ),
            )));
  }

  Widget _buildStopButton(BuildContext ctx) {
    return CEVRaisedButton(
      text: Env.stopCharging,
      bgColor: Theme.of(ctx).primaryColor,
      textColor: Colors.white,
      radius: 10,
      isTextBold: true,
      onPressed: () => _openAuthorizePaymentBottomSheet(ctx),
    );
  }

  List<Widget> _buildDetailTitleAndValue(CEVChargeProvider chargeProvider) {
    var details = <Widget>[];

    var item = chargeProvider.details[0];

    details.addAll([
      Text(
        item.id,
        style: const TextStyle(
            fontSize: 18, height: 1.5, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
      Text(
        item.value,
        style: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: item.color,
            fontWeight: FontWeight.w400),
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
      const SizedBox(
        height: 16,
      )
    ]);

    return details;
  }

  void _openAuthorizePaymentBottomSheet(BuildContext context) async {
    await showModalBottomSheet<bool>(
        context: context,
        barrierColor: CEVTheme.dialogBgColor.withOpacity(.5),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          final _header = Container(
              height: 10,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              // constraints: const BoxConstraints(maxWidth: 30),
              decoration: const BoxDecoration(
                  color: CEVTheme.greyColor,
                  borderRadius: BorderRadius.all(Radius.circular(20))));

          return CEVKeyboardPadding(
              child: CEVBottomSheet(
                  key: CEVKeys.authorizeBottomSheet,
                  childrenFlexSize: 11,
                  childrenPaddingTop: 1,
                  height: MediaQuery.of(context).size.height / 1.7,
                  header: _header,
                  boxPadding: 0,
                  children: _buildPayments(context)));
        });
  }

  List<Widget> _buildPayments(BuildContext context) {
    var children = <Widget>[];

    var _successIcon = const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Icon(
        Icons.check_circle_outline_outlined,
        color: CEVTheme.successColor,
        size: 50,
      ),
    );

    var _submitButton = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: CEVRaisedButton(
          text: Env.authorizePayment,
          bgColor: Theme.of(context).primaryColor,
          textColor: Colors.white,
          radius: 10,
          isTextBold: true,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ));

    children.add(_successIcon);

    for (var e in _transactions) {
      var title = Text(
        e.value,
        style: CEVTheme.titleLabelStyle
            .copyWith(color: CEVTheme.accentColor, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      );

      var suffix = Text(
        e.id,
        style: CEVTheme.labelStyle,
        overflow: TextOverflow.ellipsis,
      );

      final _field = CEVBorderBox(
          boxMargin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: 0,
          radius: 10,
          child: ListTile(title: title, trailing: suffix));

      children.add(_field);
    }

    children.add(_submitButton);

    return children;
  }
}
