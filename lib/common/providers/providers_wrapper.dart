import 'package:flutter/material.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:charmev/common/providers/service_provider.dart';
import 'package:charmev/common/providers/account_provider.dart';
import 'package:provider/provider.dart' as provider;

// / Wraps the app wide [Provider]s and holds the instances in its state.
class CEVProvidersWrapper extends StatefulWidget {
  const CEVProvidersWrapper({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  CEVProvidersWrapperState createState() => CEVProvidersWrapperState();
}

class CEVProvidersWrapperState extends State<CEVProvidersWrapper> {
  CEVApplicationProvider? applicationProvider;
  CEVAccountProvider? accountProvider;

  @override
  Widget build(BuildContext context) {
    final serviceProvider = CEVServiceProvider.of(context);

    accountProvider ??= CEVAccountProvider(
      cevSharedPref: serviceProvider!.data!.cevSharedPref,
    );

    applicationProvider ??= CEVApplicationProvider(context,
        cevSharedPrefs: serviceProvider!.data!.cevSharedPref,
        accountProvider: accountProvider);

    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<CEVApplicationProvider?>(
          create: (_) => applicationProvider,
        ),
        provider.ChangeNotifierProvider<CEVAccountProvider?>(
          create: (_) => accountProvider,
        ),
      ],
      child: widget.child,
    );
  }
}
