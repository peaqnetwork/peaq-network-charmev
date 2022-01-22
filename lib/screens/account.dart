import 'package:charmev/common/providers/account_provider.dart';
import 'package:charmev/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/config/navigator.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/theme.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:charmev/common/models/detail.dart';

import 'package:charmev/common/widgets/buttons.dart';
import 'package:charmev/common/widgets/route.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/assets.dart';
import 'package:charmev/common/widgets/border_box.dart';
import 'package:provider/provider.dart' as provider;

class AccountScreen extends StatefulWidget {
  const AccountScreen({this.page, Key? key}) : super(key: key);

  final int? page;

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    return provider.Consumer<CEVAccountProvider>(builder: (context, model, _) {
      return Stack(children: <Widget>[
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
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    CEVApp.router.navigateTo(context, "/on-boarding/2",
                        transition: TransitionType.inFromRight);
                  },
                )
              ],
            ),
            body: GestureDetector(
              onTap: () => {},
              child: _buildScreen(context, model),
            )),
      ]);
    });
  }

  Widget _buildScreen(
      BuildContext context, CEVAccountProvider accountProvider) {
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
                      _buildAvatar(context),
                      _buildDetails(boxW, accountProvider),
                      const SizedBox(
                        height: 50.0,
                      ),
                      _buildLogoutButton(accountProvider),
                      const SizedBox(
                        height: 100.0,
                      ),
                    ]))));
  }

  Widget _buildAppBarTitle() {
    return Text(
      Env.account,
      style: CEVTheme.appTitleStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 32, 0.0, 32.0),
        height: 150,
        child: Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: SizedBox(
                height: 100,
                width: 100,
                child: SvgPicture.asset(
                  CEVImageAssets.avatar,
                ),
              ),
            )));
  }

  Widget _buildDetails(double boxWidth, CEVAccountProvider accountProvider) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: boxWidth, // custom wrap size
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildDetailTitleAndValue(boxWidth, accountProvider),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogoutButton(CEVAccountProvider accountProvider) {
    return CEVRaisedButton(
      text: Env.logout,
      bgColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      radius: 10,
      isTextBold: true,
      onPressed: () {
        accountProvider.initBeforeLogout();
        CEVNavigator.popAllAndPushNamed("/on-boarding/0");
        // CEVNavigator.pushReplacementRoute(CEVFadeRoute(
        //   builder: (context) => const OnboardingScreen(),
        //   duration: const Duration(milliseconds: 600),
        // ));
      },
    );
  }

  List<Widget> _buildDetailTitleAndValue(
      double width, CEVAccountProvider accountProvider) {
    var details = <Widget>[];

    var _details = accountProvider.details;

    for (var e in _details) {
      var item = e;
      details.addAll([
        CEVBorderBox(
            width: width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                item.id,
                style: CEVTheme.titleLabelStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
              Text(
                item.value,
                style: CEVTheme.labelStyle.copyWith(color: e.color),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ])),
        const SizedBox(
          height: 16,
        )
      ]);
    }

    return details;
  }
}
