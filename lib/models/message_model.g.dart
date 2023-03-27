// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as String,
      status: json['status'] as int,
      desc: json['desc'] as String,
      targetId: json['targetId'] as String,
      targetName: json['targetName'] as String,
      targetPic: json['targetPic'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderPic: json['senderPic'] as String,
      updateTime: DateTime.parse(json['updateTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
      picData:
          (json['picData'] as List<dynamic>?)?.map((e) => e as String).toList(),
      openTimeData: (json['openTimeData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'desc': instance.desc,
      'targetId': instance.targetId,
      'targetName': instance.targetName,
      'targetPic': instance.targetPic,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderPic': instance.senderPic,
      'updateTime': instance.updateTime.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
      'picData': instance.picData,
      'openTimeData': instance.openTimeData,
    };

MessageGroupModel _$MessageGroupModelFromJson(Map<String, dynamic> json) =>
    MessageGroupModel(
      id: json['id'] as String,
      lastMessage: json['lastMessage'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPic: json['userPic'] as String,
      updateTime: json['updateTime'] as String,
    );

Map<String, dynamic> _$MessageGroupModelToJson(MessageGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lastMessage': instance.lastMessage,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPic': instance.userPic,
      'updateTime': instance.updateTime,
    };
