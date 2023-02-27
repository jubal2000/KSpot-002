// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
      id: json['id'] as String,
      status: json['status'] as int,
      action: json['action'] as int,
      desc: json['desc'] as String,
      roomId: json['roomId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderPic: json['senderPic'] as String,
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      openList: (json['openList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      picData:
          (json['picData'] as List<dynamic>?)?.map((e) => e as String).toList(),
      thumbData: (json['thumbData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      fileData: (json['fileData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'action': instance.action,
      'desc': instance.desc,
      'roomId': instance.roomId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderPic': instance.senderPic,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'openList': instance.openList,
      'picData': instance.picData,
      'thumbData': instance.thumbData,
      'fileData': instance.fileData,
    };

ChatRoomModel _$ChatRoomModelFromJson(Map<String, dynamic> json) =>
    ChatRoomModel(
      id: json['id'] as String,
      status: json['status'] as int,
      type: json['type'] as int,
      title: json['title'] as String,
      password: json['password'] as String,
      pic: json['pic'] as String,
      lastMessage: json['lastMessage'] as String,
      userId: json['userId'] as String,
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      memberList: (json['memberList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      memberData: (json['memberData'] as List<dynamic>)
          .map((e) => MemberData.fromJson(e as Map<String, dynamic>))
          .toList(),
      groupId: json['groupId'] as String?,
      country: json['country'] as String?,
      countryState: json['countryState'] as String?,
      fileData: (json['fileData'] as List<dynamic>?)
          ?.map((e) => RoomFileData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatRoomModelToJson(ChatRoomModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'type': instance.type,
      'title': instance.title,
      'password': instance.password,
      'pic': instance.pic,
      'lastMessage': instance.lastMessage,
      'userId': instance.userId,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'memberList': instance.memberList,
      'memberData': instance.memberData.map((e) => e.toJson()).toList(),
      'groupId': instance.groupId,
      'country': instance.country,
      'countryState': instance.countryState,
      'fileData': instance.fileData?.map((e) => e.toJson()).toList(),
    };
