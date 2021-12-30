// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CEVAccount _$CEVAccountFromJson(Map<String, dynamic> json) => CEVAccount(
      pk: json['pk'] as String?,
      address: json['address'] as String?,
      did: json['did'] as String?,
      seed: json['seed'] as String?,
    );

Map<String, dynamic> _$CEVAccountToJson(CEVAccount instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'address': instance.address,
      'did': instance.did,
      'seed': instance.seed,
    };
