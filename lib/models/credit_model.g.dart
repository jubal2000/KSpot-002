// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditModel _$CreditModelFromJson(Map<String, dynamic> json) => CreditModel(
      id: json['id'] as String,
      status: json['status'] as int,
      androidId: json['androidId'] as String,
      iosId: json['iosId'] as String,
      title: json['title'] as String,
      desc: json['desc'] as String,
      amount: (json['amount'] as num).toDouble(),
      quantity: json['quantity'] as int,
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$CreditModelToJson(CreditModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'androidId': instance.androidId,
      'iosId': instance.iosId,
      'title': instance.title,
      'desc': instance.desc,
      'amount': instance.amount,
      'quantity': instance.quantity,
      'currency': instance.currency,
    };
