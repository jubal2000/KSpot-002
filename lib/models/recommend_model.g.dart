// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendModel _$RecommendModelFromJson(Map<String, dynamic> json) => RecommendModel(
      id: json['id'] as String,
      status: json['status'] as int,
      showStatus: json['showStatus'] as int,
      creditQty: json['creditQty'] as int,
      desc: json['desc'] as String,
      securityCode: json['securityCode'] as String,
      targetType: json['targetType'] as String,
      targetGroupId: json['targetGroupId'] as String,
      targetId: json['targetId'] as String,
      targetTitle: json['targetTitle'] as String,
      targetPic: json['targetPic'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPic: json['userPic'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$RecommendModelToJson(RecommendModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'showStatus': instance.showStatus,
      'desc': instance.desc,
      'creditQty': instance.creditQty,
      'securityCode': instance.securityCode,
      'targetType': instance.targetType,
      'targetGroupId': instance.targetGroupId,
      'targetId': instance.targetId,
      'targetTitle': instance.targetTitle,
      'targetPic': instance.targetPic,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPic': instance.userPic,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'updateTime': instance.updateTime.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
    };
