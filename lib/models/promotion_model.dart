import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kspot_002/models/user_model.dart';
import '../utils/utils.dart';
import 'event_model.dart';

part 'promotion_model.g.dart';

@JsonSerializable()
class PromotionModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active)
  String  type;           // event_banner, popup_main...
  String? title;          // 배너 타이틀
  String? titleKr;        // 배너 타이틀 kr
  String? desc;           // 배너 내용
  String? descKr;         // 배너 내용 kr
  String? pic;            // 배너 이미지
  String? picThumb;       // 배너 미리보기 이미지
  String? picType;        // 배너 파일 형식 (image, movie..)
  double? picWidth;       // 배너 가로 사이즈
  double? picHeight;      // 배너 세로 사이즈
  String? userId;         // 게시자 유저 ID (존재할 경우)
  String? userName;       // 게시자 이름
  String? phone;          // 게시자 전화
  String? email;          // 게시자 이메일
  double? price;          // 광고 구매 가격
  double? priceSale;      // 광고 할인 가격
  double? priceTax;       // 광고 구매 세금
  double? priceTotal;     // 광고 구매 합계가격 (가격 - 할인 + 세금)
  String? currency;       // 결제 통화 (KRW, USD..)
  String? targetType;     // 대상 타입 ('event')
  String? targetGroupId;  // 대상 링크 Group ID
  String? targetId;       // 대상 링크 ID
  String? targetTitle;    // 대상 링크 Title
  String? targetPic;      // 대상 링크 Pic
  DateTime startTime;     // 광고 시작 시간
  DateTime endTime;       // 광고 종료 시간
  DateTime createTime;    // 생성 시간

  @JsonKey(includeFromJson: false)
  DateTime? cacheTime;    // for local cache refresh time..

  PromotionModel({
    required this.id,
    required this.status,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.createTime,
    this.title,
    this.titleKr,
    this.desc,
    this.descKr,
    this.pic,
    this.picThumb,
    this.picType,
    this.picWidth,
    this.picHeight,
    this.userId,
    this.userName,
    this.phone,
    this.email,
    this.price,
    this.priceSale,
    this.priceTax,
    this.priceTotal,
    this.currency,
    this.targetType,
    this.targetId,
    this.targetGroupId,
    this.targetTitle,
    this.targetPic,
  });

  static createEvent(EventModel event, UserModel user, String type,  DateTime startTime, DateTime endTime) {
    return PromotionModel(
      id:             '',
      status:         1,
      type:           type,
      targetType:     'event',
      targetGroupId:  event.groupId,
      targetId:       event.id,
      targetTitle:    event.title,
      targetPic:      event.pic,
      userId:         user.id,
      userName:       user.nickName,
      phone:          user.mobile,
      email:          user.email,
      startTime:      startTime,
      endTime:        endTime,
      createTime:     DateTime.now(),
    );
  }

  factory PromotionModel.fromJson(JSON json) => _$PromotionModelFromJson(json);
  JSON toJson() => _$PromotionModelToJson(this);
}
