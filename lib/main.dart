import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/config/navigator.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/screens/onboarding.dart';

void main() {
  runApp(const CharmevApp());
}

class CharmevApp extends StatefulWidget {
  const CharmevApp({Key? key}) : super(key: key);

  @override
  _CharmevAppState createState() => _CharmevAppState();
}

class _CharmevAppState extends State<CharmevApp> {
  @override
  void initState() {
    super.initState();
    final router = FluroRouter();
    CEVRoutes.configureRoutes(router);
    CEVApp.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return buildMaterialApp(context);
  }

  Widget buildMaterialApp(BuildContext context) {
    return MaterialApp(
      navigatorKey: CEVNavigator.key,
      title: "CharmEv",
      initialRoute: CEVRoutes.onboarding,
      onGenerateRoute: CEVApp.router.generator,
      debugShowCheckedModeBanner: false,
    );
  }
}
