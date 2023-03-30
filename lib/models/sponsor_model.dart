import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kspot_002/models/user_model.dart';
import '../utils/utils.dart';
import 'etc_model.dart';
import 'event_model.dart';

part 'sponsor_model.g.dart';

@JsonSerializable()
class SponsorModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active)
  int     showStatus;     // 보여주기 상태 (0: disable, 1: visible)
  int     creditQty;      // 크래딧 갯수
  String  securityCode;   // 보안코드
  String  groupId;        // 이벤트 그룹 ID
  String  eventId;        // 이벤트 링크 ID
  String  eventTitle;     // 이벤트 링크 Title
  String  eventPic;       // 이벤트 링크 Pic
  String  userId;         // 소유 유저
  String  userName;       // 소유 유저 name
  String  userPic;        // 소유 유저 pic
  DateTime startTime;     // 추천 시작 시간
  DateTime endTime;       // 추천 종료 시간
  DateTime updateTime;    // 수정 시간
  DateTime createTime;    // 생성 시간

  @JsonKey(ignore: true)
  DateTime? cacheTime;    // for local cache refresh time..

  SponsorModel({
    required this.id,
    required this.status,
    required this.showStatus,
    required this.creditQty,
    required this.securityCode,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.eventPic,
    required this.userId,
    required this.userName,
    required this.userPic,
    required this.startTime,
    required this.endTime,
    required this.updateTime,
    required this.createTime,
  });

  static createEvent(EventModel event, UserModel user, int showStatus, int creditQty, DateTime startTime, DateTime endTime) {
    return SponsorModel(
      id: '',
      status: 1,
      showStatus: showStatus,
      creditQty: creditQty,
      securityCode: '',
      groupId: event.groupId,
      eventId: event.id,
      eventTitle: event.title,
      eventPic: event.pic,
      userId: user.id,
      userName: user.nickName,
      userPic: user.pic,
      startTime: startTime,
      endTime: endTime,
      updateTime: DateTime(0),
      createTime: DateTime(0),
    );
  }

  factory SponsorModel.fromJson(JSON json) => _$SponsorModelFromJson(json);
  JSON toJson() => _$SponsorModelToJson(this);
}
