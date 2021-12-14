import 'package:charmev/common/models/detail.dart';
import 'package:charmev/config/env.dart';
import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/api/subscan.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/service/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/account.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;

import 'package:charmev/theme.dart';

class CEVAccountProvider with ChangeNotifier {
  CEVAccountProvider({
    required this.cevSharedPref,
  });

  final CEVSharedPref? cevSharedPref;

  CEVApplicationProvider? appProvider;

  static CEVAccountProvider of(BuildContext context) {
    return provider.Provider.of<CEVAccountProvider>(context);
  }

  LoadingStatus _status = LoadingStatus.idle;
  String _error = '';
  String _statusMessage = '';
  bool _isLoggedIn = false;
  CEVAccount? _account;
  List<Detail> _details = [];
  final _sdk = WalletSDK();
  final Keyring _keyring = Keyring();

  String get error => _error;
  String get statusMessage => _statusMessage;
  LoadingStatus get status => _status;
  bool get isLoggedIn => _isLoggedIn;
  CEVAccount get account => _account!;
  List<Detail> get details => _details;

  // generate consumer account details
  generateDetails({bool notify = false}) {
    List<Detail> _newDetails = [];

    print("_account:: $_account");
    print("_account::did  ${_account!.did}");

    if (_account != null) {
      _newDetails.add(Detail("Identity", _account!.did ?? ""));
    }

    _newDetails.add(
      Detail("Balance", "103.90 PEAQ", color: CEVTheme.accentColor),
    );
    _details = _newDetails;
    if (notify) {
      print("_account:: notified");
      notifyListeners();
    }
  }

  Future<void> initSDK() async {
    // set the SS58 registry prefix
    // currently set to BareSr25519 which is 1
    // ignore: todo
    // TODO:: change to PEAQ SS58 registry prefix when it's set
    int ss58 = 1;
    await _keyring.init([ss58]);
    _keyring.setSS58(ss58);

    // init the polkawallet
    await _sdk.init(_keyring);
  }

  /// Generate  consumer keys
  /// Generate wallet address
  /// Save the account details in shared preference for further retrival
  generateConsumerKeys(String secretPhrase) async {
    // added network prefix to all generated consumer keys
    String networkSuffix = "//peaq";

    // generate the address and consumer keys from secret phrase
    final res = await _sdk.api.keyring.importAccount(
      _keyring,
      keyType: KeyType.mnemonic,
      cryptoType: CryptoType.sr25519,
      derivePath: networkSuffix,
      key: secretPhrase,
      name: '',
      password: '',
    );

    final String? address = res!["address"];
    final String? pubKey = res["pubKey"];

    final CEVAccount acct =
        CEVAccount(address: address, pk: pubKey, did: "did:pq:$address");
    _account = acct;

    await cevSharedPref!.prefs!
        .setString(Env.accountPrefKey, accountToJson(acct));

    generateDetails();

    await Future.wait([
      initBeforeOnboardingPage(),
    ]);

    notifyListeners();

    return;
  }

  /// Fetch account saved in the shared pref
  Future<void> getAccount() async {
    await cevSharedPref!.init();
    String? _accountString =
        cevSharedPref!.prefs!.getString(Env.accountPrefKey);

    if (_accountString != null) {
      _account = accountFromJson(_accountString);
    }
  }

  /// Initializes the authenticated [CEVAccount].
  Future<bool> initBeforeOnboardingPage() async {
    await Future.wait([
      getAccount(),
    ]);

    if (_account != null) {
      _isLoggedIn = true;
      generateDetails(notify: true);
    }

    return true;
  }
}
