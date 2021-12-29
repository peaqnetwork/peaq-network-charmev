// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CEVStation _$CEVStationFromJson(Map<String, dynamic> json) => CEVStation(
      did: json['did'] as String?,
      plugType: json['plug_type'] as String?,
      status: json['status'] as String?,
      power: json['power'] as String?,
    )..address = json['address'] as String?;

Map<String, dynamic> _$CEVStationToJson(CEVStation instance) =>
    <String, dynamic>{
      'did': instance.did,
      'address': instance.address,
      'plug_type': instance.plugType,
      'status': instance.status,
      'power': instance.power,
    };
