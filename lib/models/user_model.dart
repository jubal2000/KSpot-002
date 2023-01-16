import 'package:get/get.dart';
import '../utils/utils.dart';

import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  String    userId;
  String    loginId;
  String    nickName;
  String    pic;
  int       birthYear;
  String    gender;
  String    mobile;
  String    email;
  String    country;
  String    countryState;
  String    updateTime;
  String    createTime;
  bool      mobileCheck;
  bool      emailCheck;
  List<CountryData> countrySelectList;

  UserModel({
    required this.userId,
    required this.loginId,
    required this.nickName,
    required this.pic,
    required this.birthYear,
    required this.gender,
    required this.mobile,
    required this.email,
    required this.country,
    required this.countryState,
    this.updateTime   = '',
    this.createTime   = '',
    this.mobileCheck  = false,
    this.emailCheck   = false,
    this.countrySelectList = const [],
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
