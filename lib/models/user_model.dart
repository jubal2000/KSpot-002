import 'package:get/get.dart';
import '../utils/utils.dart';

import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  String    id;
  int       status;
  String    loginId;
  String    loginType;  // 로그인 방식 ('', 'phone'..)
  String    nickName;
  String    pic;
  int       birthYear;
  String    gender;
  String    mobile;
  String    mobileIntl;
  String    email;
  String    country;
  String    countryState;
  int       followCount;
  int       followerCount;
  String    pushToken;
  String    deviceType;
  String    updateTime;
  String    createTime;
  String    mobileVerifyTime;
  String    emailVerifyTime;
  bool      mobileVerified;
  bool      emailVerified;
  Map<String, OptionData>  optionData;
  Map<String, OptionData>  optionPush;

  UserModel({
    required this.id,
    this.status     = 0,
    this.loginId    = '',
    this.loginType  = '',
    this.nickName   = '',
    this.pic        = '',
    this.birthYear  = 0,
    this.gender     = '',
    this.mobile     = '',
    this.mobileIntl = '',
    this.email      = '',
    this.country    = '',
    this.countryState   = '',
    this.followCount    = 0,
    this.followerCount  = 0,
    this.pushToken      = '',
    this.deviceType     = '',
    this.updateTime     = '',
    this.createTime     = '',
    this.mobileVerifyTime = '',
    this.emailVerifyTime  = '',
    this.mobileVerified   = false,
    this.emailVerified    = false,
    this.optionData = const {},
    this.optionPush = const {},
  });

  factory UserModel.fromJson(JSON json) => _$UserModelFromJson(json);
  JSON toJSON() => _$UserModelToJson(this);
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
  JSON toJSON() => _$CountryDataToJson(this);
}

@JsonSerializable()
class OptionData {
  String id = '';
  bool   value = false;
  OptionData({
    id,
    value,
  });
  factory OptionData.fromJson(JSON json) => _$OptionDataFromJson(json);
  JSON toJSON() => _$OptionDataToJson(this);
}

