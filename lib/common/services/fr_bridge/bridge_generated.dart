// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`.

// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import

import 'dart:convert';
import 'dart:typed_data';

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'dart:ffi' as ffi;

abstract class PeaqCodecApi {
  Future<void> initLogger({dynamic hint});

  Future<void> connectP2P({required String url, dynamic hint});

  Future<Uint8List> sendIdentityChallengeEvent({dynamic hint});

  Future<Uint8List> sendServiceRequestedEvent(
      {required String provider,
      required String consumer,
      required String tokenDeposited,
      dynamic hint});

  Future<Uint8List> createMultisigAddress(
      {required String consumer, required String provider, dynamic hint});

  Future<Uint8List> getEvent({dynamic hint});

  Future<Uint8List> verifyPeerDidDocument(
      {required String providerPk, required Uint8List signature, dynamic hint});

  Future<Uint8List> verifyPeerIdentity(
      {required String providerPk,
      required String plainData,
      required Uint8List signature,
      dynamic hint});

  Future<Uint8List> fetchDidDocument(
      {required String wsUrl,
      required String publicKey,
      required String storageName,
      dynamic hint});
}

class PeaqCodecApiImpl extends FlutterRustBridgeBase<PeaqCodecApiWire>
    implements PeaqCodecApi {
  factory PeaqCodecApiImpl(ffi.DynamicLibrary dylib) =>
      PeaqCodecApiImpl.raw(PeaqCodecApiWire(dylib));

  PeaqCodecApiImpl.raw(PeaqCodecApiWire inner) : super(inner);

  Future<void> initLogger({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_init_logger(port_),
        parseSuccessData: _wire2api_unit,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "init_logger",
          argNames: [],
        ),
        argValues: [],
        hint: hint,
      ));

  Future<void> connectP2P({required String url, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) =>
            inner.wire_connect_p2p(port_, _api2wire_String(url)),
        parseSuccessData: _wire2api_unit,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "connect_p2p",
          argNames: ["url"],
        ),
        argValues: [url],
        hint: hint,
      ));

  Future<Uint8List> sendIdentityChallengeEvent({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_send_identity_challenge_event(port_),
        parseSuccessData: _wire2api_uint_8_list,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "send_identity_challenge_event",
          argNames: [],
        ),
        argValues: [],
        hint: hint,
      ));

  Future<Uint8List> sendServiceRequestedEvent(
          {required String provider,
          required String consumer,
          required String tokenDeposited,
          dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_send_service_requested_event(
            port_,
            _api2wire_String(provider),
            _api2wire_String(consumer),
            _api2wire_String(tokenDeposited)),
        parseSuccessData: _wire2api_uint_8_list,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "send_service_requested_event",
          argNames: ["provider", "consumer", "tokenDeposited"],
        ),
        argValues: [provider, consumer, tokenDeposited],
        hint: hint,
      ));

  Future<Uint8List> createMultisigAddress(
          {required String consumer, required String provider, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_create_multisig_address(
            port_, _api2wire_String(consumer), _api2wire_String(provider)),
        parseSuccessData: _wire2api_uint_8_list,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "create_multisig_address",
          argNames: ["consumer", "provider"],
        ),
        argValues: [consumer, provider],
        hint: hint,
      ));

  Future<Uint8List> getEvent({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_get_event(port_),
        parseSuccessData: _wire2api_uint_8_list,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "get_event",
          argNames: [],
        ),
        argValues: [],
        hint: hint,
      ));

  Future<Uint8List> verifyPeerDidDocument(
          {required String providerPk,
          required Uint8List signature,
          dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_verify_peer_did_document(port_,
            _api2wire_String(providerPk), _api2wire_uint_8_list(signature)),
        parseSuccessData: _wire2api_uint_8_list,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "verify_peer_did_document",
          argNames: ["providerPk", "signature"],
        ),
        argValues: [providerPk, signature],
        hint: hint,
      ));

  Future<Uint8List> verifyPeerIdentity(
          {required String providerPk,
          required String plainData,
          required Uint8List signature,
          dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_verify_peer_identity(
            port_,
            _api2wire_String(providerPk),
            _api2wire_String(plainData),
            _api2wire_uint_8_list(signature)),
        parseSuccessData: _wire2api_uint_8_list,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "verify_peer_identity",
          argNames: ["providerPk", "plainData", "signature"],
        ),
        argValues: [providerPk, plainData, signature],
        hint: hint,
      ));

  Future<Uint8List> fetchDidDocument(
          {required String wsUrl,
          required String publicKey,
          required String storageName,
          dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_fetch_did_document(
            port_,
            _api2wire_String(wsUrl),
            _api2wire_String(publicKey),
            _api2wire_String(storageName)),
        parseSuccessData: _wire2api_uint_8_list,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "fetch_did_document",
          argNames: ["wsUrl", "publicKey", "storageName"],
        ),
        argValues: [wsUrl, publicKey, storageName],
        hint: hint,
      ));

  // Section: api2wire
  ffi.Pointer<wire_uint_8_list> _api2wire_String(String raw) {
    return _api2wire_uint_8_list(utf8.encoder.convert(raw));
  }

  int _api2wire_u8(int raw) {
    return raw;
  }

  ffi.Pointer<wire_uint_8_list> _api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }

  // Section: api_fill_to_wire

}

