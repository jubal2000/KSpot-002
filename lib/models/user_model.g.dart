// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: json['userId'] as String,
      status: json['status'] as int? ?? 0,
      loginId: json['loginId'] as String? ?? '',
      loginType: json['loginType'] as String? ?? '',
      nickName: json['nickName'] as String? ?? '',
      pic: json['pic'] as String? ?? '',
      birthYear: json['birthYear'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      mobileIntl: json['mobileIntl'] as String? ?? '',
      email: json['email'] as String? ?? '',
      country: json['country'] as String? ?? '',
      countryState: json['countryState'] as String? ?? '',
      pushToken: json['pushToken'] as String? ?? '',
      deviceType: json['deviceType'] as String? ?? '',
      updateTime: json['updateTime'] as String? ?? '',
      createTime: json['createTime'] as String? ?? '',
      mobileVerifyTime: json['mobileVerifyTime'] as String? ?? '',
      emailVerifyTime: json['emailVerifyTime'] as String? ?? '',
      mobileVerified: json['mobileVerified'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      optionData: (json['optionData'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, OptionData.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      optionPush: (json['optionPush'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, OptionData.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      countrySelectList: (json['countrySelectList'] as List<dynamic>?)
              ?.map((e) => CountryData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'userId': instance.userId,
      'status': instance.status,
      'loginId': instance.loginId,
      'loginType': instance.loginType,
      'nickName': instance.nickName,
      'pic': instance.pic,
      'birthYear': instance.birthYear,
      'gender': instance.gender,
      'mobile': instance.mobile,
      'mobileIntl': instance.mobileIntl,
      'email': instance.email,
      'country': instance.country,
      'countryState': instance.countryState,
      'pushToken': instance.pushToken,
      'deviceType': instance.deviceType,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'mobileVerifyTime': instance.mobileVerifyTime,
      'emailVerifyTime': instance.emailVerifyTime,
      'mobileVerified': instance.mobileVerified,
      'emailVerified': instance.emailVerified,
      'optionData': instance.optionData,
      'optionPush': instance.optionPush,
      'countrySelectList': instance.countrySelectList,
    };

CountryData _$CountryDataFromJson(Map<String, dynamic> json) => CountryData(
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      countryFlag: json['countryFlag'] as String,
      createTime: json['createTime'] as String,
    );

Map<String, dynamic> _$CountryDataToJson(CountryData instance) =>
    <String, dynamic>{
      'country': instance.country,
      'countryState': instance.countryState,
      'countryFlag': instance.countryFlag,
      'createTime': instance.createTime,
    };

OptionData _$OptionDataFromJson(Map<String, dynamic> json) => OptionData(
      id: json['id'],
      value: json['value'],
    );

Map<String, dynamic> _$OptionDataToJson(OptionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
    };
