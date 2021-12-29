import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/models/tx_info.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/account.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:dio/dio.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:substrate_sign_flutter/substrate_sign_flutter.dart' as subsign;
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
  final Dio _dio = Dio()..options = BaseOptions(baseUrl: Env.scaleCodecBaseURL);

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
      "method": "chain_subscribeFinalisedHeads"
    };

    _socket!.sink.add(json.encode(params));

    _socket!.stream.listen((event) async {
      print("EVENT:: $event");
      var devent = json.decode(event);
      var hsh = devent["params"]["result"]["parentHash"];
      print(hsh);
      url = "${Env.eventURL}/$hsh";

      var ev = await _dio.get(url);
      var evString = json.encode(ev.data);
      var msg = ev.data["message"];
      print(msg);
      if (msg == "EVENT FOUND") {
        if (_events.length > 100) {
          _events = [];
        }
        _events.insert(0, evString);

        var events = ev.data["events"];
        var eventStrings = "";
        var eventDataStrings = "";
        var eventData = [];

        for (var i = 0; events.length > i; i++) {
          var event = events[i]["method"];

          if (event == Env.serviceDeliveredEvent) {
            var data = events[i]["data"];
            var dataString = "";

            if (data != null) {
              dataString = json.encode(data);
            }
            eventDataStrings += "$dataString ";

            eventData.add(data[2]);
            eventData.add(data[3]);
          }

          // Add all event strings
          eventStrings += "$event ";
        }

        print("eventStrings:: $eventStrings");
        print("eventDataStrings:: $eventDataStrings");
        print("eventData:: $eventData");

        _checkServiceRequestedEvent(eventStrings);

        // check if event data contains comsumer key
        if (eventDataStrings.contains(_account!.address!)) {
          _checkServiceDeliveredEvent(eventStrings, eventData);
        }
        notifyListeners();
      }
    }, onError: _onError, onDone: () {});
  }

  _checkServiceRequestedEvent(String eventStrings) async {
    if (eventStrings.contains("ServiceRequested") &&
        eventStrings.contains("ExtrinsicSuccess") &&
        !eventStrings.contains("ExtrinsicFailed")) {
      Future.delayed(const Duration(seconds: 2));
      appProvider!.chargeProvider!
          .setStatus(LoadingStatus.charging, message: "");
    }
  }

  /// if [appProvider!.chargeProvider!.chargingStatus == LoadingStatus.charging]
  /// it means the charging was stopped by the charging station
  /// because consumer will stop the charging before executing [ServiceDelivered] extrinsic
  /// so the following code will execute
  _checkServiceDeliveredEvent(String eventStrings, List<dynamic> info) async {
    if (eventStrings.contains("ServiceDelivered") &&
        eventStrings.contains("ExtrinsicSuccess") &&
        !eventStrings.contains("ExtrinsicFailed") &&
        appProvider!.chargeProvider!.chargingStatus == LoadingStatus.charging) {
      appProvider!.chargeProvider!.chargingStatus = LoadingStatus.idle;
      List<CEVTxInfo> txinfo = [];

      for (var i = 0; info.length > i; i++) {
        var newinfo = CEVTxInfo(
          callHash: info[i]["callHash"],
          token: info[i]["tokenNum"],
          timePoint: CEVTimePoint(
              height: info[i]["timePoint"]["height"],
              index: info[i]["timePoint"]["index"]),
          txHash: info[i]["txHash"],
        );

        txinfo.add(newinfo);
      }

      appProvider!.chargeProvider!.txInfo = txinfo;
      appProvider!.chargeProvider!.generateTransactions(notify: true);
    }
  }

  void _onError(error) {
    print("Websocket ERROR:: $error");
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
    // Close the websocket connection
    closeNodeConnection();
  }

  closeNodeConnection() {
    _socket!.sink.close();
  }
}
