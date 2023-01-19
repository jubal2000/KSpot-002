// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      id: json['id'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      desc: json['desc'] as String,
      pic: json['pic'] as String,
      groupId: json['groupId'] as String,
      placeId: json['placeId'] as String,
      enterFee: (json['enterFee'] as num).toDouble(),
      reserveFee: json['reserveFee'] as String,
      currency: json['currency'] as String,
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      userId: json['userId'] as String,
      reservePeriod: json['reservePeriod'] as int,
      likeCount: json['likeCount'] as int,
      voteCount: json['voteCount'] as int,
      commentCount: json['commentCount'] as int,
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      tagData:
          (json['tagData'] as List<dynamic>).map((e) => e as String).toList(),
      picData: (json['picData'] as List<dynamic>)
          .map((e) => PicData.fromJson(e as Map<String, dynamic>))
          .toList(),
      managerData: (json['managerData'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      searchData: (json['searchData'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timeData: (json['timeData'] as List<dynamic>)
          .map((e) => TimeData.fromJson(e as Map<String, dynamic>))
          .toList(),
      optionData: (json['optionData'] as List<dynamic>)
          .map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      promotionData: (json['promotionData'] as List<dynamic>)
          .map((e) => PromotionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'desc': instance.desc,
      'pic': instance.pic,
      'groupId': instance.groupId,
      'placeId': instance.placeId,
      'enterFee': instance.enterFee,
      'reserveFee': instance.reserveFee,
      'currency': instance.currency,
      'country': instance.country,
      'countryState': instance.countryState,
      'userId': instance.userId,
      'reservePeriod': instance.reservePeriod,
      'likeCount': instance.likeCount,
      'voteCount': instance.voteCount,
      'commentCount': instance.commentCount,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'tagData': instance.tagData,
      'managerData': instance.managerData,
      'searchData': instance.searchData,
      'picData': instance.picData,
      'timeData': instance.timeData,
      'optionData': instance.optionData,
      'promotionData': instance.promotionData,
    };

TimeData _$TimeDataFromJson(Map<String, dynamic> json) => TimeData(
      id: json['id'],
      status: json['status'],
      title: json['title'],
      desc: json['desc'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      index: json['index'],
      day: json['day'],
      dayWeek: json['dayWeek'],
      week: json['week'],
      exceptDay: json['exceptDay'],
    );

Map<String, dynamic> _$TimeDataToJson(TimeData instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'desc': instance.desc,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'index': instance.index,
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
