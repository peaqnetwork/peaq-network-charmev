import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/models/tx_info.dart';
import 'package:charmev/common/widgets/route.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:charmev/config/navigator.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/screens/charging_session.dart';
import 'package:fluro/fluro.dart';
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

  final CEVSharedPref cevSharedPref;

  late CEVApplicationProvider appProvider;

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

    final CEVAccount acct = CEVAccount(
        address: address, pk: "", did: "did:pq:$address", seed: secretPhrase);
    _account = acct;

    await cevSharedPref.prefs
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

      print("EVENT URL:: $url");

      var ev = await _dio.get(url);
      var evString = json.encode(ev.data);
      var msg = ev.data["message"];
      print(msg);
      if (msg == "EVENT FOUND") {
        if (_events.length > 100) {
          _events = [];
        }
        _events.insert(0, evString);
        notifyListeners();

        var events = ev.data["events"];
        var eventStrings = "";
        var eventDataStrings = "";
        var eventData = [];

        for (var i = 0; events.length > i; i++) {
          var event = events[i]["method"];
          var data = events[i]["data"];

          if (event == Env.serviceDeliveredEvent ||
              event == Env.serviceRequestedEvent) {
            var dataString = "";

            if (data != null) {
              dataString = json.encode(data);
            }
            eventDataStrings += "$dataString ";

            if (event == Env.serviceDeliveredEvent) {
              eventData.add(data[2]);
              eventData.add(data[3]);
            }
          }

          // Add all event strings
          eventStrings += "$event ";
        }

        print("eventStrings:: $eventStrings");
        print("eventDataStrings:: $eventDataStrings");
        print("eventData:: $eventData");

        // check if event data contains comsumer key
        if (eventDataStrings.contains(_account!.address!)) {
          _checkServiceRequestedEvent(eventStrings);
          _checkServiceDeliveredEvent(eventStrings, eventData);
        }
      }
    }, onError: _onError, onDone: () {});
  }

  _checkServiceRequestedEvent(String eventStrings) async {
    if (eventStrings.contains(Env.serviceRequestedEvent) &&
        eventStrings.contains(Env.extrinsicSuccessEvent) &&
        !eventStrings.contains(Env.extrinsicFailedEvent)) {
      appProvider.chargeProvider.setStatus(LoadingStatus.idle, message: "");
      await Future.delayed(const Duration(milliseconds: 300));
      appProvider.chargeProvider.chargingStatus = LoadingStatus.charging;

      CEVNavigator.pushRoute(CEVFadeRoute(
        builder: (context) => const CharginSessionScreen(),
        duration: const Duration(milliseconds: 600),
      ));
    }
  }

  /// if [appProvider.chargeProvider.chargingStatus == LoadingStatus.charging]
  /// it means the charging was stopped by the charging station
  /// because consumer will stop the charging before executing [ServiceDelivered] extrinsic
  /// so the following code will execute
  _checkServiceDeliveredEvent(String eventStrings, List<dynamic> info) async {
    if (eventStrings.contains(Env.serviceDeliveredEvent) &&
        eventStrings.contains(Env.extrinsicSuccessEvent) &&
        !eventStrings.contains(Env.extrinsicFailedEvent) &&
        (appProvider.chargeProvider.chargingStatus == LoadingStatus.charging ||
            appProvider.chargeProvider.chargingStatus ==
                LoadingStatus.waiting)) {
      appProvider.chargeProvider.setStatus(LoadingStatus.idle, message: "");
      List<CEVTxInfo> txinfo = [];

      for (var i = 0; info.length > i; i++) {
        var newinfo = CEVTxInfo(
          callHash: info[i]["callHash"],
          token: "${info[i]["tokenNum"]}".replaceAll(",", ""),
          timePoint: CEVTimePoint(
              height: "${info[i]["timePoint"]["height"]}".replaceAll(",", ""),
              index: info[i]["timePoint"]["index"]),
          txHash: info[i]["txHash"],
        );

        txinfo.add(newinfo);
      }

      print("_checkServiceDeliveredEvent::txinfo:: ${json.encode(txinfo)}");

      appProvider.chargeProvider.txInfo = txinfo;
      appProvider.chargeProvider.generateTransactions(notify: true);
      appProvider.chargeProvider.chargingStatus = LoadingStatus.authorize;
    }
  }

  void _onError(error) {
    print("Websocket ERROR:: $error");
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
    // Close the websocket connection
    closeNodeConnection();
  }

  closeNodeConnection() {
    _socket!.sink.close();
  }

  /// FOR DEV ONLY
  simulateServiceRequestedAndDeliveredEvents() async {
    appProvider.chargeProvider
        .setStatus(LoadingStatus.loading, message: "Requesting Service");
    await Future.delayed(const Duration(seconds: 1));

    appProvider.chargeProvider.setStatus(LoadingStatus.idle, message: "");
    await Future.delayed(const Duration(milliseconds: 300));
    appProvider.chargeProvider.chargingStatus = LoadingStatus.charging;

    CEVNavigator.pushRoute(CEVFadeRoute(
      builder: (context) => const CharginSessionScreen(),
      duration: const Duration(milliseconds: 600),
    ));

    await Future.delayed(const Duration(seconds: 3));

    print("simulateServiceRequestedAndDeliveredEvents:: should stop");

    simulateDeliveredEvent();
  }

  /// FOR DEV ONLY
  simulateDeliveredEvent() {
    _checkServiceDeliveredEvent("ExtrinsicSuccess ServiceDelivered", [
      {
        "tokenNum": "83,755,315,000,000,002,048",
        "txHash":
            "0x5417b0905fc3be27a76b29ad758796f6fb6cc7e176516c4c9d043405b218fcde",
        "timePoint": {"height": "2,820", "index": "1"},
        "callHash":
            "0x415c126c4cfbbfb1f99b24db2203a10266b81d824993b8234bbd491d28b21ec2"
      },
      {
        "tokenNum": "16,244,684,999,999,997,952",
        "txHash":
            "0x7f2fb599030daf5e543ec01161603908c5ae14841b5a846847a34698e69d02a3",
        "timePoint": {"height": "2,817", "index": "1"},
        "callHash":
            "0xd6f9b509576fee65839f3ebf7be3ca34acf6b3bc17d12e624ec38a15948add81"
      }
    ]);
  }
}
