import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ffi';
import 'dart:async';

import 'package:charmev/common/models/account.dart';
import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/models/rust_data.dart';
import 'package:charmev/common/models/transaction.dart';
import 'package:charmev/common/services/db/transactions.dart';
import 'package:charmev/common/widgets/route.dart';
import 'package:charmev/screens/charging_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:charmev/common/models/enum.dart';

import 'package:charmev/config/navigator.dart';
import 'package:charmev/common/services/fr_bridge/bridge_generated.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:charmev/config/env.dart';
import 'package:peaq_network_ev_charging_message_format/did_document_format.pb.dart'
    as doc;
import 'package:peaq_network_ev_charging_message_format/p2p_message_format.pb.dart'
    as msg;

const base = 'peaq_codec_api';
final path = Platform.isWindows
    ? '$base.dll'
    : Platform.isMacOS
        ? 'lib$base.dylib'
        : 'lib$base.so';

final print = () {};

final dylib =
    Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(path);

final api = PeaqCodecApiImpl(dylib);

Timer runPeriodically(void Function() callback) =>
    Timer.periodic(const Duration(milliseconds: 1000), (timer) => callback());

class CEVPeerProvider with ChangeNotifier {
  CEVPeerProvider({
    required this.db,
  });

  final CEVTransactionDB db;

  late CEVApplicationProvider appProvider;

  static CEVPeerProvider of(BuildContext context) {
    return provider.Provider.of<CEVPeerProvider>(context);
  }

  LoadingStatus _status = LoadingStatus.idle;
  String _error = '';
  String _statusMessage = '';
  String _peerId = '';
  bool _isLoggedIn = false;
  bool _showNodeDropdown = false;
  List<Detail> _details = [];
  Timer? _runningLoop;

  String _identityChallengeData = '';
  String _p2pURL = '';
  String _multisigAddress = '';
  bool _isPeerDidDocVerified = false;
  bool _isPeerAuthenticated = false;
  bool _isPeerConnected = false;
  bool _isPeerSubscribed = false;
  doc.Document _providerDidDoc = doc.Document();

  bool get isPeerDidDocVerified => _isPeerDidDocVerified;
  bool get isPeerAuthenticated => _isPeerAuthenticated;
  bool get isPeerConnected => _isPeerConnected;
  bool get isPeerSubscribed => _isPeerSubscribed;
  String get multisigAddress => _multisigAddress;

  Future<void> initLog() async {
    api.initLogger();
  }

  Future<void> connectP2P() async {
    // validate p2p URL
    var splitURL = _p2pURL.trim().split("/");

    if (splitURL.length != 7) {
      appProvider.chargeProvider
          .setStatus(LoadingStatus.error, message: Env.invalidP2PUrl);
    }

    _peerId = splitURL.last;

    api.connectP2P(url: _p2pURL);
    _runningLoop = runPeriodically(getEvent);
  }

  Future<void> disconnectP2P() async {
    await api.disconnectP2P(peerId: _peerId);
    _runningLoop!.cancel();
  }

  Future<void> getEvent() async {
    var data = await api.getEvent();

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    // decode rust data data
    var rData = CEVRustResponse.fromJson(decodedRes);

    if (!rData.error!) {
      // decode event data
      List<int> docRawData = List<int>.from(decodedRes["data"]);
      String docCharCode = String.fromCharCodes(docRawData);
      var docOutputAsUint8List = Uint8List.fromList(docCharCode.codeUnits);

      var ev = msg.Event();
      ev.mergeFromBuffer(docOutputAsUint8List);

      switch (ev.eventId) {
        case msg.EventType.PEER_CONNECTED:
          {
            _isPeerConnected = true;
            break;
          }
        case msg.EventType.SERVICE_REQUEST_ACK:
          {
            bool err = ev.serviceRequestedAckData.resp.error;
            if (!err) {
              _processServiceRequestedAckEvent();
            } else {
              disconnectP2P();
              appProvider.chargeProvider.setStatus(LoadingStatus.error,
                  message:
                      "${Env.providerRejectService}: ${ev.serviceRequestedAckData.resp.message}");
            }

            break;
          }
        case msg.EventType.SERVICE_DELIVERED:
          {
            _processServiceDeliveredEvent(ev.serviceDeliveredData);

            break;
          }
        case msg.EventType.PEER_CONNECTION_FAILED:
          {
            disconnectP2P();
            _isPeerConnected = false;
            appProvider.chargeProvider.setStatus(LoadingStatus.error,
                message: Env.unableToConnectToPeer);
            break;
          }
        case msg.EventType.PEER_SUBSCRIBED:
          {
            _isPeerSubscribed = true;
            // Authenticate peer if it's connected and subscribed
            if (_isPeerConnected) {
              appProvider.chargeProvider.setStatus(LoadingStatus.loading,
                  message: Env.authenticatingProvider);
              // send identity challenge to peer for verification
              _sendIdentityChallengeEvent();
            }
            break;
          }
        case msg.EventType.IDENTITY_RESPONSE:
          {
            _authenticatePeer(ev.identityResponseData);
            break;
          }
        case msg.EventType.CHARGING_STATUS:
          {
            appProvider.chargeProvider.chargeProgress =
                ev.chargingStatusData.progress / 100;
            notifyListeners();
            break;
          }
        case msg.EventType.STOP_CHARGE_RESPONSE:
          {
            appProvider.chargeProvider.chargingStatus = LoadingStatus.waiting;
            appProvider.chargeProvider.setStatus(LoadingStatus.loading,
                message: Env.stationStoppedCharging);
            notifyListeners();
            break;
          }
        default:
          {}
      }
    }
  }

