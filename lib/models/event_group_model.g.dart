// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventGroupModel _$EventGroupModelFromJson(Map<String, dynamic> json) =>
    EventGroupModel(
      id: json['id'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      titleKr: json['titleKr'] as String,
      desc: json['desc'] as String,
      descKr: json['descKr'] as String,
      pic: json['pic'] as String,
      contentType: json['contentType'] as String,
      tagData:
          (json['tagData'] as List<dynamic>?)?.map((e) => e as String).toList(),
      searchData: (json['searchData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EventGroupModelToJson(EventGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'titleKr': instance.titleKr,
      'desc': instance.desc,
      'descKr': instance.descKr,
      'pic': instance.pic,
      'contentType': instance.contentType,
      'tagData': instance.tagData,
      'searchData': instance.searchData,
    };
