import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'rust_data.g.dart';

CEVRustResponse stationFromJson(String str) =>
    CEVRustResponse.fromJson(json.decode(str));

String stationToJson(CEVRustResponse data) => json.encode(data.toJson());

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CEVRustResponse {
  CEVRustResponse({this.error, this.message});

  factory CEVRustResponse.fromJson(Map<String, dynamic> json) =>
      _$CEVRustResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CEVRustResponseToJson(this);

  bool? error;
  String? message;
}