  verifyPeerDidDocument() async {
    var sig = _providerDidDoc.signature.writeToBuffer();
    var providerPK = _providerDidDoc.id.split(":")[2];

    var data =
        await api.verifyPeerDidDocument(providerPk: providerPK, signature: sig);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    if (!decodedRes["error"]) {
      _isPeerDidDocVerified = true;
      notifyListeners();
    }
  }

  _processServiceRequestedAckEvent() async {
    appProvider.chargeProvider.setStatus(LoadingStatus.idle, message: "");
    await Future.delayed(const Duration(milliseconds: 300));
    appProvider.chargeProvider.chargingStatus = LoadingStatus.charging;

    CEVNavigator.pushRoute(CEVFadeRoute(
      builder: (context) => const CharginSessionScreen(),
      duration: const Duration(milliseconds: 600),
    ));
  }

  _processServiceDeliveredEvent(msg.ServiceDeliveredData data) async {
    if (appProvider.chargeProvider.chargingStatus == LoadingStatus.charging ||
        appProvider.chargeProvider.chargingStatus == LoadingStatus.waiting) {
      appProvider.chargeProvider.setStatus(LoadingStatus.idle, message: "");

      appProvider.chargeProvider.refundInfo = data.refundInfo;
      appProvider.chargeProvider.spentInfo = data.spentInfo;
      appProvider.chargeProvider.generateTransactions(notify: true);
      appProvider.chargeProvider.chargingStatus = LoadingStatus.authorize;

      final double progress = appProvider.chargeProvider.chargeProgress;
      final String otherSignatory =
          appProvider.chargeProvider.station!.address!;

      // save transaction on the local db until they are approved
      CEVTransactionDbModel refundTranx = CEVTransactionDbModel(
        id: data.refundInfo.txHash,
        data: data.refundInfo.writeToJson(),
        progress: progress,
        signatory: otherSignatory,
        transactionType: TransactonType.refund,
        date: DateTime.now().millisecondsSinceEpoch,
      );

      CEVTransactionDbModel spentTranx = CEVTransactionDbModel(
        id: data.spentInfo.txHash,
        data: data.spentInfo.writeToJson(),
        progress: progress,
        signatory: otherSignatory,
        transactionType: TransactonType.spent,
        date: DateTime.now().millisecondsSinceEpoch,
      );

      db.newTransaction(spentTranx);
      db.newTransaction(refundTranx);
    }
  }

  _verifyPeerIdentity(
      String providerPK, String plainData, doc.Signature signature) async {
    var sig = signature.writeToBuffer();

    var data = await api.verifyPeerIdentity(
        providerPk: providerPK, plainData: plainData, signature: sig);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    if (!decodedRes["error"]) {
      _isPeerAuthenticated = true;
      notifyListeners();
    }
  }

  _authenticatePeer(msg.IdentityResponseData data) async {
    for (var i = 0; i < _providerDidDoc.verificationMethods.length; i++) {
      var vm = _providerDidDoc.verificationMethods[i];

      var signature = doc.Signature(
          type: vm.type, issuer: vm.controller, hash: data.signature);

      await _verifyPeerIdentity(vm.id, _identityChallengeData, signature);
    }

    if (_isPeerAuthenticated) {
      await appProvider.chargeProvider
          .startCharge(appProvider.chargeProvider.token.toString());
      // await appProvider.accountProvider
      //     .simulateServiceRequestedAndDeliveredEvents();
    } else {
      appProvider.chargeProvider
          .setStatus(LoadingStatus.error, message: Env.providerPeerAuthFailed);
    }
  }

