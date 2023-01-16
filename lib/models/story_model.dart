import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import '../data/utils.dart';
part 'story_model.g.dart';

class StoryModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String  desc;
  String  groupId;        // 그룹 ID
  String  eventId;        // 이벤트 링크 ID
  String  country;        // 국가
  String  countryState;   // 도시
  String  userId;         // 소유 유저
  int     likeCount;      // 종아요 횟수
  int     voteCount;      // 추천 횟수
  String  updateTime;     // 수정 시간
  String  createTime;     // 생성 시간

  List<String>        tagData;        // tag
  List<String>        searchData;     // 검색어 목록
  List<String>        linkUserData;   // 유저링크 목록
  List<PicData>       picData;        // 메인 이지미 목록

  StoryModel({
    required this.id,
    required this.status,
    required this.desc,
    required this.groupId,
    required this.eventId,
    required this.country,
    required this.countryState,
    required this.userId,
    required this.likeCount,
    required this.voteCount,
    required this.updateTime,
    required this.createTime,

    required this.tagData,
    required this.searchData,
    required this.linkUserData,
    required this.picData,
  });

  factory StoryModel.fromJson(JSON json) => StoryModel(
    id:         json['id'] as String,
    status:     json['status'] as int,
    desc:       json['desc'] as String,
    groupId:    json['groupId'] as String,
    eventId:    json['eventId'] as String,
    country:    json['country'] as String,
    countryState: json['countryState'] as String,
    userId:     json['userId'] as String,
    likeCount:  json['likeCount'] as int,
    voteCount:  json['voteCount'] as int,
    updateTime: json['updateTime'] as String,
    createTime: json['createTime'] as String,
    tagData: (json['tagData'] as List<dynamic>)
        .map((e) => e as String).toList(),
    searchData: (json['searchData'] as List<dynamic>)
        .map((e) => e as String).toList(),
    linkUserData: (json['linkUserData'] as List<dynamic>)
        .map((e) => e as String).toList(),
    picData: (json['picData'] as List<dynamic>)
        .map((e) => PicData.fromJson(e)).toList(),
  );

  JSON toJSON() => <String, dynamic> {
    'id':         id,
    'status':     status,
    'desc':       desc,
    'groupId':    groupId,
    'placeId':    eventId,
    'country':    country,
    'countryState': countryState,
    'userId':     userId,
    'likeCount':  likeCount,
    'voteCount':  voteCount,
    'updateTime': updateTime,
    'createTime': createTime,
    'tagData':    tagData,
    'searchData': searchData,
    'linkUserData': linkUserData,
    'picData':    picData.map((e) => e.toJSON()).toList(),
  };
}

@JsonSerializable()
class PicData {
  String id = '';
  int    type = 0; // 이미지 종류 (0:photo, 1:movie..)
  String url = '';
  PicData({
    id,
    type,
    url,
  });
  factory PicData.fromJson(JSON json) => _$PicDataFromJson(json);
  JSON toJSON() => _$PicDataToJson(this);
}
