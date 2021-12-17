import 'package:charmev/config/app.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/theme.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan/scan.dart';

import 'package:charmev/config/env.dart';
import 'package:charmev/common/providers/account_provider.dart';
import 'package:provider/provider.dart' as provider;

class EventExplorerScreen extends StatefulWidget {
  const EventExplorerScreen({this.page, Key? key}) : super(key: key);

  final int? page;

  @override
  _EventExplorerScreenState createState() => _EventExplorerScreenState();
}

class _EventExplorerScreenState extends State<EventExplorerScreen>
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
            automaticallyImplyLeading: true,
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
    return provider.Consumer<CEVAccountProvider>(builder: (context, model, _) {
      return _buildEventList(model);
    });
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
              Env.eventExplorer,
              style: CEVTheme.appTitleStyle,
              textAlign: TextAlign.center,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildEventList(CEVAccountProvider accountProvider) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: accountProvider.events.length,
        // reverse: true,
        itemBuilder: (context, i) {
          return Wrap(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    accountProvider.events[i],
                    style: CEVTheme.labelStyle.copyWith(color: Colors.blue),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                  ))
            ],
          );
        });
  }
}
