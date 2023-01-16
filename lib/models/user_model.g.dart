// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: json['userId'] as String,
      loginId: json['loginId'] as String,
      nickName: json['nickName'] as String,
      pic: json['pic'] as String,
      birthYear: json['birthYear'] as int,
      gender: json['gender'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      updateTime: json['updateTime'] as String? ?? '',
      createTime: json['createTime'] as String? ?? '',
      mobileCheck: json['mobileCheck'] as bool? ?? false,
      emailCheck: json['emailCheck'] as bool? ?? false,
      countrySelectList: (json['countrySelectList'] as List<dynamic>?)
              ?.map((e) => CountryData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'userId': instance.userId,
      'loginId': instance.loginId,
      'nickName': instance.nickName,
      'pic': instance.pic,
      'birthYear': instance.birthYear,
      'gender': instance.gender,
      'mobile': instance.mobile,
      'email': instance.email,
      'country': instance.country,
      'countryState': instance.countryState,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'mobileCheck': instance.mobileCheck,
      'emailCheck': instance.emailCheck,
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