// Section: wire2api
int _wire2api_u8(dynamic raw) {
  return raw as int;
}

Uint8List _wire2api_uint_8_list(dynamic raw) {
  return raw as Uint8List;
}

void _wire2api_unit(dynamic raw) {
  return;
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.

/// generated by flutter_rust_bridge
class PeaqCodecApiWire implements FlutterRustBridgeWireBase {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  PeaqCodecApiWire(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  PeaqCodecApiWire.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void wire_init_logger(
    int port_,
  ) {
    return _wire_init_logger(
      port_,
    );
  }

  late final _wire_init_loggerPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_init_logger');
  late final _wire_init_logger =
      _wire_init_loggerPtr.asFunction<void Function(int)>();

  void wire_connect_p2p(
    int port_,
    ffi.Pointer<wire_uint_8_list> url,
  ) {
    return _wire_connect_p2p(
      port_,
      url,
    );
  }

  late final _wire_connect_p2pPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>('wire_connect_p2p');
  late final _wire_connect_p2p = _wire_connect_p2pPtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_send_identity_challenge_event(
    int port_,
  ) {
    return _wire_send_identity_challenge_event(
      port_,
    );
  }

  late final _wire_send_identity_challenge_eventPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_send_identity_challenge_event');
  late final _wire_send_identity_challenge_event =
      _wire_send_identity_challenge_eventPtr.asFunction<void Function(int)>();

  void wire_send_service_requested_event(
    int port_,
    ffi.Pointer<wire_uint_8_list> provider,
    ffi.Pointer<wire_uint_8_list> consumer,
    ffi.Pointer<wire_uint_8_list> token_deposited,
  ) {
    return _wire_send_service_requested_event(
      port_,
      provider,
      consumer,
      token_deposited,
    );
  }

  late final _wire_send_service_requested_eventPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Int64,
                  ffi.Pointer<wire_uint_8_list>,
                  ffi.Pointer<wire_uint_8_list>,
                  ffi.Pointer<wire_uint_8_list>)>>(
      'wire_send_service_requested_event');
  late final _wire_send_service_requested_event =
      _wire_send_service_requested_eventPtr.asFunction<
          void Function(int, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>, ffi.Pointer<wire_uint_8_list>)>();

  void wire_create_multisig_address(
    int port_,
    ffi.Pointer<wire_uint_8_list> consumer,
    ffi.Pointer<wire_uint_8_list> provider,
  ) {
    return _wire_create_multisig_address(
      port_,
      consumer,
      provider,
    );
  }

  late final _wire_create_multisig_addressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>)>>('wire_create_multisig_address');
  late final _wire_create_multisig_address =
      _wire_create_multisig_addressPtr.asFunction<
          void Function(int, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>)>();

  void wire_get_event(
    int port_,
  ) {
    return _wire_get_event(
      port_,
    );
  }

  late final _wire_get_eventPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_get_event');
  late final _wire_get_event =
      _wire_get_eventPtr.asFunction<void Function(int)>();

  void wire_verify_peer_did_document(
    int port_,
    ffi.Pointer<wire_uint_8_list> provider_pk,
    ffi.Pointer<wire_uint_8_list> signature,
  ) {
    return _wire_verify_peer_did_document(
      port_,
      provider_pk,
      signature,
    );
  }

  late final _wire_verify_peer_did_documentPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>)>>('wire_verify_peer_did_document');
  late final _wire_verify_peer_did_document =
      _wire_verify_peer_did_documentPtr.asFunction<
          void Function(int, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>)>();

  void wire_verify_peer_identity(
    int port_,
    ffi.Pointer<wire_uint_8_list> provider_pk,
    ffi.Pointer<wire_uint_8_list> plain_data,
    ffi.Pointer<wire_uint_8_list> signature,
  ) {
    return _wire_verify_peer_identity(
      port_,
      provider_pk,
      plain_data,
      signature,
    );
  }

  late final _wire_verify_peer_identityPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>)>>('wire_verify_peer_identity');
  late final _wire_verify_peer_identity =
      _wire_verify_peer_identityPtr.asFunction<
          void Function(int, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>, ffi.Pointer<wire_uint_8_list>)>();

  void wire_fetch_did_document(
    int port_,
    ffi.Pointer<wire_uint_8_list> ws_url,
    ffi.Pointer<wire_uint_8_list> public_key,
    ffi.Pointer<wire_uint_8_list> storage_name,
  ) {
    return _wire_fetch_did_document(
      port_,
      ws_url,
      public_key,
      storage_name,
    );
  }

  late final _wire_fetch_did_documentPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>)>>('wire_fetch_did_document');
  late final _wire_fetch_did_document = _wire_fetch_did_documentPtr.asFunction<
      void Function(int, ffi.Pointer<wire_uint_8_list>,
          ffi.Pointer<wire_uint_8_list>, ffi.Pointer<wire_uint_8_list>)>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list(
    int len,
  ) {
    return _new_uint_8_list(
      len,
    );
  }

  late final _new_uint_8_listPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_uint_8_list> Function(
              ffi.Int32)>>('new_uint_8_list');
  late final _new_uint_8_list = _new_uint_8_listPtr
      .asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();

  void free_WireSyncReturnStruct(
    WireSyncReturnStruct val,
  ) {
    return _free_WireSyncReturnStruct(
      val,
    );
  }

  late final _free_WireSyncReturnStructPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(WireSyncReturnStruct)>>(
          'free_WireSyncReturnStruct');
  late final _free_WireSyncReturnStruct = _free_WireSyncReturnStructPtr
      .asFunction<void Function(WireSyncReturnStruct)>();

  void store_dart_post_cobject(
    DartPostCObjectFnType ptr,
  ) {
    return _store_dart_post_cobject(
      ptr,
    );
  }

  late final _store_dart_post_cobjectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(DartPostCObjectFnType)>>(
          'store_dart_post_cobject');
  late final _store_dart_post_cobject = _store_dart_post_cobjectPtr
      .asFunction<void Function(DartPostCObjectFnType)>();
}

class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

typedef DartPostCObjectFnType = ffi.Pointer<
    ffi.NativeFunction<ffi.Uint8 Function(DartPort, ffi.Pointer<ffi.Void>)>>;
typedef DartPort = ffi.Int64;
