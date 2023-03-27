// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowModel _$FollowModelFromJson(Map<String, dynamic> json) => FollowModel(
      id: json['id'] as String,
      status: json['status'] as int,
      targetId: json['targetId'] as String,
      targetName: json['targetName'] as String,
      targetPic: json['targetPic'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPic: json['userPic'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$FollowModelToJson(FollowModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'targetId': instance.targetId,
      'targetName': instance.targetName,
      'targetPic': instance.targetPic,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPic': instance.userPic,
      'createTime': instance.createTime.toIso8601String(),
    };
