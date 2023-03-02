// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadFileModel _$UploadFileModelFromJson(Map<String, dynamic> json) =>
    UploadFileModel(
      id: json['id'] as String,
      status: json['status'] as int,
      name: json['name'] as String,
      size: json['size'] as int,
      extension: json['extension'] as String,
      thumb: json['thumb'] as String,
      url: json['url'] as String,
      path: json['path'] as String?,
    );

Map<String, dynamic> _$UploadFileModelToJson(UploadFileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'name': instance.name,
      'size': instance.size,
      'extension': instance.extension,
      'thumb': instance.thumb,
      'url': instance.url,
      'path': instance.path,
    };
