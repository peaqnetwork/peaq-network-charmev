import 'dart:convert';
import 'dart:math';

import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/station.dart';
import 'package:charmev/common/models/tx_info.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/widgets.dart';
import 'package:cryptography/cryptography.dart';
import 'package:schnorr/schnorr.dart' as scn;
import 'package:elliptic/elliptic.dart' as ec;
import 'package:substrate_sign_flutter/substrate_sign_flutter.dart' as subsign;
import 'package:scan/scan.dart';
import 'package:peaq_network_ev_charging_message_format/did_document_format.pb.dart';
import 'package:peaq_network_ev_charging_message_format/did_document_format.pbenum.dart';

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
  double _totalTimeInSeconds = 120;
  double _counter = 0;
  double _progress = 1;
  CEVStation _station = CEVStation();
  List<Detail> _transactions = [];
  List<CEVTxInfo> _txInfo = [];
  List<Detail> _details = [];
  BigInt _atto = BigInt.parse("10000000000000000000");
  final Dio _dio = Dio()..options = BaseOptions(baseUrl: Env.scaleCodecBaseURL);

  String get providerDid => _providerDid;
  CEVStation? get station => _station;
  List<Detail> get details => _details;
  LoadingStatus get status => _status;
  LoadingStatus get chargingStatus => _chargingStatus;
  double get totalTimeInSeconds => _totalTimeInSeconds;
  List<Detail> get transactions => _transactions;
  List<CEVTxInfo> get txInfo => _txInfo;
  double get progress => _progress;
  double get counter => _counter;
  String get statusMessage => _statusMessage;

  set chargingStatus(LoadingStatus cstatus) {
    _chargingStatus = cstatus;
    notifyListeners();
  }

  set txInfo(List<CEVTxInfo> info) {
    _txInfo = info;
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

  updateTimer(double count) async {
    var percent = _counter / _totalTimeInSeconds;
    double progress = (percent <= 1) ? percent : 1;
    _progress = progress;
    _counter = count;
  }

  // generate provider account details
  generateDetails({bool notify = false}) {
    List<Detail> _newDetails = [];

    print("_station:: $_station");
    print("_station::did  ${_station.did}");

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

    print("generateTransactions :: _txInfo:: ${json.encode(_txInfo)}");

    if (_txInfo.isNotEmpty) {
      var refundRawToken = _txInfo[0].token;
      var spentRawToken = _txInfo[1].token;
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
    var params = {
      "addresses": [
        appProvider.accountProvider.account.address,
        _station.address
      ],
      "owner_index": 0,
      "threshold": 2
    };

    setStatus(LoadingStatus.loading, message: Env.creatingMultisigWallet);

    var url = Env.multisigURL;

    var res1 =
        await _dio.post(url, data: json.encode(params)).catchError((err) async {
      setStatus(LoadingStatus.error, message: Env.creatingMultisigWalletFailed);
      print("Err:: $err");
      return err;
    });

    print("generateAndFundMultisigWallet res1  data:: ${res1}");
    print("generateAndFundMultisigWallet res1 data:: ${res1.data}");

    var token = (10 * pow(10, 19));

    params = {
      "address": res1.data["multisig_address"],
      "amount": "$token",
      "signer_seed": appProvider.accountProvider.account.seed ?? ""
    };

    print("Transfer param:: $params");

    url = Env.transferURL;

    setStatus(LoadingStatus.loading, message: Env.fundingMultisigWallet);

    var res2 =
        await _dio.post(url, data: json.encode(params)).catchError((err) async {
      setStatus(LoadingStatus.error, message: Env.fundingMultisigWalletFailed);
      print("Err:: $err");
      return err;
    });

    print("generateAndFundMultisigWallet res2 data:: ${res2.data}");

    await Future.delayed(const Duration(seconds: 3));

    _startCharge(token.toString());
  }

  _startCharge(String token) async {
    setStatus(LoadingStatus.idle);
    var params = {
      "signer_seed": appProvider.accountProvider.account.seed ?? "",
      "provider_address": _station.address,
      "amount": token,
    };

    setStatus(LoadingStatus.loading, message: Env.requestingService);

    var url = Env.transactionURL;
    var consumer = appProvider.accountProvider.account.address;
    var provider = _station.address;

    var res = await appProvider.peerProvider
        .sendServiceRequestedEvent(provider!, consumer!, token);

    if (!res) {
      setStatus(LoadingStatus.loading, message: Env.serviceRequestFailed);
      return;
    }

    setStatus(LoadingStatus.loading, message: Env.serviceRequested);

    print("_startCharge res data:: ${res}");
  }

  stopCharge() async {
    setStatus(LoadingStatus.loading, message: Env.stoppingCharge);

    // var url = _station.stopUrl ?? "";
    var url = "";

    if (url.isEmpty) {
      setStatus(LoadingStatus.error, message: Env.stopUrlNotSet);
      return;
    }

    var params = {
      "success": true,
    };

    print("stopCharge URL:: $url");
    var res = await _dio.post(url, data: params).catchError((err) async {
      setStatus(LoadingStatus.error, message: Env.stoppingChargeFailed);
      print("stopCharge Err:: $err");
      return err;
    });

    _chargingStatus = LoadingStatus.waiting;

    setStatus(LoadingStatus.loading, message: Env.stoppingChargeSent);

    print("stopCharge res data:: ${res}");
  }

  approveTransactions() async {
    print("approveTransactions:: ${json.encode(_txInfo)}");

    if (_txInfo.isEmpty) {
      setStatus(LoadingStatus.error, message: "Empty transactions");
      return;
    }

    setStatus(LoadingStatus.loading);

    var refundTimePoint = _txInfo[0].timePoint;
    var spentTimePoint = _txInfo[1].timePoint;

    var _seed = appProvider.accountProvider.account.seed ?? "";

    var refundParams = {
      "call_hash": _txInfo[0].callHash,
      "timepoint": refundTimePoint.toJson(),
      "threshold": 2,
      "other_sig": [_station.address],
      "signer_seed": _seed
    };

    var spentParams = {
      "call_hash": _txInfo[1].callHash,
      "timepoint": spentTimePoint.toJson(),
      "threshold": 2,
      "other_sig": [_station.address],
      "signer_seed": _seed
    };

    setStatus(LoadingStatus.loading, message: Env.approvingRefundTransaction);

    var url = Env.multisigURL;

    var refundRes =
        await _dio.patch(url, data: refundParams).catchError((err) async {
      setStatus(LoadingStatus.error,
          message: Env.approvingRefundTransactionFailed);
      print("Refund Err:: $err");
      return err;
    });

    print("refundRes data:: ${refundRes.data}");
    await Future.delayed(const Duration(seconds: 7));

    setStatus(LoadingStatus.loading, message: Env.approvingSpentTransaction);

    var spentRes =
        await _dio.patch(url, data: spentParams).catchError((err) async {
      setStatus(LoadingStatus.error,
          message: Env.approvingSpentTransactionFailed);
      print("spent Err:: $err");
      return err;
    });
    print("spentRes data:: ${spentRes.data}");

    _chargingStatus = LoadingStatus.success;
    setStatus(LoadingStatus.idle, message: Env.transactionCompleted);
  }

  /// FOR DEV ONLY
  simulateApproveTransactions() async {
    setStatus(LoadingStatus.loading, message: Env.approvingRefundTransaction);
    await Future.delayed(const Duration(seconds: 3));
    setStatus(LoadingStatus.loading, message: Env.approvingSpentTransaction);
    await Future.delayed(const Duration(seconds: 3));

    _chargingStatus = LoadingStatus.success;
    setStatus(LoadingStatus.idle, message: Env.transactionCompleted);
  }

  /// FOR DEV ONLY
  simulateStopCharge(bool urlExist) async {
    setStatus(LoadingStatus.loading, message: Env.stoppingCharge);

    if (!urlExist) {
      setStatus(LoadingStatus.error, message: Env.stopUrlNotSet);
      return;
    }
    await Future.delayed(const Duration(seconds: 3));

    _chargingStatus = LoadingStatus.waiting;

    setStatus(LoadingStatus.loading, message: Env.stoppingChargeSent);
    await Future.delayed(const Duration(seconds: 3));

    appProvider.accountProvider.simulateDeliveredEvent();
  }
}
