// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rust_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CEVRustResponse _$CEVRustResponseFromJson(Map<String, dynamic> json) =>
    CEVRustResponse(
      error: json['error'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$CEVRustResponseToJson(CEVRustResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
    };
