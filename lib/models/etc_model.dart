
import 'package:json_annotation/json_annotation.dart';
import 'package:kspot_002/models/sponsor_model.dart';
import 'package:kspot_002/models/upload_model.dart';
import 'package:kspot_002/models/user_model.dart';
import 'package:uuid/uuid.dart';
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
  int    status;           // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String title;            // 프로모션 title
  String typeId;           // 프로모션 type id
  String userId;           // 프로모션 유저 id
  String userName;         // 프로모션 유저 이름
  String userPic;          // 프로모션 유저 pic
  DateTime startTime;      // 시작시간
  DateTime endTime;        // 종료시간
  DateTime updateTime;
  DateTime createTime;

  PromotionData({
    required this.id,
    required this.status,
    required this.title,
    required this.typeId,
    required this.userId,
    required this.userName,
    required this.userPic,
    required this.startTime,
    required this.endTime,
    required this.updateTime,
    required this.createTime,
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
  DateTime  createTime;

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
class BankData {
  String    id;
  int       status;
  String    title;
  String    name;     // bank name..
  String    account;  // bank account..
  String    author;   // bank author..

  BankData({
    required this.id,
    required this.status,
    required this.title,
    required this.name,
    required this.account,
    required this.author,
  });

  static get empty {
    return BankData(id: Uuid().v4(), status: 1, title: '', name: '', account: '', author: '');
  }

  factory BankData.fromJson(JSON json) => _$BankDataFromJson(json);
  JSON toJson() => _$BankDataToJson(this);
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
  String    id;            // user id
  int       status;
  String    nickName;
  String    pic;
  DateTime  createTime;

  MemberData({
    required this.id,
    required this.status,
    required this.nickName,
    required this.pic,
    required this.createTime,
  });

  factory MemberData.fromJson(JSON json) => _$MemberDataFromJson(json);
  JSON toJson() => _$MemberDataToJson(this);

  setFromUserModel(UserModel user) {
    id          = user.id;
    status      = 1;
    nickName    = user.nickName;
    pic         = user.pic;
    createTime  = DateTime.now();
  }
}

@JsonSerializable()
class SponsorData {
  String    id;            // user id
  int       creditQty;
  String    userId;
  String    userPic;
  String    userName;
  DateTime  createTime;
  DateTime  startTime;
  DateTime  endTime;

  SponsorData({
    required this.id,
    required this.creditQty,
    required this.userId,
    required this.userPic,
    required this.userName,
    required this.createTime,
    required this.startTime,
    required this.endTime,
  });

  factory SponsorData.fromJson(JSON json) => _$SponsorDataFromJson(json);
  JSON toJson() => _$SponsorDataToJson(this);

  setFromSponsorModel(SponsorModel sponsor) {
    id          = sponsor.id;
    creditQty   = sponsor.creditQty;
    userId      = sponsor.userId;
    userName    = sponsor.userName;
    userPic     = sponsor.userPic;
    createTime  = DateTime.now();
    startTime   = DateTime.now();
    endTime     = DateTime.now();
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
  DateTime createTime;     // 생성 시간

  List<UploadFileModel>? fileData;

  NoticeModel({
    required this.id,
    required this.status,
    required this.index,
    required this.desc,
    required this.userId,
    required this.userName,
    required this.createTime,

    this.fileData,
  });
  factory NoticeModel.fromJson(JSON json) => _$NoticeModelFromJson(json);
  JSON toJson() => _$NoticeModelToJson(this);

  get fileDataMap {
    JSON result = {};
    if (fileData != null) {
      for (var item in fileData!) {
        result[item.id] = item.toJson();
      }
    }
    return result;
  }
}

@JsonSerializable()
class BanData {
  String id;
  String nickName;
  DateTime createTime;
  BanData({
    required this.id,
    required this.nickName,
    required this.createTime,
  });
  factory BanData.fromJson(JSON json) => _$BanDataFromJson(json);
  JSON toJson() => _$BanDataToJson(this);
}
