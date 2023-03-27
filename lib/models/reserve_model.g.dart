// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reserve_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReserveData _$ReserveDataFromJson(Map<String, dynamic> json) => ReserveData(
      id: json['id'] as String,
      status: json['status'] as int,
      reserveStatus: json['reserveStatus'] as String,
      desc: json['desc'] as String,
      peoples: json['peoples'] as int,
      price: (json['price'] as num).toDouble(),
      priceTotal: (json['priceTotal'] as num).toDouble(),
      currency: json['currency'] as String,
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      targetTitle: json['targetTitle'] as String,
      targetDate: json['targetDate'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPic: json['userPic'] as String,
      updateTime: DateTime.parse(json['updateTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
      confirmId: json['confirmId'] as String?,
      confirmDesc: json['confirmDesc'] as String?,
      confirmTime: json['confirmTime'] == null
          ? null
          : DateTime.parse(json['confirmTime'] as String),
    );

Map<String, dynamic> _$ReserveDataToJson(ReserveData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'reserveStatus': instance.reserveStatus,
      'desc': instance.desc,
      'peoples': instance.peoples,
      'price': instance.price,
      'priceTotal': instance.priceTotal,
      'currency': instance.currency,
      'targetId': instance.targetId,
      'targetType': instance.targetType,
      'targetTitle': instance.targetTitle,
      'targetDate': instance.targetDate,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPic': instance.userPic,
      'updateTime': instance.updateTime.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
      'confirmId': instance.confirmId,
      'confirmDesc': instance.confirmDesc,
      'confirmTime': instance.confirmTime?.toIso8601String(),
    };
