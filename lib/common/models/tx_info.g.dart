// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tx_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CEVTxInfo _$CEVTxInfoFromJson(Map<String, dynamic> json) => CEVTxInfo(
      token: json['token'] as String,
      txHash: json['tx_hash'] as String,
      timePoint:
          CEVTimePoint.fromJson(json['time_point'] as Map<String, dynamic>),
      callHash: json['call_hash'] as String,
    );

Map<String, dynamic> _$CEVTxInfoToJson(CEVTxInfo instance) => <String, dynamic>{
      'token': instance.token,
      'tx_hash': instance.txHash,
      'time_point': instance.timePoint,
      'call_hash': instance.callHash,
    };

CEVTimePoint _$CEVTimePointFromJson(Map<String, dynamic> json) => CEVTimePoint(
      height: json['height'] as String,
      index: json['index'] as String,
    );

Map<String, dynamic> _$CEVTimePointToJson(CEVTimePoint instance) =>
    <String, dynamic>{
      'height': instance.height,
      'index': instance.index,
    };
