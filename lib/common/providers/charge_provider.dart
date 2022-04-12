import 'dart:math';

import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/station.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/theme.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/widgets.dart';
import 'package:scan/scan.dart';
import 'package:peaq_network_ev_charging_message_format/did_document_format.pb.dart';
import 'package:peaq_network_ev_charging_message_format/did_document_format.pbenum.dart';
import 'package:peaq_network_ev_charging_message_format/p2p_message_format.pb.dart'
    as msg;

class CEVChargeProvider with ChangeNotifier {
  CEVChargeProvider({
    required this.cevSharedPref,
  });

  final CEVSharedPref cevSharedPref;

  late CEVApplicationProvider appProvider;

  static CEVChargeProvider of(BuildContext context) {
    return provider.Provider.of<CEVChargeProvider>(context);
  }

  ScanController qrController = ScanController();

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus _chargingStatus = LoadingStatus.idle;
  String _statusMessage = '';
  String _providerDid = "";
  double _counter = 0;
  double _progress = 1;
  CEVStation _station = CEVStation();
  List<Detail> _transactions = [];
  msg.TransactionValue _refundInfo = msg.TransactionValue();
  msg.TransactionValue _spentInfo = msg.TransactionValue();
  List<Detail> _details = [];
  BigInt _atto = BigInt.parse("10000000000000000000");

  String get providerDid => _providerDid;
  CEVStation? get station => _station;
  List<Detail> get details => _details;
  LoadingStatus get status => _status;
  LoadingStatus get chargingStatus => _chargingStatus;
  List<Detail> get transactions => _transactions;
  msg.TransactionValue get refundInfo => _refundInfo;
  msg.TransactionValue get spentInfo => _spentInfo;
  double get progress => _progress;
  double get counter => _counter;
  String get statusMessage => _statusMessage;

  set chargingStatus(LoadingStatus cstatus) {
    _chargingStatus = cstatus;
    notifyListeners();
  }

  set refundInfo(msg.TransactionValue info) {
    _refundInfo = info;
    notifyListeners();
  }

  set spentInfo(msg.TransactionValue info) {
    _spentInfo = info;
    notifyListeners();
  }

  set providerDid(String did) {
    _providerDid = did;
    notifyListeners();
  }

  setStatus(LoadingStatus status, {String message = ""}) {
    _status = status;
    _statusMessage = message;
    notifyListeners();
  }

  reset() {
    _status = LoadingStatus.idle;
    _statusMessage = "";
    notifyListeners();
  }

  // generate provider account details
  generateDetails({bool notify = false}) {
    List<Detail> _newDetails = [];

    if (_station != null) {
      _newDetails.addAll([
        Detail("Identity", _station.did ?? ""),
        Detail("Plug Type", _station.plugType ?? ""),
        Detail("Status", _station.status ?? "", color: CEVTheme.successColor),
        Detail("Power", _station.power ?? ""),
      ]);
    }

    _details = _newDetails;
    if (notify) {
      notifyListeners();
    }
  }

  generateTransactions({bool notify = false}) {
    List<Detail> _newtx = [];

    print(
        "generateTransactions :: _refundInfo:: ${_refundInfo.toProto3Json()}");
    print("generateTransactions :: _spentInfo:: ${_spentInfo.toProto3Json()}");

    if (_refundInfo.tokenNum.isNotEmpty && _spentInfo.tokenNum.isNotEmpty) {
      var refundRawToken = _refundInfo.tokenNum;
      var spentRawToken = _spentInfo.tokenNum;
      var refundToken = (BigInt.parse(refundRawToken) / _atto);
      print("refundToken:: $refundToken");
      var refundTokenString = refundToken.toStringAsFixed(4);
      var spentToken = (BigInt.parse(spentRawToken) / _atto);
      print("spentToken:: $spentToken");
      var spentTokenString = spentToken.toStringAsFixed(4);
      var total = (refundToken + spentToken).toStringAsFixed(4);
      _newtx.addAll([
        Detail("Pay Station", "$spentTokenString PEAQ"),
        Detail("Refund", "$refundTokenString PEAQ"),
        Detail("Total", "$total PEAQ"),
      ]);
    }

    _transactions = _newtx;
    if (notify) {
      notifyListeners();
    }
  }

