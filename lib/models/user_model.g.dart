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
      pic: json['pic'] as String,
      message: json['message'] as String,
      birthYear: json['birthYear'] as int,
      gender: json['gender'] as String,
      mobile: json['mobile'] as String,
      mobileIntl: json['mobileIntl'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      followCount: json['followCount'] as int,
      followerCount: json['followerCount'] as int,
      pushToken: json['pushToken'] as String,
      deviceType: json['deviceType'] as String,
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      mobileVerifyTime: json['mobileVerifyTime'] as String,
      emailVerifyTime: json['emailVerifyTime'] as String,
      mobileVerified: json['mobileVerified'] as bool,
      emailVerified: json['emailVerified'] as bool,
      likeGroup: (json['likeGroup'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      likePlace: (json['likePlace'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      likeEvent: (json['likeEvent'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      likeUser: (json['likeUser'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      optionData: (json['optionData'] as List<dynamic>?)
          ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      optionPush: (json['optionPush'] as List<dynamic>?)
          ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'loginId': instance.loginId,
      'loginType': instance.loginType,
      'nickName': instance.nickName,
      'pic': instance.pic,
      'message': instance.message,
      'birthYear': instance.birthYear,
      'gender': instance.gender,
      'mobile': instance.mobile,
      'mobileIntl': instance.mobileIntl,
      'email': instance.email,
      'country': instance.country,
      'countryState': instance.countryState,
      'followCount': instance.followCount,
      'followerCount': instance.followerCount,
      'pushToken': instance.pushToken,
      'deviceType': instance.deviceType,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'mobileVerifyTime': instance.mobileVerifyTime,
      'emailVerifyTime': instance.emailVerifyTime,
      'mobileVerified': instance.mobileVerified,
      'emailVerified': instance.emailVerified,
      'likeGroup': instance.likeGroup,
      'likePlace': instance.likePlace,
      'likeEvent': instance.likeEvent,
      'likeUser': instance.likeUser,
      'optionData': instance.optionData?.map((e) => e.toJson()).toList(),
      'optionPush': instance.optionPush?.map((e) => e.toJson()).toList(),
    };
