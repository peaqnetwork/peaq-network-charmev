import 'package:charmev/common/models/enum.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'transaction.g.dart';

String? transactionTypeToString(TransactonType type) =>
    _$TransactonTypeEnumMap[type];

@JsonSerializable(fieldRename: FieldRename.snake)
class CEVTransactionDbModel {
  CEVTransactionDbModel({
    required this.id,
    required this.data,
    required this.progress,
    required this.transactionType,
    required this.signatory,
    required this.date,
  });

  factory CEVTransactionDbModel.fromJson(Map<String, dynamic> json) =>
      _$CEVTransactionDbModelFromJson(json);

  Map<String, dynamic> toJson() => _$CEVTransactionDbModelToJson(this);

  String id;
  String data;
  double progress;
  String signatory;
  TransactonType transactionType;
  int date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CEVTransactionDbModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
