import 'package:charmev/common/widgets/dropdown.dart';
import 'package:charmev/common/widgets/route.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/screens/event_explorer.dart';
import 'package:charmev/screens/home.dart';
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
import 'package:charmev/common/providers/account_provider.dart';
import 'package:charmev/assets.dart';
import 'package:provider/provider.dart' as provider;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({this.page = 1, Key? key}) : super(key: key);
// page = 1 - default screen page
// page = 2 - Account edit screen page
  final int? page;

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nodeAddressFieldController =
      TextEditingController(text: Env.peaqTestnet);
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
        child: _buildMain(context));
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

    return provider.Consumer<CEVAccountProvider>(builder: (context, model, _) {
      return Stack(children: <Widget>[
        // page 2 is routed from account edit screen
        // Changes was made to suite the edir account page
        // instead of creating a new screen
        (widget.page != 2) ? _backgroundImage : const SizedBox(),
        Scaffold(
            backgroundColor:
                (widget.page != 2) ? Colors.transparent : CEVTheme.bgColor,
            appBar: (widget.page == 2)
                ? AppBar(
                    title: _buildAppBarTitle(),
                    centerTitle: true,
                    automaticallyImplyLeading: true,
                    backgroundColor: CEVTheme.appBarBgColor,
                    iconTheme:
                        const IconThemeData(color: CEVTheme.textFadeColor),
                  )
                : null,
            body: GestureDetector(
              onTap: () => {},
              child: _buildScreen(context),
            )),
      ]);
    });
  }

  Widget _buildScreen(BuildContext context) {
    var accountProvider = CEVAccountProvider.of(context);

    final _nodeAddressField = CEVTextField(
      label: "Node Address",
      controller: _nodeAddressFieldController,
      filled: false,
      keyboardType: TextInputType.url,
      bottomMargin: 0,
      suffix: InkWell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Icon(
              accountProvider.showNodeDropdown
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: CEVTheme.greyColor,
            ),
          ),
          onTap: () {
            accountProvider.showNodeDropdown =
                !accountProvider.showNodeDropdown;
          }),
      onChanged: (value) => {},
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
      onChanged: (value) => {},
      onTap: () => {},
    );

    return Container(
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 25.0),
        child: SingleChildScrollView(
            child: SizedBox(
                // height: MediaQuery.of(context).size.height / 1.18,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
              Column(
                children: [
                  (widget.page != 2) ? _buildLogo(context) : const SizedBox(),
                  (widget.page != 2)
                      ? const SizedBox(
                          height: 24.0,
                        )
                      : const SizedBox(
                          height: 150,
                        ),
                  _secretPhraseField,
                  const SizedBox(
                    height: 8.0,
                  ),
                  SizedBox(
                    height: 180.0,
                    child: Stack(
                      children: [
                        Positioned(
                          child: _nodeAddressField,
                        ),
                        Positioned.fill(
                          // height: MediaQuery.of(context).size.height / 1.18,
                          top: 70,
                          child: Visibility(
                              visible: accountProvider.showNodeDropdown,
                              child: Container(
                                height: 100,
                                color: Colors.transparent,
                                child: CEVDropDown(
                                    items: accountProvider.nodes,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 2, 0, 0),
                                    borderColor: CEVTheme.accentColor,
                                    radius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    onTap: (String item) {
                                      _nodeAddressFieldController.text = item;
                                      accountProvider.showNodeDropdown =
                                          !accountProvider.showNodeDropdown;
                                      accountProvider.selectedNode = item;
                                    }),
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              _buildImportButton(accountProvider),
              const SizedBox(
                height: 50.0,
              ),
            ]))));
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

  Widget _buildAppBarTitle() {
    return Text(
      Env.editAccount,
      style: CEVTheme.appTitleStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildImportButton(CEVAccountProvider accountProvider) {
    return CEVRaisedButton(
        text: Env.importString,
        bgColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        isTextBold: true,
        radius: 10,
        onPressed: () async {
          if (widget.page == 2) {
            Navigator.of(context).pop();
            return;
          }

          var node = _nodeAddressFieldController.text;
          var secretPhrase = _secretPhraseFieldController.text;
          if (node.isNotEmpty && secretPhrase.isNotEmpty) {
            await accountProvider.generateConsumerKeys(secretPhrase);
            if (accountProvider.isLoggedIn) {
              CEVNavigator.pushReplacementRoute(CEVFadeRoute(
                builder: (context) => const HomeScreen(),
                duration: const Duration(milliseconds: 600),
              ));
            }
            accountProvider.selectedNode = node;
            accountProvider.addNode(node);
            accountProvider.connectNode();
          }
        });
  }
}
