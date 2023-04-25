// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      status: json['status'] as int,
      loginId: json['loginId'] as String,
      loginType: json['loginType'] as String,
      nickName: json['nickName'] as String,
      realName: json['realName'] as String? ?? '',
      pic: json['pic'] as String,
      message: json['message'] as String,
      birthYear: json['birthYear'] as int,
      gender: json['gender'] as String,
      mobile: json['mobile'] as String,
      mobileIntl: json['mobileIntl'] as String,
      mobileShow: json['mobileShow'] as int? ?? 0,
      mobileVerifyTime: json['mobileVerifyTime'] as String,
      email: json['email'] as String,
      emailShow: json['emailShow'] as int? ?? 0,
      emailVerifyTime: json['emailVerifyTime'] as String,
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      followCount: json['followCount'] as int? ?? 0,
      followerCount: json['followerCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      creditCount: json['creditCount'] as int? ?? 0,
      pushToken: json['pushToken'] as String,
      deviceType: json['deviceType'] as String,
      updateTime: DateTime.parse(json['updateTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
      backPic: json['backPic'] as String?,
      emailNew: json['emailNew'] as String?,
      snsData: (json['snsData'] as List<dynamic>?)
          ?.map((e) => DescData.fromJson(e as Map<String, dynamic>))
          .toList(),
      optionData: (json['optionData'] as List<dynamic>?)
          ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      optionPush: (json['optionPush'] as List<dynamic>?)
          ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..refundBank = json['refundBank'] == null
        ? null
        : BankData.fromJson(json['refundBank'] as Map<String, dynamic>);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'loginId': instance.loginId,
      'loginType': instance.loginType,
      'nickName': instance.nickName,
      'realName': instance.realName,
      'pic': instance.pic,
      'backPic': instance.backPic,
      'message': instance.message,
      'birthYear': instance.birthYear,
      'gender': instance.gender,
      'mobile': instance.mobile,
      'mobileIntl': instance.mobileIntl,
      'mobileShow': instance.mobileShow,
      'mobileVerifyTime': instance.mobileVerifyTime,
      'email': instance.email,
      'emailShow': instance.emailShow,
      'emailVerifyTime': instance.emailVerifyTime,
      'country': instance.country,
      'countryState': instance.countryState,
      'followCount': instance.followCount,
      'followerCount': instance.followerCount,
      'likeCount': instance.likeCount,
      'creditCount': instance.creditCount,
      'pushToken': instance.pushToken,
      'deviceType': instance.deviceType,
      'updateTime': instance.updateTime.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
      'emailNew': instance.emailNew,
      'refundBank': instance.refundBank?.toJson(),
      'snsData': instance.snsData?.map((e) => e.toJson()).toList(),
      'optionData': instance.optionData?.map((e) => e.toJson()).toList(),
      'optionPush': instance.optionPush?.map((e) => e.toJson()).toList(),
    };
