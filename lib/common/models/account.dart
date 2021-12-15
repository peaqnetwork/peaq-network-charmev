import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'account.g.dart';

CEVAccount accountFromJson(String str) => CEVAccount.fromJson(json.decode(str));

String accountToJson(CEVAccount data) => json.encode(data.toJson());

@JsonSerializable(fieldRename: FieldRename.snake)
class CEVAccount {
  CEVAccount({this.pk, this.address, this.did});

  factory CEVAccount.fromJson(Map<String, dynamic> json) =>
      _$CEVAccountFromJson(json);

  Map<String, dynamic> toJson() => _$CEVAccountToJson(this);

  String? pk;
  String? address;
  String? did;
}
