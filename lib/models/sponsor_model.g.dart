// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sponsor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SponsorModel _$SponsorModelFromJson(Map<String, dynamic> json) => SponsorModel(
      id: json['id'] as String,
      status: json['status'] as int,
      showStatus: json['showStatus'] as int,
      creditQty: json['creditQty'] as int,
      securityCode: json['securityCode'] as String,
      groupId: json['groupId'] as String,
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String,
      eventPic: json['eventPic'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPic: json['userPic'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$SponsorModelToJson(SponsorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'showStatus': instance.showStatus,
      'creditQty': instance.creditQty,
      'securityCode': instance.securityCode,
      'groupId': instance.groupId,
      'eventId': instance.eventId,
      'eventTitle': instance.eventTitle,
      'eventPic': instance.eventPic,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPic': instance.userPic,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'updateTime': instance.updateTime.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
    };
