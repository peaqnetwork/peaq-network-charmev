import 'package:charmev/common/models/detail.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/account.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;

import 'dart:async';

import 'package:charmev/theme.dart';

class CEVAccountProvider with ChangeNotifier {
  CEVAccountProvider({
    required this.cevSharedPref,
  });

  final CEVSharedPref cevSharedPref;

  late CEVApplicationProvider appProvider;

  static CEVAccountProvider of(BuildContext context) {
    return provider.Provider.of<CEVAccountProvider>(context);
  }

  LoadingStatus _status = LoadingStatus.idle;
  String _error = '';
  String _statusMessage = '';
  bool _isLoggedIn = false;
  bool _showNodeDropdown = false;
  CEVAccount? _account = CEVAccount();
  List<Detail> _details = [];
  // set the SS58 registry prefix
  // currently set to Substrate which is 42
  // ignore: todo
  // TODO:: change to PEAQ SS58 registry prefix when it's set
  final int _ss58 = 42;

  List<String> _events = [];
  List<String> _nodes = [Env.peaqTestnet];
  String _selectedNode = Env.peaqTestnet;

  String get error => _error;
  String get statusMessage => _statusMessage;
  LoadingStatus get status => _status;
  bool get isLoggedIn => _isLoggedIn;
  CEVAccount get account => _account!;
  List<Detail> get details => _details;
  List<String> get events => _events;
  List<String> get nodes => _nodes;
  String get selectedNode => _selectedNode;
  bool get showNodeDropdown => _showNodeDropdown;

  set showNodeDropdown(bool show) {
    _showNodeDropdown = show;
    notifyListeners();
  }

  set selectedNode(String node) {
    _selectedNode = node;
    notifyListeners();
  }

  addNode(String node) async {
    var exist = _nodes.contains(node);
    if (!exist) {
      _nodes.add(node);
      await cevSharedPref.init();
      cevSharedPref.prefs.setStringList(Env.nodePrefKey, _nodes);
    }
    notifyListeners();
  }

  _deleteNodes() async {
    await cevSharedPref.init();
    cevSharedPref.prefs.remove(Env.nodePrefKey);
  }

  _fetchNode() async {
    await cevSharedPref.init();
    List<String>? _savedNodes =
        cevSharedPref.prefs.getStringList(Env.nodePrefKey);

    if (_savedNodes != null) {
      if (_savedNodes.isNotEmpty) {
        _nodes = _savedNodes;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  // generate consumer account details
  generateDetails({bool notify = false}) {
    List<Detail> _newDetails = [];

    if (_account != null) {
      _newDetails.add(Detail("Identity", _account!.did ?? ""));
    }

    _newDetails.add(
      Detail("Balance", "${_account!.balance} ${_account!.tokenSymbol}",
          color: CEVTheme.accentColor),
    );
    _details = _newDetails;
    if (notify) {
      notifyListeners();
    }
  }

  /// Generate  consumer keys
  /// Generate wallet address
  /// Save the account details in shared preference for further retrival
  generateAccount(String secretPhrase) async {
    CEVAccount account =
        await appProvider.peerProvider.generateAccount(secretPhrase);
    print("account: ${accountToJson(account)}");

    await cevSharedPref.prefs
        .setString(Env.accountPrefKey, accountToJson(account));

    _account = account;

    generateDetails();

    await Future.wait([
      initBeforeOnboardingPage(),
    ]);

    notifyListeners();

    return;
  }

  getAccountBalance() async {
    String balance = await appProvider.peerProvider
        .getAccountBalance(_account!.tokenDecimals.toString(), _account!.seed!);
    print("balance: $balance");

    _account?.balance = double.parse(balance);
    print("new account: ${accountToJson(_account!)}");

    await cevSharedPref.prefs
        .setString(Env.accountPrefKey, accountToJson(account));

    _account = account;

    generateDetails();

    notifyListeners();

    return;
  }

  /// Fetch account saved in the shared pref
  Future<void> getAccount() async {
    await cevSharedPref.init();
    String? _accountString = cevSharedPref.prefs.getString(Env.accountPrefKey);

    if (_accountString != null) {
      _account = accountFromJson(_accountString);
    }
  }

  /// Delete account saved in the shared pref
  Future<void> _deleteAccount() async {
    await cevSharedPref.init();
    cevSharedPref.prefs.remove(Env.accountPrefKey);
  }

  /// Initializes the authenticated [CEVAccount].
  Future<bool> initBeforeOnboardingPage() async {
    await Future.wait([getAccount()]);

    if (_account != null) {
      _isLoggedIn = true;
      generateDetails(notify: true);
      _fetchNode();
    }

    return true;
  }

  /// Remove credentials before logout.
  initBeforeLogout() async {
    await _deleteAccount();
    _deleteNodes();
  }
}
