import 'dart:convert';

import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/station.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/widgets.dart';
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
  String _error = '';
  String _statusMessage = '';
  String _providerDid = "";
  CEVStation _station = CEVStation();
  List<Detail> _details = [];
  final Dio _dio = Dio()..options = BaseOptions(baseUrl: Env.scaleCodecBaseURL);

  String get providerDid => _providerDid;
  CEVStation? get station => _station;
  List<Detail> get details => _details;
  LoadingStatus get status => _status;
  String get error => _error;
  String get statusMessage => _statusMessage;

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
    _station.plugType = enData["plug_type"];
    _station.status = enData["status"];
    _station.power = enData["power"];

    _status = LoadingStatus.idle;
    generateDetails(notify: true);
  }
}
