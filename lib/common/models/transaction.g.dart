// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CEVTransactionDbModel _$CEVTransactionDbModelFromJson(
        Map<String, dynamic> json) =>
    CEVTransactionDbModel()
      ..id = json['id'] as String
      ..data = json['data'] as String
      ..date = json['date'] as int;

Map<String, dynamic> _$CEVTransactionDbModelToJson(
        CEVTransactionDbModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
      'date': instance.date,
    };
