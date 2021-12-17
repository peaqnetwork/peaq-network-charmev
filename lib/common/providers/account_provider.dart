import 'package:charmev/common/models/detail.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/account.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;

import 'package:nanodart/nanodart.dart';

import 'package:json_rpc_2/json_rpc_2.dart' as rpc;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as socketStatus;

import 'package:substrate_sign_flutter/substrate_sign_flutter.dart' as subsign;
import "package:hex/hex.dart";
import 'package:bip39/bip39.dart' as bip39;
import 'dart:async';
import 'dart:convert';

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
  // set the SS58 registry prefix
  // currently set to Substrate which is 42
  // ignore: todo
  // TODO:: change to PEAQ SS58 registry prefix when it's set
  final int _ss58 = 42;

  rpc.Client? _rpcClient;
  WebSocketChannel? _socket;

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

  set selectedNode(String node) {
    _selectedNode = node;
    notifyListeners();
  }

  addNode(String node) async {
    var exist = _nodes.contains(node);
    if (!exist) {
      _nodes.add(node);
      await cevSharedPref!.init();
      cevSharedPref!.prefs!.setStringList(Env.nodePrefKey, _nodes);
    }
    notifyListeners();
  }

  _deleteNodes() async {
    await cevSharedPref!.init();
    cevSharedPref!.prefs!.remove(Env.nodePrefKey);
  }

  _fetchNode() async {
    await cevSharedPref!.init();
    List<String>? _savedNodes =
        cevSharedPref!.prefs!.getStringList(Env.nodePrefKey);

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
      Detail("Balance", "103.90 PEAQ", color: CEVTheme.accentColor),
    );
    _details = _newDetails;
    if (notify) {
      notifyListeners();
    }
  }

  /// Generate  consumer keys
  /// Generate wallet address
  /// Save the account details in shared preference for further retrival
  generateConsumerKeys(String secretPhrase) async {
    String address = subsign.substrateAddress(secretPhrase, _ss58);
    print("address: $address");

    final CEVAccount acct =
        CEVAccount(address: address, pk: "", did: "did:pq:$address");
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

  connectNode() async {
    String url = _selectedNode;

    _socket = WebSocketChannel.connect(Uri.parse(url));

    final params = {
      "id": 1,
      "jsonrpc": "2.0",
      "method": "chain_subscribeNewHeads"
    };

    _socket!.sink.add(json.encode(params));

    _socket!.stream.listen(
        (event) {
          print("EVENT:: $event");
          _events.insert(0, event);
          // _events.add(event);
          notifyListeners();
        },
        onError: _onError,
        onDone: () {
          // _socket.sink.
          // print("DONE");
        });
  }

  void _onError(error) {
    print("ERROR:: $error");
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

  /// Delete account saved in the shared pref
  Future<void> _deleteAccount() async {
    await cevSharedPref!.init();
    cevSharedPref!.prefs!.remove(Env.accountPrefKey);
  }

  /// Initializes the authenticated [CEVAccount].
  Future<bool> initBeforeOnboardingPage() async {
    await Future.wait([
      getAccount(),
    ]);

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
    // Close the websocket connection
    _socket!.sink.close();
  }
}
