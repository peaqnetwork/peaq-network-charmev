import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/providers/account_provider.dart';
import 'package:charmev/common/providers/charge_provider.dart';
import 'package:charmev/common/providers/peer_provider.dart';
import 'package:charmev/common/widgets/dropdown.dart';
import 'package:charmev/common/widgets/loading_view.dart';
import 'package:charmev/common/widgets/status_card.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/theme.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:scan/scan.dart';

import 'package:charmev/common/widgets/buttons.dart';
import 'package:charmev/common/widgets/custom_shapes.dart';
import 'package:charmev/config/env.dart';
import 'package:provider/provider.dart' as provider;

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.page, Key? key}) : super(key: key);

  final int? page;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String qrcode = 'Unknown';

  CEVChargeProvider? _dumbChargeProvider;

  @override
  void initState() {
    super.initState();
    _dumbChargeProvider =
        provider.Provider.of<CEVChargeProvider>(context, listen: false);
    _dumbChargeProvider!.qrController.resume();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CEVAccountProvider _accountProvider = CEVAccountProvider.of(context);
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Material(color: Colors.white, child: _buildMain(context)));
  }

  Widget _buildMain(BuildContext context) {
    CEVChargeProvider _chargeProvider = CEVChargeProvider.of(context);
    CEVAccountProvider _accountProvider = CEVAccountProvider.of(context);
    return provider.Consumer<CEVAccountProvider>(builder: (context, model, _) {
      return SafeArea(
          child: Stack(children: <Widget>[
        // _backgroundImage,
        Scaffold(
            backgroundColor: CEVTheme.bgColor,
            appBar: AppBar(
              title: _buildAppBarTitle(context, model),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: CEVTheme.appBarBgColor,
              leading: IconButton(
                  icon: const Icon(Icons.explore),
                  onPressed: () {
                    _dumbChargeProvider!.qrController.pause();
                    CEVApp.router.navigateTo(context, CEVRoutes.eventExplorer,
                        transition: TransitionType.inFromRight);
                  }),
              iconTheme: const IconThemeData(color: CEVTheme.textFadeColor),
              actions: [
                IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      // qrController.pause();
                      model.getAccountBalance();
                      CEVApp.router.navigateTo(context, CEVRoutes.account,
                          transition: TransitionType.inFromRight);
                    })
              ],
            ),
            body: GestureDetector(
              onTap: () => {},
              child: _buildScreen(context),
            )),
        Visibility(
          visible: _accountProvider.showNodeDropdown,
          child: CEVDropDown(
              items: _accountProvider.nodes,
              borderColor: CEVTheme.accentColor,
              onTap: (String item) {
                _accountProvider.showNodeDropdown =
                    !_accountProvider.showNodeDropdown;
                _accountProvider.selectedNode = item;
              }),
        ),
        Visibility(
            visible: (_chargeProvider.status != LoadingStatus.idle &&
                _chargeProvider.status != LoadingStatus.success),
            child: CEVLoadingView(
              status: _chargeProvider.status,
              loadingContent: CEVStatusCard(
                  text:
                      "${_chargeProvider.providerDid} \n\n ${Env.fetchingData}",
                  status: LoadingStatus.loading),
              errorContent: CEVStatusCard(
                  text:
                      "${_chargeProvider.providerDid} ${_chargeProvider.providerDid != '' ? '\n\n' : ''} ${_chargeProvider.statusMessage}",
                  status: LoadingStatus.error,
                  onTap: () {
                    _chargeProvider.reset();
                    _dumbChargeProvider!.qrController.resume();
                  }),
              successContent: const SizedBox(),
            )),
      ]));
    });
  }

  Widget _buildScreen(BuildContext context) {
    CEVChargeProvider _chargeProvider = CEVChargeProvider.of(context);
    CEVPeerProvider _peerProvider = CEVPeerProvider.of(context);
    final qrcodeSize = MediaQuery.of(context).size.width - 32;
    return SizedBox(
        height: double.infinity,
        // padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 25.0),
        child: SingleChildScrollView(
            child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.18,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                              width: qrcodeSize, // custom wrap size
                              height: qrcodeSize,
                              child: Stack(children: <Widget>[
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: CustomPaint(
                                    painter: CurvePainter(Colors.black),
                                    child: Container(
                                      margin: const EdgeInsets.all(0.3),
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: ScanView(
                                        controller:
                                            _dumbChargeProvider!.qrController,
                                        scanAreaScale: 1,
                                        scanLineColor: CEVTheme.dialogBgColor,
                                        onCapture: (data) async {
                                          print("Sacnned:: $data");
                                          print("Sacnned len:: ${data.length}");
                                          if (data.length > 64) {
                                            _chargeProvider.setStatus(
                                                LoadingStatus.error,
                                                message:
                                                    Env.invalidProviderDid);

                                            return;
                                          }
                                          _dumbChargeProvider!.qrController
                                              .pause();
                                          _chargeProvider.providerDid = data;
                                          await _chargeProvider
                                              .fetchProviderDidDocument(data);
                                          CEVApp.router.navigateTo(
                                              context, CEVRoutes.providerDetail,
                                              transition:
                                                  TransitionType.inFromRight);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                      const SizedBox(
                        height: 24.0,
                      ),
                      const Text(
                        Env.scanQRCode,
                      ),
                      // _buildImportButton(),
                    ]))));
  }

  Widget _buildAppBarTitle(
      BuildContext context, CEVAccountProvider accountProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Text(
                Env.scanProviderDID,
                style: CEVTheme.appTitleStyle,
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              height: 20,
              width: 240,
              // color: Colors.red,
              child: CEVRaisedButton(
                  text: accountProvider.selectedNode,
                  icon: accountProvider.showNodeDropdown
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  iconColor: CEVTheme.textFadeColor,
                  textColor: CEVTheme.textFadeColor,
                  spacing: 8,
                  padding: const EdgeInsets.all(2),
                  isIconRight: true,
                  textSize: 13,
                  isTextBold: true,
                  bgColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  elevation: MaterialStateProperty.all(0),
                  onPressed: () {
                    accountProvider.showNodeDropdown =
                        !accountProvider.showNodeDropdown;
                  }),
            )

            // _buildDropdown(context, accountProvider),
          ],
        )
      ],
    );
  }
}
