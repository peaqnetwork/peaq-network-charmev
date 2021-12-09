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

  final List<Detail> _details = [
    Detail("Identity", "did:pq:35203qr8s0fsfqßr23ßt23qfiwßfj43645z3sdivgsow"),
    Detail("Plug Type", "EV2021"),
    Detail("Status", "Available", color: CEVTheme.successColor),
    Detail("Power", "(22kW) 2,50 DKK / kwh"),
  ];

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
            leading: IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: () => Navigator.of(context).pop(),
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
            child: _buildScreen(context),
          )),
    ]);
  }

  Widget _buildScreen(BuildContext context) {
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
                      _buildDetails(boxW),
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
                            _buildStartButton(),
                            const SizedBox(
                              height: 40.0,
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

  Widget _buildDetails(double boxWidth) {
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
                children: _buildDetailTitleAndValue(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return CEVRaisedButton(
      text: Env.startCharging,
      bgColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      radius: 10,
      isTextBold: true,
      onPressed: () => CEVApp.router.navigateTo(
          context, CEVRoutes.chargingSession,
          transition: TransitionType.inFromRight),
    );
  }

  List<Widget> _buildDetailTitleAndValue() {
    var details = <Widget>[];

    for (var e in _details) {
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
