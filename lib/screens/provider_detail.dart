import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:charmev/common/providers/charge_provider.dart';
import 'package:charmev/common/providers/peer_provider.dart';
import 'package:charmev/common/widgets/loading_view.dart';
import 'package:charmev/common/widgets/status_card.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/theme.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:charmev/common/models/detail.dart';

import 'package:charmev/common/widgets/buttons.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/assets.dart';
import 'package:charmev/common/widgets/border_box.dart';
import 'package:provider/provider.dart' as provider;

class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({this.page, Key? key}) : super(key: key);

  final int? page;

  @override
  _ProviderDetailScreenState createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    CEVChargeProvider _chargeProvider = CEVChargeProvider.of(context);

    return WillPopScope(
        onWillPop: () async {
          _chargeProvider.qrController.resume();
          return true;
        },
        child: _buildMain(context, _chargeProvider));
  }

  Widget _buildMain(BuildContext context, CEVChargeProvider model) {
    return Stack(children: <Widget>[
      // _backgroundImage,
      Scaffold(
          backgroundColor: CEVTheme.bgColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: () {
                model.qrController.resume();
                Navigator.of(context).pop();
              },
            ),
            title: _buildAppBarTitle(),
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: CEVTheme.appBarBgColor,
            iconTheme: const IconThemeData(color: CEVTheme.textFadeColor),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => CEVApp.router.navigateTo(
                    context, CEVRoutes.account,
                    transition: TransitionType.inFromRight),
              )
            ],
          ),
          body: GestureDetector(
            onTap: () => {},
            child: _buildScreen(context, model),
          )),
      Visibility(
          visible: (model.status != LoadingStatus.idle &&
              model.status != LoadingStatus.success),
          child: CEVLoadingView(
            status: model.status,
            loadingContent: CEVStatusCard(
                text: model.statusMessage, status: LoadingStatus.loading),
            errorContent: CEVStatusCard(
                text: model.statusMessage,
                status: LoadingStatus.error,
                onTap: () {
                  model.reset();
                }),
            successContent: const SizedBox(),
          )),
    ]);
  }

  Widget _buildScreen(BuildContext context, CEVChargeProvider chargeProvider) {
    final boxW = MediaQuery.of(context).size.width / 1.2;
    return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 32.0),
                // height: MediaQuery.of(context).size.height / 1.18,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildPump(context),
                      _buildDetails(boxW, chargeProvider),
                      const SizedBox(
                        height: 50.0,
                      ),
                      SizedBox(
                        child: Column(
                          children: <Widget>[
                            Text(
                              "0.21 PEAQ/KWh",
                              style: CEVTheme.titleLabelStyle
                                  .copyWith(color: CEVTheme.accentColor),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            _buildStartButton(chargeProvider),
                            const SizedBox(
                              height: 100.0,
                            ),
                          ],
                        ),
                      ),
                    ]))));
  }

  Widget _buildAppBarTitle() {
    return Text(
      "Sohn EV Charge Station",
      style: CEVTheme.appTitleStyle,
      textAlign: TextAlign.center,
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

  Widget _buildDetails(double boxWidth, CEVChargeProvider chargeProvider) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: boxWidth, // custom wrap size
            child: CEVBorderBox(
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

  Widget _buildStartButton(CEVChargeProvider chargeProvider) {
    CEVApplicationProvider appProvider = CEVApplicationProvider.of(context);
    CEVPeerProvider _peerProvider = CEVPeerProvider.of(context);
    return CEVRaisedButton(
        text: Env.startCharging,
        bgColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        radius: 10,
        isTextBold: true,
        onPressed: () async {
          chargeProvider.setStatus(LoadingStatus.loading,
              message: Env.verifyingDidDocument);
          await _peerProvider.verifyPeerDidDocument();
          if (_peerProvider.isPeerDidDocVerified) {
            chargeProvider.setStatus(LoadingStatus.loading,
                message: Env.connectingToPeer);
            _peerProvider.connectP2P();

            // delay to allow app to establish peer connection
            await Future.delayed(const Duration(milliseconds: 2000));

            chargeProvider.setStatus(LoadingStatus.loading,
                message: Env.authenticatingProvider);
            // send identity challenge to peer for verification
            await _peerProvider.sendIdentityChallengeEvent();
          } else {
            chargeProvider.setStatus(LoadingStatus.error,
                message: Env.didVerificationFailed);
          }
        });
  }

  List<Widget> _buildDetailTitleAndValue(CEVChargeProvider chargeProvider) {
    var details = <Widget>[];

    for (var e in chargeProvider.details) {
      var item = e;
      details.addAll([
        Text(
          item.id,
          style: CEVTheme.titleLabelStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
        Text(
          item.value,
          style: CEVTheme.labelStyle.copyWith(color: item.color),
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
        const SizedBox(
          height: 16,
        )
      ]);
    }

    return details;
  }
}
