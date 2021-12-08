import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:charmev/common/widgets/buttons.dart';
import 'package:charmev/common/models/detail.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/assets.dart';

class CharginSessionScreen extends StatefulWidget {
  const CharginSessionScreen({Key? key}) : super(key: key);

  @override
  _CharginSessionScreenState createState() => _CharginSessionScreenState();
}

class _CharginSessionScreenState extends State<CharginSessionScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String qrcode = 'Unknown';

  final List<Detail> _details = [
    Detail("Identity", "did:pq:35203qr8s0fsfqßr23ßt23qfiwßfj43645z3sdivgsow")
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
          backgroundColor: Colors.black,
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
                onPressed: () {},
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                              width: boxW, // custom wrap size
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Container(
                                  width: boxW,
                                  margin: const EdgeInsets.all(1),
                                  padding: const EdgeInsets.all(32),
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _buildDetailTitleAndValue(),
                                  ),
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 50.0,
                      ),
                      SizedBox(
                        child: Column(
                          children: <Widget>[
                            const Text(
                              "0.21 PEAQ/KWh",
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
    return const Text(
      "Sohn EV Charge Station",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildStartButton() {
    return CEVRaisedButton(
      text: Env.stopCharging,
      bgColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      radius: 10,
      isTextBold: true,
      onPressed: () => {},
    );
  }

  List<Widget> _buildDetailTitleAndValue() {
    var details = <Widget>[];

    for (var e in _details) {
      var item = e;
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
    }

    return details;
  }
}
