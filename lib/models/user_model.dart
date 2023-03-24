import 'package:get/get.dart';
import '../utils/utils.dart';

import 'package:json_annotation/json_annotation.dart';

import 'etc_model.dart';
part 'user_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class UserModel {
  String    id;
  int       status;
  String    loginId;
  String    loginType;  // 로그인 방식 ('', 'phone'..)
  String    nickName;
  @JsonKey(defaultValue: '')
  String    realName;
  String    pic;
  String    message;
  int       birthYear;
  String    gender;

  String    mobile;
  String    mobileIntl;
  @JsonKey(defaultValue: 0)
  int       mobileShow; // 0:hide 1:show 2:for follower
  String    mobileVerifyTime;

  String    email;
  @JsonKey(defaultValue: 0)
  int       emailShow; // 0:hide 1:show 2:for follower
  String    emailVerifyTime;

  String    country;
  String    countryState;

  @JsonKey(defaultValue: 0)
  int       followCount;
  @JsonKey(defaultValue: 0)
  int       followerCount;
  @JsonKey(defaultValue: 0)
  int       likeCount;

  @JsonKey(defaultValue: 0)
  int       creditAmount;
  @JsonKey(defaultValue: 0)
  int       creditUsed;

  String    pushToken;
  String    deviceType;
  String    updateTime;
  String    createTime;

  String?   emailNew;
  BankData? refundBank;

  List<DescData>?     snsData;
  List<OptionData>?   optionData;
  List<OptionData>?   optionPush;

  UserModel({
    required this.id,
    required this.status,
    required this.loginId,
    required this.loginType,
    required this.nickName,
    required this.realName,
    required this.pic,
    required this.message,
    required this.birthYear,
    required this.gender,
    required this.mobile,
    required this.mobileIntl,
    required this.mobileShow,
    required this.mobileVerifyTime,
    required this.email,
    required this.emailShow,
    required this.emailVerifyTime,
    required this.country,
    required this.countryState,
    required this.followCount,
    required this.followerCount,
    required this.likeCount,
    required this.pushToken,
    required this.deviceType,
    required this.updateTime,
    required this.createTime,
    required this.creditAmount,
    required this.creditUsed,

    this.emailNew,
    this.snsData,
    this.optionData,
    this.optionPush,
  });

  static get empty {
    return UserModel.create('', '');
  }

  static create(loginId, loginType, {nickName = '',pic = ''}) {
    return UserModel(
      id: '',
      status: 1,
      loginId: loginId,
      loginType: loginType,
      nickName: nickName,
      realName: '',
      pic: pic,
      message: '',
      birthYear: 0,
      gender: '',
      mobile: '',
      mobileIntl: '',
      mobileShow: 0,
      mobileVerifyTime: '',
      email: '',
      emailShow: 0,
      emailVerifyTime: '',
      country: '',
      countryState: '',
      followCount: 0,
      followerCount: 0,
      likeCount: 0,
      creditAmount: 0,
      creditUsed: 0,
      pushToken: '',
      deviceType: '',
      updateTime: '',
      createTime: '',
    );
  }

  factory UserModel.fromJson(JSON json) => _$UserModelFromJson(json);
  JSON toJson() => _$UserModelToJson(this);

  checkOwner(String userId) {
    return id == userId;
  }

  checkOption(String optionId) {
    if (LIST_EMPTY(optionData)) return;
    for (var item in optionData!) {
      if (item.id == optionId) return true;
    }
    return false;
  }

  //------------------------------------------------------------------------------------------------------
  //  SNSData
  //

  get snsDataMap {
    JSON result = {};
    if (snsData != null) {
      for (var item in snsData!) {
        result[item.id] = item.toJson();
      }
    }
    return result;
  }

  setSnsData(JSON data) {
    snsData ??= [];
    for (var item in data.entries) {
      snsData!.add(item.value);
    }
    return snsData;
  }


}

