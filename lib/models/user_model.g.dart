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
      updateTime: json['updateTime'] as String? ?? '',
      createTime: json['createTime'] as String? ?? '',
      mobileCheck: json['mobileCheck'] as bool? ?? false,
      emailCheck: json['emailCheck'] as bool? ?? false,
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
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'mobileCheck': instance.mobileCheck,
      'emailCheck': instance.emailCheck,
    };
