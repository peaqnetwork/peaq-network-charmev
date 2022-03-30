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
import 'package:peaq_network_ev_charging_message_format/did_document_format.pb.dart';
import 'package:peaq_network_ev_charging_message_format/p2p_message_format.pb.dart'
    as msg;

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

  String _identityChallengeData = '';

  Future<void> connectP2P() async {
    api.connectP2P(
        url:
            "${Env.p2pURL}/12D3KooWCazx4ZLTdrA1yeTTmCy5sGW32SFejztJTGdSZwnGf5Yo");
    runPeriodically(getEvent);
  }

  Future<void> getEvent() async {
    print("getEvent hitts");

    var data = await api.getEvent();

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    if (!decodedRes["error"]) {
      // decode did document data
      List<int> docRawData = List<int>.from(decodedRes["data"]);
      String docCharCode = String.fromCharCodes(docRawData);
      var docOutputAsUint8List = Uint8List.fromList(docCharCode.codeUnits);

      var ev = msg.Event();
      ev.mergeFromBuffer(docOutputAsUint8List);

      // print("EVENT:: ${ev.toProto3Json()}");
    }
  }

  Future<void> sendIdentityChallengeEvent() async {
    print("sendIdentityChallengeEvent hitts");
    var data = await api.sendIdentityChallengeEvent();

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    // decode did document data
    List<int> docRawData = List<int>.from(decodedRes["data"]);
    String docCharCode = String.fromCharCodes(docRawData);

    _identityChallengeData = docCharCode;
    // print("RANDOM DATA:: $_identityChallengeData");

    return;
  }

  Future<Document> fetchDidDocument(String publicKey) async {
    var data = await api.fetchDidDocument(
        wsUrl: Env.peaqTestnet,
        publicKey: publicKey,
        storageName: Env.didDocAttributeName);

    String s = String.fromCharCodes(data);
    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    // decode did document data
    List<int> docRawData = List<int>.from(decodedRes["data"]);
    String docCharCode = String.fromCharCodes(docRawData);
    var docOutputAsUint8List = Uint8List.fromList(docCharCode.codeUnits);

    var doc = Document();
    doc.mergeFromBuffer(docOutputAsUint8List);

    return doc;
  }
}
