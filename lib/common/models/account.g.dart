// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CEVAccount _$CEVAccountFromJson(Map<String, dynamic> json) => CEVAccount(
      pubKey: json['pub_key'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
      address: json['address'] as String?,
      did: json['did'] as String?,
      seed: json['seed'] as String?,
    )
      ..tokenDecimals = json['token_decimals'] == null
          ? null
          : BigInt.parse(json['token_decimals'] as String)
      ..tokenSymbol = json['token_symbol'] as String?;

Map<String, dynamic> _$CEVAccountToJson(CEVAccount instance) =>
    <String, dynamic>{
      'pub_key': instance.pubKey,
      'address': instance.address,
      'did': instance.did,
      'seed': instance.seed,
      'balance': instance.balance,
      'token_decimals': instance.tokenDecimals?.toString(),
      'token_symbol': instance.tokenSymbol,
    };
