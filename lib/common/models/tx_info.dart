import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'tx_info.g.dart';

CEVTxInfo txInfoFromJson(String str) => CEVTxInfo.fromJson(json.decode(str));

String txInfoToJson(CEVTxInfo data) => json.encode(data.toJson());

@JsonSerializable(fieldRename: FieldRename.snake)
class CEVTxInfo {
  CEVTxInfo(
      {required this.token,
      required this.txHash,
      required this.timePoint,
      required this.callHash});

  factory CEVTxInfo.fromJson(Map<String, dynamic> json) =>
      _$CEVTxInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CEVTxInfoToJson(this);

  String token;
  String txHash;
  CEVTimePoint timePoint;
  String callHash;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CEVTimePoint {
  CEVTimePoint({
    required this.height,
    required this.index,
  });

  String height;
  String index;

  factory CEVTimePoint.fromJson(Map<String, dynamic> json) =>
      _$CEVTimePointFromJson(json);

  Map<String, dynamic> toJson() => _$CEVTimePointToJson(this);
}
