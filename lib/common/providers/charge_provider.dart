import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/models/station.dart';
import 'package:charmev/theme.dart';
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

  String _providerDid = "";
  CEVStation _station = CEVStation(
      plugType: "EV2022", status: "Available", power: "(22kW) 2,50 DKK / kwh");
  List<Detail> _details = [];

  String get providerDid => _providerDid;
  CEVStation? get station => _station;
  List<Detail> get details => _details;

  set providerDid(String did) {
    _providerDid = did;
    _station.did = did;
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
        Detail("Plug Type", _station.plugType!),
        Detail("Status", _station.status!, color: CEVTheme.successColor),
        Detail("Power", _station.power!),
      ]);
    }

    _details = _newDetails;
    if (notify) {
      notifyListeners();
    }
  }

  /// Scan and parse scanned providerDid
  scanProviderDid() {}
}
