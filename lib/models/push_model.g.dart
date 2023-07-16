// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushModel _$PushModelFromJson(Map<String, dynamic> json) => PushModel(
      tokens:
          (json['tokens'] as List<dynamic>).map((e) => e as String).toList(),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PushModelToJson(PushModel instance) => <String, dynamic>{
      'tokens': instance.tokens,
      'data': instance.data,
    };
