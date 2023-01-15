// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartModel _$StartModelFromJson(Map<String, dynamic> json) => StartModel(
      id: json['id'] as String,
      infoVersion: json['infoVersion'] as int,
      androidVersion: json['androidVersion'] as String,
      androidUpdate: json['androidUpdate'] as bool,
      iosVersion: json['iosVersion'] as String,
      iosUpdate: json['iosUpdate'] as bool,
    );

Map<String, dynamic> _$StartModelToJson(StartModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'infoVersion': instance.infoVersion,
      'androidVersion': instance.androidVersion,
      'androidUpdate': instance.androidUpdate,
      'iosVersion': instance.iosVersion,
      'iosUpdate': instance.iosUpdate,
    };
