import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'transaction.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CEVTransactionDbModel {
  CEVTransactionDbModel();

  factory CEVTransactionDbModel.fromJson(Map<String, dynamic> json) =>
      _$CEVTransactionDbModelFromJson(json);

  Map<String, dynamic> toJson() => _$CEVTransactionDbModelToJson(this);

  late String id;
  late String data;
  late int date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CEVTransactionDbModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