  Future<void> _sendIdentityChallengeEvent() async {
    var data = await api.sendIdentityChallengeEvent();

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    // decode random data
    List<int> docRawData = List<int>.from(decodedRes["data"]);
    String docCharCode = String.fromCharCodes(docRawData);

    _identityChallengeData = docCharCode;
  }

  Future<bool> sendServiceRequestedEvent(
      String provider, String consumer, String tokenDeposited) async {
    var data = await api.sendServiceRequestedEvent(
        provider: provider, consumer: consumer, tokenDeposited: tokenDeposited);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    if (decodedRes["error"]) {
      return false;
    }

    return true;
  }

  Future<bool> sendStopChargeEvent() async {
    var data = await api.sendStopChargeEvent();

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    // decode rust data data
    var rData = CEVRustResponse.fromJson(decodedRes);

    if (!rData.error!) {
      return true;
    }

    return false;
  }

  Future<bool> creatMultisigAddress(String provider, String consumer) async {
    var data = await api
        .createMultisigAddress(signatories: [provider, consumer], threshold: 2);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    // decode rust data data
    var rData = CEVRustResponse.fromJson(decodedRes);

    if (!rData.error!) {
      // decode address data
      List<int> docRawData = List<int>.from(decodedRes["data"]);
      String addr = String.fromCharCodes(docRawData);
      _multisigAddress = addr;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<CEVRustResponse> transferFund(
      String address, String amount, String seed) async {
    var data = await api.transferFund(
        wsUrl: Env.peaqTestnet, address: address, amount: amount, seed: seed);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    // decode rust data data
    var rData = CEVRustResponse.fromJson(decodedRes);
    return rData;
  }

  Future<bool> approveMultisigTransaction({
    required int threshold,
    required List<String> otherSignatories,
    required int timepointHeight,
    required int timepointIndex,
    required String callHash,
    required String seed,
  }) async {
    var data = await api.approveMultisig(
        wsUrl: Env.peaqTestnet,
        threshold: threshold,
        otherSignatories: otherSignatories,
        timepointHeight: timepointHeight,
        timepointIndex: timepointIndex,
        seed: seed,
        callHash: callHash);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);
    var rData = CEVRustResponse.fromJson(decodedRes);

    if (rData.error!) {
      appProvider.chargeProvider
          .setStatus(LoadingStatus.error, message: rData.message!);
      return false;
    }

    return true;
  }

  Future<doc.Document> fetchDidDocument(String publicKey) async {
    var data = await api.fetchDidDocument(
        wsUrl: Env.peaqTestnet,
        publicKey: publicKey,
        storageName: Env.didDocAttributeName);

    String s = String.fromCharCodes(data);
    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);
    var didDoc = doc.Document();

    if (!decodedRes["error"]) {
      // decode did document data
      List<int> docRawData = List<int>.from(decodedRes["data"]);
      String docCharCode = String.fromCharCodes(docRawData);
      var docOutputAsUint8List = Uint8List.fromList(docCharCode.codeUnits);

      didDoc.mergeFromBuffer(docOutputAsUint8List);

      _providerDidDoc = didDoc;
      _setP2PURL(didDoc.services);
      notifyListeners();
    }
    return didDoc;
  }

  Future<CEVAccount> generateAccount(String secretPhrase) async {
    debugPrint("LIB PATH: $path");

    CEVAccount account = CEVAccount();
    var data = await api.generateAccount(
        wsUrl: Env.peaqTestnet, secretPhrase: secretPhrase);

    String s = String.fromCharCodes(data);
    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    if (!decodedRes["error"]) {
      // decode account data
      var accData = decodedRes["data"];
      List<int> docRawData = List<int>.from(accData);
      var utf8ResData = utf8.decode(docRawData);
      var decodedResData = json.decode(utf8ResData);

      account = accountFromJson(json.encode(decodedResData));
    }
    return account;
  }

  Future<String> getAccountBalance(String tokenDecimals, String seed) async {
    var data = await api.getAccountBalance(
        wsUrl: Env.peaqTestnet, tokenDecimals: tokenDecimals, seed: seed);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    var accData = decodedRes["data"];
    List<int> docRawData = List<int>.from(accData);
    var utf8ResData = utf8.decode(docRawData);

    return utf8ResData;
  }

  _setP2PURL(List<doc.Service> services) {
    for (var i = 0; i < services.length; i++) {
      var service = services[i];

      if (service.type == doc.ServiceType.p2p) {
        _p2pURL = service.stringData;
        break;
      }
    }
  }
}
