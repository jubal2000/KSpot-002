// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etc_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeData _$TimeDataFromJson(Map<String, dynamic> json) => TimeData(
      id: json['id'] as String,
      status: json['status'] as int,
      type: json['type'] as int,
      title: json['title'] as String,
      desc: json['desc'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      index: json['index'] as int,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      day: (json['day'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dayWeek:
          (json['dayWeek'] as List<dynamic>?)?.map((e) => e as String).toList(),
      week: (json['week'] as List<dynamic>?)?.map((e) => e as String).toList(),
      exceptDay: (json['exceptDay'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      customData: json['customData'] as List<dynamic>?,
    );

Map<String, dynamic> _$TimeDataToJson(TimeData instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'type': instance.type,
      'title': instance.title,
      'desc': instance.desc,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'index': instance.index,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'day': instance.day,
      'dayWeek': instance.dayWeek,
      'week': instance.week,
      'exceptDay': instance.exceptDay,
      'customData': instance.customData,
    };

PromotionData _$PromotionDataFromJson(Map<String, dynamic> json) =>
    PromotionData(
      id: json['id'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      typeId: json['typeId'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
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

CustomData _$CustomDataFromJson(Map<String, dynamic> json) => CustomData(
      id: json['id'] as String,
      title: json['title'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$CustomDataToJson(CustomData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'value': instance.value,
    };

PicData _$PicDataFromJson(Map<String, dynamic> json) => PicData(
      id: json['id'] as String,
      type: json['type'] as int,
      url: json['url'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$PicDataToJson(PicData instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'url': instance.url,
      'data': instance.data,
    };

CountryData _$CountryDataFromJson(Map<String, dynamic> json) => CountryData(
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      countryFlag: json['countryFlag'] as String,
      createTime: json['createTime'] as String,
    );

Map<String, dynamic> _$CountryDataToJson(CountryData instance) =>
    <String, dynamic>{
      'country': instance.country,
      'countryState': instance.countryState,
      'countryFlag': instance.countryFlag,
      'createTime': instance.createTime,
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
