import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
import 'etc_model.dart';
part 'story_model.g.dart';

class StoryModelEx extends StoryModel {
  StoryModelEx.empty(
      String id,
      {
        int    status = 0,
        String title = '',
        String desc = '',
        String pic = '',
        String groupId = '',
        String eventId = '',
        String country = '',
        String countryState = '',
        String userId = '',
        int likeCount = 0,
        int voteCount = 0,
        int commentCount = 0,
        String updateTime = '',
        String createTime = '',

        List<String>  tagData = const [],
        List<String>  searchData = const [],
        List<String>  linkUserData = const [],
        List<PicData> picData = const [],
      }) : super(
    id: id,
    status: status,
    desc: desc,
    groupId: groupId,
    eventId: eventId,
    country: country,
    countryState: countryState,
    userId: userId,
    likeCount: likeCount,
    voteCount: voteCount,
    commentCount: commentCount,
    updateTime: updateTime,
    createTime: createTime,

    tagData: tagData,
    searchData: searchData,
    linkUserData: linkUserData,
    picData: picData,
  );
}

@JsonSerializable()
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
  int     commentCount;   // 댓글 갯수
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
    required this.commentCount,
    required this.updateTime,
    required this.createTime,

    required this.tagData,
    required this.searchData,
    required this.linkUserData,
    required this.picData,
  });

  factory StoryModel.fromJson(JSON json) => _$StoryModelFromJson(json);
  JSON toJSON() => _$StoryModelToJson(this);
}
