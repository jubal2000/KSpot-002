import 'package:get/get.dart';
import '../utils/utils.dart';

import 'package:json_annotation/json_annotation.dart';

import 'etc_model.dart';
part 'user_model.g.dart';

class UserModelEx extends UserModel {
  UserModelEx.empty(String id) : super(
    id: id,
    status: 0,
    loginId: '',
    loginType: '',
    nickName: '',
    pic: '',
    message: '',
    birthYear: 0,
    gender: '',
    mobile: '',
    mobileIntl: '',
    email: '',
    country: '',
    countryState: '',
    followCount: 0,
    followerCount: 0,
    pushToken: '',
    deviceType: '',
    updateTime: '',
    createTime: '',
    mobileVerifyTime: '',
    emailVerifyTime: '',
    mobileVerified: false,
    emailVerified: false,
  );

  UserModelEx.create(loginId, loginType, {String nickName = '', String pic = ''}) : super(
    id: '',
    status: 1,
    loginId: loginId,
    loginType: loginType,
    nickName: nickName,
    pic: pic,
    message: '',
    birthYear: 0,
    gender: '',
    mobile: '',
    mobileIntl: '',
    email: '',
    country: '',
    countryState: '',
    followCount: 0,
    followerCount: 0,
    pushToken: '',
    deviceType: '',
    updateTime: '',
    createTime: '',
    mobileVerifyTime: '',
    emailVerifyTime: '',
    mobileVerified: false,
    emailVerified: false,
  );

  UserModelEx.signOut() : super(
    id: '',
    status: 0,
    loginId: '',
    loginType: '',
    nickName: '',
    pic: '',
    message: '',
    birthYear: 0,
    gender: '',
    mobile: '',
    mobileIntl: '',
    email: '',
    country: '',
    countryState: '',
    followCount: 0,
    followerCount: 0,
    pushToken: '',
    deviceType: '',
    updateTime: '',
    createTime: '',
    mobileVerifyTime: '',
    emailVerifyTime: '',
    mobileVerified: false,
    emailVerified: false,
  );
}

@JsonSerializable(
  explicitToJson: true,
)
class UserModel {
  String    id;
  int       status;
  String    loginId;
  String    loginType;  // 로그인 방식 ('', 'phone'..)
  String    nickName;
  String    pic;
  String    message;
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

  List<String>?       likeGroup;
  List<String>?       likePlace;
  List<String>?       likeEvent;
  List<String>?       likeUser;
  List<DescData>?     snsData;
  List<OptionData>?   optionData;
  List<OptionData>?   optionPush;

  UserModel({
    required this.id,
    required this.status,
    required this.loginId,
    required this.loginType,
    required this.nickName,
    required this.pic,
    required this.message,
    required this.birthYear,
    required this.gender,
    required this.mobile,
    required this.mobileIntl,
    required this.email,
    required this.country,
    required this.countryState,
    required this.followCount,
    required this.followerCount,
    required this.pushToken,
    required this.deviceType,
    required this.updateTime,
    required this.createTime,
    required this.mobileVerifyTime,
    required this.emailVerifyTime,
    required this.mobileVerified,
    required this.emailVerified,

    this.likeGroup,
    this.likePlace,
    this.likeEvent,
    this.likeUser,
    this.snsData,
    this.optionData,
    this.optionPush,
  });

  factory UserModel.fromJson(JSON json) => _$UserModelFromJson(json);
  JSON toJson() => _$UserModelToJson(this);

  checkOwner(userId) {
    return id == userId;
  }

  //------------------------------------------------------------------------------------------------------
  //  TimeData
  //

  get getSnsDataMap {
    JSON result = {};
    if (snsData != null) {
      for (var item in snsData!) {
        result[item.id] = item.toJson();
      }
    }
    return result;
  }

}

