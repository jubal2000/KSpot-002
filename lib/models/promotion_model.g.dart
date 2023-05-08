// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromotionModel _$PromotionModelFromJson(Map<String, dynamic> json) =>
    PromotionModel(
      id: json['id'] as String,
      status: json['status'] as int,
      type: json['type'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
      title: json['title'] as String?,
      titleKr: json['titleKr'] as String?,
      desc: json['desc'] as String?,
      descKr: json['descKr'] as String?,
      pic: json['pic'] as String?,
      picThumb: json['picThumb'] as String?,
      picType: json['picType'] as String?,
      picWidth: (json['picWidth'] as num?)?.toDouble(),
      picHeight: (json['picHeight'] as num?)?.toDouble(),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      priceSale: (json['priceSale'] as num?)?.toDouble(),
      priceTax: (json['priceTax'] as num?)?.toDouble(),
      priceTotal: (json['priceTotal'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      targetType: json['targetType'] as String?,
      targetId: json['targetId'] as String?,
      targetGroupId: json['targetGroupId'] as String?,
      targetTitle: json['targetTitle'] as String?,
      targetPic: json['targetPic'] as String?,
    );

Map<String, dynamic> _$PromotionModelToJson(PromotionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'type': instance.type,
      'title': instance.title,
      'titleKr': instance.titleKr,
      'desc': instance.desc,
      'descKr': instance.descKr,
      'pic': instance.pic,
      'picThumb': instance.picThumb,
      'picType': instance.picType,
      'picWidth': instance.picWidth,
      'picHeight': instance.picHeight,
      'userId': instance.userId,
      'userName': instance.userName,
      'phone': instance.phone,
      'email': instance.email,
      'price': instance.price,
      'priceSale': instance.priceSale,
      'priceTax': instance.priceTax,
      'priceTotal': instance.priceTotal,
      'currency': instance.currency,
      'targetType': instance.targetType,
      'targetGroupId': instance.targetGroupId,
      'targetId': instance.targetId,
      'targetTitle': instance.targetTitle,
      'targetPic': instance.targetPic,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
    };
