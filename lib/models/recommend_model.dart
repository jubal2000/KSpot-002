import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kspot_002/models/user_model.dart';
import '../utils/utils.dart';
import 'etc_model.dart';
import 'event_model.dart';

part 'recommend_model.g.dart';

@JsonSerializable()
class RecommendModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active)
  int     showStatus;     // 보여주기 상태 (0: disable, 1: visible)
  int     creditQty;      // 크래딧 갯수
  String  desc;
  String  securityCode;   // 보안코드
  String  targetType;     // 대상 타입 ('event')
  String  targetGroupId;  // 대상 그룹 ID
  String  targetId;       // 대상 링크 ID
  String  targetTitle;    // 대상 링크 Title
  String  targetPic;      // 대상 링크 Pic
  String  userId;         // 소유 유저
  String  userName;       // 소유 유저 name
  String  userPic;        // 소유 유저 pic
  DateTime startTime;     // 추천 시작 시간
  DateTime endTime;       // 추천 종료 시간
  DateTime updateTime;    // 수정 시간
  DateTime createTime;    // 생성 시간

  @JsonKey(includeFromJson: false)
  DateTime? cacheTime;    // for local cache refresh time..

  RecommendModel({
    required this.id,
    required this.status,
    required this.showStatus,
    required this.creditQty,
    required this.desc,
    required this.securityCode,
    required this.targetType,
    required this.targetGroupId,
    required this.targetId,
    required this.targetTitle,
    required this.targetPic,
    required this.userId,
    required this.userName,
    required this.userPic,
    required this.startTime,
    required this.endTime,
    required this.updateTime,
    required this.createTime,
  });

  static createEvent(EventModel event, UserModel user, int showStatus, int creditQty, DateTime startTime, DateTime endTime, String desc) {
    return RecommendModel(
      id:             '',
      status:         1,
      showStatus:     showStatus,
      creditQty:      creditQty,
      desc:           desc,
      securityCode:   '',
      targetType:     'event',
      targetGroupId:  event.groupId,
      targetId:       event.id,
      targetTitle:    event.title,
      targetPic:      event.pic,
      userId:         user.id,
      userName:       user.nickName,
      userPic:        user.pic,
      startTime:      startTime,
      endTime:        endTime,
      updateTime:     DateTime.now(),
      createTime:     DateTime.now(),
    );
  }

  factory RecommendModel.fromJson(JSON json) => _$RecommendModelFromJson(json);
  JSON toJson() => _$RecommendModelToJson(this);
}
