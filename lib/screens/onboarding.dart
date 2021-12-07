import 'package:charmev/config/app.dart';
import 'package:charmev/theme.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:charmev/common/widgets/buttons.dart';
import 'package:charmev/common/widgets/textfield.dart';
import 'package:charmev/common/widgets/dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/config/navigator.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/assets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({this.page, Key? key}) : super(key: key);

  final int? page;

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nodeAddressFieldController =
      TextEditingController(text: "https://testnet.peaq.network");
  final _secretPhraseFieldController = TextEditingController();
  bool _hideSecret = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nodeAddressFieldController.dispose();
    _secretPhraseFieldController.dispose();
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
    final _backgroundImage = Positioned.fill(
      top: 0.0,
      child: Container(
          // color: Colors.black,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(CEVImageAssets.bg),
                fit: BoxFit.cover,
                alignment: Alignment(.5, 100)),
          ),
          foregroundDecoration: const BoxDecoration(color: Colors.transparent)),
    );

    return Stack(children: <Widget>[
      _backgroundImage,
      Scaffold(
          backgroundColor: Colors.transparent,
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   backgroundColor: Colors.transparent,
          //   iconTheme: const IconThemeData(color: Colors.white),
          // ),
          body: GestureDetector(
            onTap: () => {},
            child: _buildScreen(context),
          )),
    ]);
  }

  Widget _buildScreen(BuildContext context) {
    final _nodeAddressField = CEVTextField(
      label: "Node Address",
      controller: _nodeAddressFieldController,
      filled: false,
      keyboardType: TextInputType.url,
      suffix: InkWell(
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: CEVTheme.greyColor,
          ),
        ),
        onTap: () => _openNodePicker(context),
      ),
      onChanged: () => {},
      onTap: () => {},
    );

    final _secretPhraseField = CEVTextField(
      label: "Secret Phrase",
      filled: false,
      obscureText: _hideSecret,
      controller: _secretPhraseFieldController,
      suffix: InkWell(
        child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.visibility,
              color: CEVTheme.greyColor,
              key: Key("hello"),
            )),
        onTap: () => {
          setState(() {
            _hideSecret = !_hideSecret;
          })
        },
      ),
      onChanged: () => {},
      onTap: () => {},
    );

    return Container(
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 25.0),
        child: SingleChildScrollView(
            child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.18,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        children: [
                          _buildLogo(context),
                          const SizedBox(
                            height: 24.0,
                          ),
                          _secretPhraseField,
                          const SizedBox(
                            height: 8.0,
                          ),
                          _nodeAddressField,
                          const SizedBox(
                            height: 8.0,
                          ),
                        ],
                      ),
                      _buildImportButton(),
                    ]))));
  }

  void _openNodePicker(BuildContext context) async {
    await showDialog<bool>(
        context: context,
        barrierLabel: "hello",
        barrierColor: Colors.transparent,
        // backgroundColor: Colors.transparent,
        // isScrollControlled: true,
        // elevation: 0,

        builder: (context) {
          return const Padding(
              padding: EdgeInsets.only(top: 220),
              child: CEVDialog(items: [
                "https://local.testnet.dev",
                "https://devnet.local"
              ]));
        });
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 25.0, 10.0),
        height: MediaQuery.of(context).size.height * 0.32,
        child: Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 2 / 3,
              child: SizedBox(
                height: 100,
                width: 100,
                child: SvgPicture.asset(
                  CEVImageAssets.logo,
                  height: 70,
                  width: 70,
                ),
              ),
            )));
  }

  Widget _buildImportButton() {
    return CEVRaisedButton(
      text: Env.importString,
      bgColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      radius: 10,
      onPressed: () => CEVApp.router.navigateTo(context, CEVRoutes.home,
          transition: TransitionType.fadeIn),
    );
  }
}
