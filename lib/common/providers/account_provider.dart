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
  CEVAccountProvider();

  late CEVApplicationProvider appProvider;

  static CEVAccountProvider of(BuildContext context) {
    return provider.Provider.of<CEVAccountProvider>(context);
  }

  LoadingStatus _status = LoadingStatus.idle;
  String _statusMessage = '';
  bool _showNodeDropdown = false;
  bool _logoutInitiated = false;
  CEVAccount? _account;
  List<Detail> _details = [];
  List<String> _nodes = [Env.peaqTestnet];
  String _selectedNode = Env.peaqTestnet;

  String get statusMessage => _statusMessage;
  LoadingStatus get status => _status;
  CEVAccount get account => _account!;
  List<Detail> get details => _details;
  List<String> get nodes => _nodes;
  String get selectedNode => _selectedNode;
  bool get showNodeDropdown => _showNodeDropdown;

  Future<bool> get isLoggedIn async {
    var str =
        appProvider.cevSharedPrefs.prefs.getString(Env.accountPrefKey) ?? "";

    return str.isNotEmpty;
  }

  set showNodeDropdown(bool show) {
    _showNodeDropdown = show;
    notifyListeners();
  }

  set selectedNode(String node) {
    _selectedNode = node;
    notifyListeners();
  }

  reset() {
    _status = LoadingStatus.idle;
    _statusMessage = "";
    notifyListeners();
  }

  addNode(String node) async {
    var exist = _nodes.contains(node);
    if (!exist) {
      _nodes.add(node);
      appProvider.cevSharedPrefs.prefs.setStringList(Env.nodePrefKey, _nodes);
    }
    notifyListeners();
  }

  _deleteNodes() async {
    appProvider.cevSharedPrefs.prefs.remove(Env.nodePrefKey);
  }

  _fetchNode() async {
    List<String>? savedNodes =
        appProvider.cevSharedPrefs.prefs.getStringList(Env.nodePrefKey);

    if (savedNodes != null) {
      if (savedNodes.isNotEmpty) {
        _nodes = savedNodes;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  // generate consumer account details
  generateDetails({bool notify = false}) {
    List<Detail> newDetails = [];

    if (_account != null) {
      newDetails.add(Detail("Identity", _account!.did ?? ""));
    }

    newDetails.add(
      Detail("Balance", "${_account!.balance} ${_account!.tokenSymbol}",
          color: CEVTheme.accentColor),
    );
    _details = newDetails;
    if (notify) {
      notifyListeners();
    }
  }

  /// Generate  consumer keys
  /// Generate wallet address
  /// Save the account details in shared preference for further retrival
  generateAccount(String secretPhrase) async {
    _status = LoadingStatus.loading;
    _statusMessage = Env.generatingAccount;
    notifyListeners();
    CEVAccount account =
        await appProvider.peerProvider.generateAccount(secretPhrase);
    // print("account: ${accountToJson(account)}");

    await appProvider.cevSharedPrefs.prefs
        .setString(Env.accountPrefKey, accountToJson(account));

    _account = account;

    generateDetails();

    await Future.wait([
      initBeforeHomePage(),
    ]);
    reset();

    return;
  }

  getAccountBalance() async {
    String balance = await appProvider.peerProvider
        .getAccountBalance(_account!.tokenDecimals.toString(), _account!.seed!);
    // print("balance: $balance");

    _account?.balance = double.parse(balance);
    // print("new account: ${accountToJson(_account!)}");

    if (!_logoutInitiated) {
      await appProvider.cevSharedPrefs.prefs
          .setString(Env.accountPrefKey, accountToJson(account));

      _account = account;

      generateDetails();

      notifyListeners();
    }

    return;
  }

  /// Fetch account saved in the shared pref
  Future<void> getAccount() async {
    String? accountString =
        appProvider.cevSharedPrefs.prefs.getString(Env.accountPrefKey);

    if (accountString != null) {
      _account = accountFromJson(accountString);
    }
  }

  /// Delete account saved in the shared pref
  Future<void> _deleteAccount() async {
    appProvider.cevSharedPrefs.prefs.remove(Env.accountPrefKey);
    _logoutInitiated = true;
  }

  Future<bool> initBeforeHomePage() async {
    await Future.wait([getAccount()]);

    if (_account != null) {
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
