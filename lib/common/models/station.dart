import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'station.g.dart';

CEVStation stationFromJson(String str) => CEVStation.fromJson(json.decode(str));

String stationToJson(CEVStation data) => json.encode(data.toJson());

@JsonSerializable(fieldRename: FieldRename.snake)
class CEVStation {
  CEVStation({this.did, this.plugType, this.status, this.power});

  factory CEVStation.fromJson(Map<String, dynamic> json) =>
      _$CEVStationFromJson(json);

  Map<String, dynamic> toJson() => _$CEVStationToJson(this);

  String? did;
  String? address;
  String? plugType;
  String? status;
  String? power;
}
