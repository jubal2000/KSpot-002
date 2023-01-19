// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      id: json['id'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      titleKr: json['titleKr'] as String,
      desc: json['desc'] as String,
      descKr: json['descKr'] as String,
      pic: json['pic'] as String,
      groupId: json['groupId'] as String,
      placeId: json['placeId'] as String,
      enterFee: (json['enterFee'] as num).toDouble(),
      reserveFee: (json['reserveFee'] as num).toDouble(),
      reserveDay: json['reserveDay'] as int,
      currency: json['currency'] as String,
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      userId: json['userId'] as String,
      likeCount: json['likeCount'] as int,
      voteCount: json['voteCount'] as int,
      commentCount: json['commentCount'] as int,
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      tagData:
          (json['tagData'] as List<dynamic>?)?.map((e) => e as String).toList(),
      picData: (json['picData'] as List<dynamic>?)
          ?.map((e) => PicData.fromJson(e as Map<String, dynamic>))
          .toList(),
      managerData: (json['managerData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      searchData: (json['searchData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      timeData: (json['timeData'] as List<dynamic>?)
          ?.map((e) => TimeData.fromJson(e as Map<String, dynamic>))
          .toList(),
      optionData: (json['optionData'] as List<dynamic>?)
          ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      customData: (json['customData'] as List<dynamic>?)
          ?.map((e) => CustomData.fromJson(e as Map<String, dynamic>))
          .toList(),
      promotionData: (json['promotionData'] as List<dynamic>?)
          ?.map((e) => PromotionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'titleKr': instance.titleKr,
      'desc': instance.desc,
      'descKr': instance.descKr,
      'pic': instance.pic,
      'groupId': instance.groupId,
      'placeId': instance.placeId,
      'enterFee': instance.enterFee,
      'reserveFee': instance.reserveFee,
      'reserveDay': instance.reserveDay,
      'currency': instance.currency,
      'country': instance.country,
      'countryState': instance.countryState,
      'userId': instance.userId,
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
      'customData': instance.customData,
      'promotionData': instance.promotionData,
    };
