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
        String desc = '',
        String pic = '',
        String groupId = '',
        String eventId = '',
        String eventTitle = '',
        String eventPic = '',
        String country = '',
        String countryState = '',
        String userId = '',
        String userName = '',
        String userPic = '',
        int likeCount = 0,
        int voteCount = 0,
        int commentCount = 0,
        String updateTime = '',
        String createTime = '',
      }) : super(
    id: id,
    status: status,
    desc: desc,
    groupId: groupId,
    eventId: eventId,
    eventTitle: eventTitle,
    eventPic: eventPic,
    country: country,
    countryState: countryState,
    userId: userId,
    userName: userName,
    userPic: userPic,
    likeCount: likeCount,
    commentCount: commentCount,
    updateTime: updateTime,
    createTime: createTime,
  );
}

@JsonSerializable(
  explicitToJson: true,
)
class StoryModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String  desc;
  String  groupId;        // 그룹 ID
  String  eventId;        // 이벤트 링크 ID
  @JsonKey(defaultValue: '')
  String  eventTitle;     // 이벤트 링크 Title
  @JsonKey(defaultValue: '')
  String  eventPic;       // 이벤트 링크 Pic
  String  country;        // 국가
  String  countryState;   // 도시
  String  userId;         // 소유 유저
  String  userName;       // 소유 유저 name
  String  userPic;        // 소유 유저 pic
  int     likeCount;      // 종아요 횟수
  int     commentCount;   // 댓글 갯수
  String  updateTime;     // 수정 시간
  String  createTime;     // 생성 시간

  List<PicData>?    picData;        // 메인 이지미 목록
  List<OptionData>? optionData;     // 옵션 정보
  List<String>?     tagData;        // tag
  List<String>?     searchData;     // 검색어 목록

  StoryModel({
    required this.id,
    required this.status,
    required this.desc,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.eventPic,
    required this.country,
    required this.countryState,
    required this.userId,
    required this.userName,
    required this.userPic,
    required this.likeCount,
    required this.commentCount,
    required this.updateTime,
    required this.createTime,

    this.picData,
    this.optionData,
    this.tagData,
    this.searchData,
  });

  factory StoryModel.fromJson(JSON json) => _$StoryModelFromJson(json);
  JSON toJson() => _$StoryModelToJson(this);

  //------------------------------------------------------------------------------------------------------
  //  PicData
  //

  get getPicDataList {
    List<JSON> result = [];
    if (picData != null) {
      for (var item in picData!) {
        result.add(item.toJson());
      }
    }
    return result;
  }

  //------------------------------------------------------------------------------------------------------
  //  TagData
  //

  get getTagDataMap {
    JSON result = {};
    if (tagData != null) {
      for (var item in tagData!) {
        result[item] = item;
      }
    }
    return result;
  }

  addTagData(String tag) {
    tagData ??= [];
    if (!tagData!.contains(tag)) {
      tagData!.add(tag);
    }
    return tagData!.indexOf(tag);
  }

  //------------------------------------------------------------------------------------------------------
  //  OptionData
  //

  get getOptionDataMap {
    JSON result = {};
    if (optionData != null) {
      for (var item in optionData!) {
        result[item.id] = item.value;
      }
    }
    return result;
  }

  getOptionValue(String key) {
    final optionMap = getOptionDataMap;
    return optionMap[key] != null && optionMap[key] == '1';
  }

  setOptionDataMap(JSON map) {
    optionData ??= [];
    optionData!.clear();
    if (map.isNotEmpty) {
      for (var item in map.entries) {
        optionData!.add(OptionData(
          id: item.key,
          value: item.value,
        ));
      }
    }
    return optionData;
  }
}
