import 'package:get/get.dart';
import '../data/utils.dart';

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
  String    updateTime;
  String    createTime;
  bool      mobileCheck;
  bool      emailCheck;
  UserModel({
    required this.userId,
    required this.loginId,
    required this.nickName,
    required this.pic,
    required this.birthYear,
    required this.gender,
    required this.mobile,
    required this.email,
    this.updateTime   = '',
    this.createTime   = '',
    this.mobileCheck  = false,
    this.emailCheck   = false,
  });

  factory UserModel.fromJson(JSON json) => _$UserModelFromJson(json);
  JSON toJSON() => _$UserModelToJson(this);
}
