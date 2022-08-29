// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CEVTransactionDbModel _$CEVTransactionDbModelFromJson(
        Map<String, dynamic> json) =>
    CEVTransactionDbModel(
      id: json['id'] as String,
      data: json['data'] as String,
      progress: (json['progress'] as num).toDouble(),
      transactionType:
          $enumDecode(_$TransactonTypeEnumMap, json['transaction_type']),
      signatory: json['signatory'] as String,
      date: json['date'] as int,
    );

Map<String, dynamic> _$CEVTransactionDbModelToJson(
        CEVTransactionDbModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
      'progress': instance.progress,
      'signatory': instance.signatory,
      'transaction_type': _$TransactonTypeEnumMap[instance.transactionType]!,
      'date': instance.date,
    };

const _$TransactonTypeEnumMap = {
  TransactonType.spent: 'spent',
  TransactonType.refund: 'refund',
};
