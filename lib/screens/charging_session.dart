import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/providers/charge_provider.dart';
import 'package:charmev/common/providers/peer_provider.dart';
import 'package:charmev/common/widgets/loading_view.dart';
import 'package:charmev/common/widgets/status_card.dart';
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
  bool isScrollStart = false;
  final ScrollController _tabScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
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
    CEVChargeProvider chargeProvider = CEVChargeProvider.of(context);

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
            child: _buildScreen(context, chargeProvider),
          )),
      Visibility(
          visible: chargeProvider.chargingStatus == LoadingStatus.authorize,
          child: _buildAuthorizePaymentTab(context, chargeProvider)),
      Visibility(
          visible: (chargeProvider.status != LoadingStatus.idle &&
              chargeProvider.status != LoadingStatus.success),
          child: CEVLoadingView(
            status: chargeProvider.status,
            loadingContent: CEVStatusCard(
                text: chargeProvider.statusMessage,
                status: LoadingStatus.loading),
            errorContent: CEVStatusCard(
                text: chargeProvider.statusMessage,
                status: LoadingStatus.error,
                onTap: () async {
                  chargeProvider.reset();
                  if (chargeProvider.chargingStatus == LoadingStatus.idle) {
                    Navigator.pop(context);
                  }
                }),
            successContent: const SizedBox(),
          )),
      Visibility(
          visible: (chargeProvider.chargingStatus != LoadingStatus.idle &&
              chargeProvider.chargingStatus == LoadingStatus.success),
          child: CEVLoadingView(
            status: chargeProvider.chargingStatus,
            loadingContent: const SizedBox(),
            errorContent: const SizedBox(),
            successContent: CEVStatusCard(
                text: chargeProvider.statusMessage,
                status: LoadingStatus.success,
                onTap: () async {
                  Navigator.pop(context);
                  chargeProvider.reset();
                  chargeProvider.chargingStatus = LoadingStatus.idle;
                }),
          )),
    ]);
  }

  Widget _buildScreen(BuildContext context, CEVChargeProvider chargeProvider) {
    final boxW = MediaQuery.of(context).size.width / 1.2;
    CEVPeerProvider peerProvider = CEVPeerProvider.of(context);

    print("charge progress:: ${peerProvider.chargeProgress}");

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
                      CEVProgressCard(
                        progress: peerProvider.chargeProgress,
                        child: _buildPump(context),
                        size: 172,
                        margin: const EdgeInsets.all(32),
                      ),
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
                            _buildStopButton(context, chargeProvider),
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

  Widget _buildStopButton(BuildContext ctx, CEVChargeProvider chargeProvider) {
    var isCharging = chargeProvider.chargingStatus == LoadingStatus.charging;
    var stopUrlSet = false; //chargeProvider.station!.stopUrl != null;
    return CEVRaisedButton(
      text: isCharging ? Env.stopCharging : Env.charged,
      bgColor: isCharging && stopUrlSet
          ? Theme.of(ctx).primaryColor
          : CEVTheme.dialogBgColor,
      textColor: isCharging && stopUrlSet ? Colors.white : CEVTheme.greyColor,
      radius: 10,
      isTextBold: true,
      onPressed: () async {
        if (isCharging && stopUrlSet) {
          chargeProvider.stopCharge();
        }
        // chargeProvider.simulateStopCharge(true);
      },
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

  List<Widget> _buildPayments(
      BuildContext context, CEVChargeProvider chargeProvider) {
    var children = <Widget>[];

    var _successIcon = const Padding(
      padding: EdgeInsets.only(bottom: 3),
      child: Icon(
        Icons.check_circle_outline_outlined,
        color: CEVTheme.successColor,
        size: 60,
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
          onPressed: () async {
            await chargeProvider.approveTransactions();
            // chargeProvider.simulateApproveTransactions();
          },
        ));

    children.add(_successIcon);
    children.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            chargeProvider.progress >= 1 ? Env.fullyCharged : Env.charged,
            style: CEVTheme.titleLabelStyle,
            overflow: TextOverflow.ellipsis,
          )
        ])));

    for (var e in chargeProvider.transactions) {
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

  Widget _buildAuthorizePaymentTab(
      BuildContext context, CEVChargeProvider chargeProvider) {
    final _header = Container(
        height: 7,
        width: 50,
        margin: const EdgeInsets.only(bottom: 0),
        // constraints: const BoxConstraints(maxWidth: 30),
        decoration: const BoxDecoration(
            color: CEVTheme.greyColor,
            borderRadius: BorderRadius.all(Radius.circular(20))));

    return Positioned.fill(
        top: 0,
        child: Container(
            color: CEVTheme.dialogBgColor.withOpacity(0.5),
            child: NotificationListener<ScrollNotification>(
              child: SingleChildScrollView(
                controller: _tabScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height / 2.9),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.3,
                        decoration: BoxDecoration(
                            color: CEVTheme.bgColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 0),
                            child: Column(children: [
                              const SizedBox(
                                height: 16,
                              ),
                              _header,
                              const SizedBox(
                                height: 10,
                              ),
                              ..._buildPayments(context, chargeProvider)
                            ]))),
                  ],
                ),
              ),
            )));
  }
}
