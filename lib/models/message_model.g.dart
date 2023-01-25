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
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      imageData: (json['imageData'] as List<dynamic>?)
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
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'imageData': instance.imageData,
    };
