
import 'package:json_annotation/json_annotation.dart';
import 'package:kspot_002/models/upload_model.dart';
import 'package:kspot_002/models/user_model.dart';
import '../utils/utils.dart';

part 'etc_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class TimeData {
  String      id;
  int         status;       // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  int         type;         // 타입선택 (0:날짜선택, 1:기간선택)
  String      title;
  String      desc;
  String      startTime;   // 시작시간
  String      endTime;     // 종료시간
  int         index;
  String?     startDate;   // 시작일
  String?     endDate;     // 종료일
  List<String>? day;        // 특별한 날 선택
  List<String>? dayWeek;    // 요일 선택 (월, 화..)
  List<String>? week;       // 주간 선택 (첫째주, 마지막주..)
  List<String>? exceptDay;  // 제외 날 선택
  List<dynamic>? customData; // 사용자 설정 데이터

  TimeData({
    required this.id,
    required this.status,
    required this.type,
    required this.title,
    required this.desc,
    required this.startTime,
    required this.endTime,
    required this.index,
    this.startDate,
    this.endDate,
    this.day,
    this.dayWeek,
    this.week,
    this.exceptDay,
    this.customData,
  });
  factory TimeData.fromJson(JSON json) => _$TimeDataFromJson(json);
  JSON toJson() => _$TimeDataToJson(this);
}

@JsonSerializable()
class PromotionData {
  String id;
  int    status;            // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String title;
  String typeId;           // 프로모션 type ID
  String startDate;        // 시작일
  String endDate;          // 종료일
  String startTime;        // 시작시간
  String endTime;          // 종료시간

  PromotionData({
    required this.id,
    required this.status,
    required this.title,
    required this.typeId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
  });
  factory PromotionData.fromJson(JSON json) => _$PromotionDataFromJson(json);
  JSON toJson() => _$PromotionDataToJson(this);
}

@JsonSerializable()
class CustomData {
  String id;
  String title;
  String customId;
  String parentId;
  String? desc;
  String? url;
  String? data;

  CustomData({
    required this.id,
    required this.title,
    required this.customId,
    required this.parentId,
    this.desc,
    this.url,
    this.data,
  });
  factory CustomData.fromJson(JSON json) => _$CustomDataFromJson(json);
  JSON toJson() => _$CustomDataToJson(this);
}

@JsonSerializable()
class PicData {
  String  id;
  int     type; // 이미지 종류 (0:photo or picture, 1:movie..)
  String  url;

  PicData({
    required this.id,
    required this.type,
    required this.url,
  });
  factory PicData.fromJson(JSON json) => _$PicDataFromJson(json);
  JSON toJson() => _$PicDataToJson(this);
}

@JsonSerializable()
class CountryData {
  String    country;
  String    countryState;
  String    countryFlag;
  String    createTime;

  CountryData({
    required this.country,
    required this.countryState,
    required this.countryFlag,
    required this.createTime,
  });

  factory CountryData.fromJson(JSON json) => _$CountryDataFromJson(json);
  JSON toJson() => _$CountryDataToJson(this);
}

@JsonSerializable()
class OptionData {
  String id;
  String value;

  OptionData({
    required this.id,
    required this.value,
  });
  factory OptionData.fromJson(JSON json) => _$OptionDataFromJson(json);
  JSON toJson() => _$OptionDataToJson(this);
}

@JsonSerializable()
class AddressData {
  String address1;
  String address2;
  double lat;
  double lng;

  AddressData({
    required this.address1,
    required this.address2,
    required this.lat,
    required this.lng,
  });
  factory AddressData.fromJson(JSON json) => _$AddressDataFromJson(json);
  JSON toJson() => _$AddressDataToJson(this);

  get desc {
    return '$address1, $address2';
  }
}

@JsonSerializable()
class MemberData {
  String  id;            // user id
  int     status;
  String  nickName;
  String  pic;
  String? createTime;

  MemberData({
    required this.id,
    required this.status,
    required this.nickName,
    required this.pic,
    this.createTime,
  });

  factory MemberData.fromJson(JSON json) => _$MemberDataFromJson(json);
  JSON toJson() => _$MemberDataToJson(this);

  setFromUserModel(UserModel user) {
    id          = user.id;
    status      = 1;
    nickName    = user.nickName;
    pic         = user.pic;
    createTime  = DateTime.now().toString();
  }
}

@JsonSerializable()
class DescData {
  String id;
  String desc;
  DescData({
    required this.id,
    required this.desc,
  });
  factory DescData.fromJson(JSON json) => _$DescDataFromJson(json);
  JSON toJson() => _$DescDataToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
)
class NoticeModel {
  String  id;
  int     status;   // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  int     index;    // sort index.. 0 is first view..
  String  desc;
  String  userId;
  String  userName;
  String  createTime;     // 생성 시간

  List<UploadFileModel>? fileList;

  NoticeModel({
    required this.id,
    required this.status,
    required this.index,
    required this.desc,
    required this.userId,
    required this.userName,
    required this.createTime,

    this.fileList,
  });
  factory NoticeModel.fromJson(JSON json) => _$NoticeModelFromJson(json);
  JSON toJson() => _$NoticeModelToJson(this);
}
