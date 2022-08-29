import 'package:charmev/common/providers/providers_wrapper.dart';
import 'package:charmev/common/widgets/service_container.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:charmev/config/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/config/navigator.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/theme.dart';
import 'package:provider/provider.dart' as provider;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CEVServiceContainer(
      child: CEVProvidersWrapper(child: CharmevApp())));
}

class CharmevApp extends StatefulWidget {
  const CharmevApp({Key? key}) : super(key: key);

  @override
  CharmevAppState createState() => CharmevAppState();
}

class CharmevAppState extends State<CharmevApp> {
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
    return provider.Consumer<CEVApplicationProvider>(
        builder: (context, model, _) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: CEVTheme.appBarBgColor));
      return MaterialApp(
        navigatorKey: CEVNavigator.key,
        title: Env.appName,
        theme: CEVTheme.theme,
        themeMode: ThemeMode.dark,
        initialRoute: CEVRoutes.entry,
        onGenerateRoute: CEVApp.router.generator,
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
