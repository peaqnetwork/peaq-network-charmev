import 'package:charmev/config/app.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/theme.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan/scan.dart';

import 'package:charmev/common/widgets/buttons.dart';
import 'package:charmev/common/widgets/dialog.dart';
import 'package:charmev/common/widgets/custom_shapes.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/assets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.page, Key? key}) : super(key: key);

  final int? page;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ScanController qrController = ScanController();
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
    return Stack(children: <Widget>[
      // _backgroundImage,
      Scaffold(
          backgroundColor: CEVTheme.bgColor,
          appBar: AppBar(
            title: _buildAppBarTitle(),
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: CEVTheme.appBarBgColor,
            iconTheme: const IconThemeData(color: CEVTheme.textFadeColor),
            actions: [
              IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    // qrController.pause();
                    CEVApp.router.navigateTo(context, CEVRoutes.account,
                        transition: TransitionType.inFromRight);
                  })
            ],
          ),
          body: GestureDetector(
            onTap: () => {},
            child: _buildScreen(context),
          )),
    ]);
  }

  Widget _buildScreen(BuildContext context) {
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
                                        controller: qrController,
                                        scanAreaScale: 1,
                                        scanLineColor: CEVTheme.dialogBgColor,
                                        onCapture: (data) {
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

  Widget _buildAppBarTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              Env.scanProviderDID,
              style: CEVTheme.appTitleStyle,
              textAlign: TextAlign.center,
            ),
            _buildDropdown(),
          ],
        )
      ],
    );
  }

  Widget _buildDropdown() {
    return DropdownButton<String>(
        value: "https://testnet.peaq.network",
        isDense: true,
        isExpanded: false,
        style: Theme.of(context).textTheme.headline6?.copyWith(
            letterSpacing: 0, color: CEVTheme.textFadeColor, fontSize: 12
            // fontWeight: FontWeight.bold

            ),
        underline: const SizedBox(),
        alignment: AlignmentDirectional.center,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: CEVTheme.textFadeColor,
        ),
        items: [
          "https://testnet.peaq.network",
          "https://local.testnet.dev",
          "https://devnet.local"
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 13, color: CEVTheme.textFadeColor),
              ));
        }).toList(),
        onChanged: (value) {});
  }
}