  /// fetch provider Did  document from chain state storage
  fetchProviderDidDocument(String did) async {
    reset();
    if (_providerDid == _station.did) {
      generateDetails(notify: true);
      return;
    }

    String separator = ":";

    if (!did.contains(separator)) {
      setStatus(LoadingStatus.error, message: Env.invalidProviderDid);
    }

    var address = did.split(":")[2];

    var doc = await appProvider.peerProvider.fetchDidDocument(address);

    if (doc.id.isEmpty) {
      setStatus(LoadingStatus.error, message: Env.providerDidNotFound);
      notifyListeners();
    }

    _status = LoadingStatus.loading;
    notifyListeners();

    _station.did = _providerDid;
    _station.address = address;

    for (var i = 0; i < doc.services.length; i++) {
      var service = doc.services[i];
      // Get the station metadata
      if (service.type == ServiceType.metadata) {
        var metadata = service.metadata;
        _station.plugType = metadata.plugType;
        _station.status = metadata.status.toString();
        _station.power = metadata.power;
        break;
      }
    }

    setStatus(LoadingStatus.idle, message: "");

    generateDetails(notify: true);
  }

  generateAndFundMultisigWallet() async {
    setStatus(LoadingStatus.idle);
    String consumer = appProvider.accountProvider.account.address!;
    String provider = _station.address!;

    setStatus(LoadingStatus.loading, message: Env.creatingMultisigWallet);

    bool walletCreated =
        await appProvider.peerProvider.creatMultisigAddress(provider, consumer);

    String multisigAddress = appProvider.peerProvider.multisigAddress;

    if (!walletCreated || multisigAddress.isEmpty) {
      setStatus(LoadingStatus.error, message: Env.creatingMultisigWalletFailed);
      return;
    }

    var token = (10 * pow(10, 19));
    var seed = appProvider.accountProvider.account.seed!;

    setStatus(LoadingStatus.loading, message: Env.fundingMultisigWallet);

    var resp = await appProvider.peerProvider
        .transferFund(multisigAddress, "$token", seed);
    // print("generateAndFundMultisigWallet resp data:: ${resp.toJson()}");

    if (resp.error!) {
      setStatus(LoadingStatus.error, message: resp.message!);
      return;
    }

    await Future.delayed(const Duration(seconds: 3));

    _startCharge(token.toString());
  }

  _startCharge(String token) async {
    setStatus(LoadingStatus.idle);

    setStatus(LoadingStatus.loading, message: Env.requestingService);

    String consumer = appProvider.accountProvider.account.address!;
    String provider = _station.address!;

    var res = await appProvider.peerProvider
        .sendServiceRequestedEvent(provider, consumer, token);

    if (!res) {
      setStatus(LoadingStatus.loading, message: Env.serviceRequestFailed);
      return;
    }

    setStatus(LoadingStatus.loading, message: Env.serviceRequested);
  }

  stopCharge() async {
    setStatus(LoadingStatus.loading, message: Env.stoppingCharge);

    bool chargeStopEventSent =
        await appProvider.peerProvider.sendStopChargeEvent();

    if (!chargeStopEventSent) {
      setStatus(LoadingStatus.error, message: Env.stoppingChargeFailed);
      return;
    }

    _chargingStatus = LoadingStatus.waiting;

    setStatus(LoadingStatus.loading, message: Env.stoppingChargeSent);
  }

  approveTransactions() async {
    if (_refundInfo.tokenNum.isEmpty || _spentInfo.tokenNum.isEmpty) {
      setStatus(LoadingStatus.error, message: "Empty transactions");
      return;
    }

    setStatus(LoadingStatus.loading);

    var refundTimePoint = _refundInfo.timePoint;
    var spentTimePoint = _spentInfo.timePoint;
    var otherSignatories = [_station.address!];

    var _seed = appProvider.accountProvider.account.seed ?? "";

    setStatus(LoadingStatus.loading, message: Env.approvingRefundTransaction);

    bool approveRefund = await appProvider.peerProvider
        .approveMultisigTransaction(
            threshold: 2,
            otherSignatories: otherSignatories,
            timepointHeight: refundTimePoint.height.toInt(),
            timepointIndex: refundTimePoint.index.toInt(),
            callHash: _refundInfo.callHash,
            seed: _seed);

    if (!approveRefund) {
      setStatus(LoadingStatus.error,
          message: Env.approvingRefundTransactionFailed);
      return;
    }
    setStatus(LoadingStatus.loading, message: Env.approvingSpentTransaction);

    bool approveSpent = await appProvider.peerProvider
        .approveMultisigTransaction(
            threshold: 2,
            otherSignatories: otherSignatories,
            timepointHeight: spentTimePoint.height.toInt(),
            timepointIndex: spentTimePoint.index.toInt(),
            callHash: _spentInfo.callHash,
            seed: _seed);

    if (!approveSpent) {
      setStatus(LoadingStatus.error,
          message: Env.approvingSpentTransactionFailed);
      return;
    }

    _chargingStatus = LoadingStatus.success;
    setStatus(LoadingStatus.idle, message: Env.transactionCompleted);
  }
}
