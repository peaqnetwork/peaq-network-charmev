import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/config/navigator.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: CEVTheme.appBarBgColor));
    return MaterialApp(
      navigatorKey: CEVNavigator.key,
      title: "CharmEv",
      theme: CEVTheme.theme,
      themeMode: ThemeMode.dark,
      initialRoute: CEVRoutes.chargingSession,
      onGenerateRoute: CEVApp.router.generator,
      debugShowCheckedModeBanner: false,
    );
  }
}
