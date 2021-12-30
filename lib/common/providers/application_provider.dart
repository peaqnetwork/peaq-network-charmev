import 'package:charmev/common/providers/account_provider.dart';
import 'package:charmev/common/widgets/route.dart';
import 'package:charmev/screens/charging_session.dart';
import 'package:charmev/screens/provider_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charmev/common/utils/logger.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:logging/logging.dart';
import 'package:charmev/screens/home.dart';
import 'package:provider/provider.dart' as provider;
import 'package:charmev/config/navigator.dart';
import 'package:charmev/screens/onboarding.dart';

import 'package:charmev/common/providers/charge_provider.dart';

// / The [CEVApplicationProvider] handles initialization in the [EntryScreen] when
/// starting the app.
class CEVApplicationProvider extends ChangeNotifier {
  CEVApplicationProvider(BuildContext context,
      {required this.cevSharedPrefs,
      required this.accountProvider,
      required this.chargeProvider}) {
    _initialize(context);
  }

  final CEVSharedPref cevSharedPrefs;
  final CEVAccountProvider accountProvider;
  final CEVChargeProvider chargeProvider;

  static CEVApplicationProvider of(BuildContext context) {
    return provider.Provider.of<CEVApplicationProvider>(context);
  }

  static final Logger _log = Logger("CEVApplicationProvider");

  /// Whether or not the [CEVApplicationProvider] has been initialized.
  bool initialized = false;
  // holds the consumer authentication status
  bool _authenticated = false;

  // / Returns true when consumer has imported account
  ///
  // / Always false if [initialized] is also false.
  bool get authenticated => _authenticated;

  set authenticated(bool isLoggedin) {
    _authenticated = isLoggedin;
    notifyListeners();
  }

  Future<void> _initialize(context) async {
    initLogger();
    _log.fine("initializing");
    // set application model references
    cevSharedPrefs.appProvider = this;
    accountProvider.appProvider = this;
    chargeProvider.appProvider = this;

    await Future.wait([
      // charmev shared preferences
      // Initialize the shared preference
      cevSharedPrefs.init(),
      accountProvider.initBeforeOnboardingPage(),
    ]);
    chargeProvider.generateDetails(notify: true);

    if (accountProvider.isLoggedIn) {
      _authenticated = true;
      notifyListeners();
      initAuthenticated();
    }

    initialized = true;
    _onInitialized(context);
  }

  /// Called when the [CEVApplicationProvider] finished initializing and navigates
  /// to the next screen.
  Future<void> _onInitialized(BuildContext context) async {
    _log.fine("on initialized");

    if (authenticated) {
      _log.fine("navigating to home screen");
      accountProvider.connectNode();
      CEVNavigator.pushReplacementRoute(CEVFadeRoute(
        builder: (context) => const HomeScreen(),
        duration: const Duration(milliseconds: 600),
      ));
    } else {
      CEVNavigator.pushReplacementRoute(CEVFadeRoute(
        builder: (context) => const OnboardingScreen(),
        duration: const Duration(milliseconds: 600),
      ));
    }
  }

  // / Called when initializing and already authenticated or
  // / in the [CEVAuthProvider] after authenticating for the first time.
  void initAuthenticated() {}
}
