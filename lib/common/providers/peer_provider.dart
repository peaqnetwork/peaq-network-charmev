import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ffi';
import 'dart:async';

import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:charmev/common/models/enum.dart';

import 'package:charmev/common/services/fr_bridge/bridge_generated.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:charmev/config/env.dart';

const base = 'peaq_codec_api';
final path = Platform.isWindows
    ? '$base.dll'
    : Platform.isMacOS
        ? 'lib$base.dylib'
        : 'lib$base.so';
late final dylib =
    Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(path);

late final api = PeaqCodecApiImpl(dylib);

void runPeriodically(void Function() callback) =>
    Timer.periodic(const Duration(milliseconds: 3000), (timer) => callback());

class CEVPeerProvider with ChangeNotifier {
  CEVPeerProvider({
    required this.cevSharedPref,
  });

  final CEVSharedPref cevSharedPref;

  late CEVApplicationProvider appProvider;

  static CEVPeerProvider of(BuildContext context) {
    return provider.Provider.of<CEVPeerProvider>(context);
  }

  LoadingStatus _status = LoadingStatus.idle;
  String _error = '';
  String _statusMessage = '';
  bool _isLoggedIn = false;
  bool _showNodeDropdown = false;
  List<Detail> _details = [];

  Future<void> connectP2P() async {
    await api.connectP2P(
        url:
            "${Env.p2pURL}/12D3KooWCazx4ZLTdrA1yeTTmCy5sGW32SFejztJTGdSZwnGf5Yo");
    // String s = String.fromCharCodes(data);
    // var outputAsUint8List = Uint8List.fromList(s.codeUnits);
    // var decoded = utf8.decode(data);
    // print("P2P DATA:: $data");
    // print('P2P decoded DATA:: $decoded');
    // print("P2P outputAsUint8List DATA:: $outputAsUint8List");
  }
}
