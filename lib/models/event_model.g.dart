// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeData _$TimeDataFromJson(Map<String, dynamic> json) => TimeData(
      id: json['id'],
      status: json['status'],
      desc: json['desc'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      day: json['day'],
      dayWeek: json['dayWeek'],
      week: json['week'],
      exceptDay: json['exceptDay'],
    );

Map<String, dynamic> _$TimeDataToJson(TimeData instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'desc': instance.desc,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'day': instance.day,
      'dayWeek': instance.dayWeek,
      'week': instance.week,
      'exceptDay': instance.exceptDay,
    };

PromotionData _$PromotionDataFromJson(Map<String, dynamic> json) =>
    PromotionData(
      id: json['id'],
      status: json['status'],
      title: json['title'],
      typeId: json['typeId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );

Map<String, dynamic> _$PromotionDataToJson(PromotionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'typeId': instance.typeId,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

OptionData _$OptionDataFromJson(Map<String, dynamic> json) => OptionData(
      id: json['id'],
      value: json['value'],
    );

Map<String, dynamic> _$OptionDataToJson(OptionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
    };

PicData _$PicDataFromJson(Map<String, dynamic> json) => PicData(
      id: json['id'],
      type: json['type'],
      url: json['url'],
    );

Map<String, dynamic> _$PicDataToJson(PicData instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'url': instance.url,
    };
