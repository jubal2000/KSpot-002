// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => $checkedCreate(
      'UserModel',
      json,
      ($checkedConvert) {
        final val = UserModel(
          userId: $checkedConvert('userId', (v) => v as String),
          nickName: $checkedConvert('nickName', (v) => v as String),
          pic: $checkedConvert('pic', (v) => v as String),
          birthYear: $checkedConvert('birthYear', (v) => v as int),
          gender: $checkedConvert('gender', (v) => v as String),
          mobile: $checkedConvert('mobile', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          updateTime: $checkedConvert('updateTime', (v) => v as String? ?? ''),
          createTime: $checkedConvert('createTime', (v) => v as String? ?? ''),
          mobileCheck:
              $checkedConvert('mobileCheck', (v) => v as bool? ?? false),
          emailCheck: $checkedConvert('emailCheck', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'userId': instance.userId,
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
