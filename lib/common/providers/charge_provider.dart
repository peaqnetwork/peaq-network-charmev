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

class CEVChargeProvider with ChangeNotifier {
  CEVChargeProvider({
    required this.cevSharedPref,
  });

  final CEVSharedPref? cevSharedPref;

  CEVApplicationProvider? appProvider;

  static CEVChargeProvider of(BuildContext context) {
    return provider.Provider.of<CEVChargeProvider>(context);
  }

  ScanController qrController = ScanController();

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus _chargingStatus = LoadingStatus.idle;
  String _statusMessage = '';
  String _providerDid = "";
  double _totalTimeInSeconds = 10;
  double _progress = 1;
  CEVStation _station = CEVStation();
  List<Detail> _transactions = [];
  List<CEVTxInfo> _txInfo = [];
  List<Detail> _details = [];
  String _seed =
      "scrub peace island turn collect bronze ceiling alter pyramid bring summer gentle";
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
  String get statusMessage => _statusMessage;

  set chargingStatus(LoadingStatus status) {
    _chargingStatus = status;
    notifyListeners();
  }

  set txInfo(List<CEVTxInfo> info) {
    _txInfo.addAll(info);
    notifyListeners();
  }

  set progress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  set totalTimeInSeconds(double time) {
    _totalTimeInSeconds = time;
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
    List<Detail> _newDetails = [];

    print("_txInfo:: $_txInfo");

    if (_txInfo.isNotEmpty) {
      var refundRawToken = _txInfo[0].token.replaceAll(",", "");
      var spentRawToken = _txInfo[1].token.replaceAll(",", "");
      var refundToken = int.parse(refundRawToken).toStringAsFixed(4);
      var spentToken = int.parse(spentRawToken).toStringAsFixed(4);
      var total = refundToken + spentToken;
      _newDetails.addAll([
        Detail("Pay Station", "$spentToken PEAQ"),
        Detail("Refund", "$refundToken PEAQ"),
        Detail("Total", "$total PEAQ"),
      ]);
    }

    _details = _newDetails;
    if (notify) {
      notifyListeners();
    }
  }

  /// fetch provider Did  details from chain state storage
  fetchProviderDidDetails(String did) async {
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

    _status = LoadingStatus.loading;
    notifyListeners();

    var key = "station_data";
    var params = {
      "address": address,
      "key": key,
    };

    var url = Env.storageURL;

    print(_dio.options.baseUrl);

    var res =
        await _dio.post(url, data: json.encode(params)).catchError((err) async {
      setStatus(LoadingStatus.error, message: Env.providerDidNotFound);
      print("Err:: $err");
      return err;
    });

    print("res data:: ${res}");
    print("res data:: ${res.data}");

    String hashKey = res.data ?? "";

    if (hashKey.length < 64) {
      setStatus(LoadingStatus.error, message: Env.storageKeyGenError);
      notifyListeners();
      return;
    }

    url = "$url/$hashKey";
    var result = await _dio.get(url);

    if (result.data["message"] == "STORAGE NOT FOUND") {
      _statusMessage = "Provider Did Details not Found";
      _status = LoadingStatus.error;
      notifyListeners();
      return;
    }

    print(result.data);

    var enData = json.decode(result.data["value"]);

    _station.did = _providerDid;
    _station.address = address;
    _station.plugType = enData["plug_type"];
    _station.status = enData["status"];
    _station.power = enData["power"];

    _status = LoadingStatus.idle;
    generateDetails(notify: true);
  }

  generateAndFundMultisigWallet() async {
    setStatus(LoadingStatus.idle);
    var params = {
      "addresses": [
        appProvider!.accountProvider!.account.address,
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

    params = {
      "address": res1.data["multisig_address"],
      "amount": "100000000000000000000",
      "signer_seed": _seed
    };
    url = Env.transferURL;

    setStatus(LoadingStatus.loading, message: Env.fundingMultisigWallet);

    var res2 =
        await _dio.post(url, data: json.encode(params)).catchError((err) async {
      setStatus(LoadingStatus.error, message: Env.fundingMultisigWalletFailed);
      print("Err:: $err");
      return err;
    });

    print("generateAndFundMultisigWallet res2  data:: ${res2}");
    print("generateAndFundMultisigWallet res2 data:: ${res2.data}");
  }
}
