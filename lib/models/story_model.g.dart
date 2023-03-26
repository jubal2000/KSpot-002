// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryModel _$StoryModelFromJson(Map<String, dynamic> json) => StoryModel(
      id: json['id'] as String,
      status: json['status'] as int,
      showStatus: json['showStatus'] as int? ?? 1,
      desc: json['desc'] as String,
      groupId: json['groupId'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      eventTitle: json['eventTitle'] as String? ?? '',
      eventPic: json['eventPic'] as String? ?? '',
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPic: json['userPic'] as String,
      likeCount: json['likeCount'] as int,
      commentCount: json['commentCount'] as int,
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      picData: (json['picData'] as List<dynamic>?)
          ?.map((e) => PicData.fromJson(e as Map<String, dynamic>))
          .toList(),
      optionData: (json['optionData'] as List<dynamic>?)
          ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      tagData:
          (json['tagData'] as List<dynamic>?)?.map((e) => e as String).toList(),
      searchData: (json['searchData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$StoryModelToJson(StoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'showStatus': instance.showStatus,
      'desc': instance.desc,
      'groupId': instance.groupId,
      'eventId': instance.eventId,
      'eventTitle': instance.eventTitle,
      'eventPic': instance.eventPic,
      'country': instance.country,
      'countryState': instance.countryState,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPic': instance.userPic,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'picData': instance.picData?.map((e) => e.toJson()).toList(),
      'optionData': instance.optionData?.map((e) => e.toJson()).toList(),
      'tagData': instance.tagData,
      'searchData': instance.searchData,
    };
