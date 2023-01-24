// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryModel _$StoryModelFromJson(Map<String, dynamic> json) => StoryModel(
      id: json['id'] as String,
      status: json['status'] as int,
      desc: json['desc'] as String,
      groupId: json['groupId'] as String,
      eventId: json['eventId'] as String,
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      userId: json['userId'] as String,
      likeCount: json['likeCount'] as int,
      voteCount: json['voteCount'] as int,
      commentCount: json['commentCount'] as int,
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      tagData:
          (json['tagData'] as List<dynamic>).map((e) => e as String).toList(),
      searchData: (json['searchData'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      linkUserData: (json['linkUserData'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      picData: (json['picData'] as List<dynamic>)
          .map((e) => PicData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StoryModelToJson(StoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'desc': instance.desc,
      'groupId': instance.groupId,
      'eventId': instance.eventId,
      'country': instance.country,
      'countryState': instance.countryState,
      'userId': instance.userId,
      'likeCount': instance.likeCount,
      'voteCount': instance.voteCount,
      'commentCount': instance.commentCount,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'tagData': instance.tagData,
      'searchData': instance.searchData,
      'linkUserData': instance.linkUserData,
      'picData': instance.picData.map((e) => e.toJson()).toList(),
    };
