import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'account.g.dart';

CEVAccount accountFromJson(String str) => CEVAccount.fromJson(json.decode(str));

String accountToJson(CEVAccount data) => json.encode(data.toJson());

@JsonSerializable(fieldRename: FieldRename.snake)
class CEVAccount {
  CEVAccount({this.pubKey, this.balance, this.address, this.did, this.seed});

  factory CEVAccount.fromJson(Map<String, dynamic> json) =>
      _$CEVAccountFromJson(json);

  Map<String, dynamic> toJson() => _$CEVAccountToJson(this);

  String? pubKey;
  String? address;
  String? did;
  String? seed;
  BigInt? balance;
  BigInt? tokenDecimals;
  String? tokenSymbol;
}
