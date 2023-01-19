// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartModel _$StartModelFromJson(Map<String, dynamic> json) => StartModel(
      id: json['id'] as String,
      title: json['title'] as String,
      serverStatus: json['serverStatus'] as int,
      serverStatusMsg: json['serverStatusMsg'] as String,
      infoVersion: json['infoVersion'] as int,
      promotionInfo:
          ServiceData.fromJson(json['promotionInfo'] as Map<String, dynamic>),
      serviceInfo:
          ServiceData.fromJson(json['serviceInfo'] as Map<String, dynamic>),
      appVersion: (json['appVersion'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, VersionData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$StartModelToJson(StartModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'serverStatus': instance.serverStatus,
      'serverStatusMsg': instance.serverStatusMsg,
      'infoVersion': instance.infoVersion,
      'promotionInfo': instance.promotionInfo,
      'serviceInfo': instance.serviceInfo,
      'appVersion': instance.appVersion,
    };

VersionData _$VersionDataFromJson(Map<String, dynamic> json) => VersionData(
      id: json['id'] as String,
      type: json['type'] as int,
      message: json['message'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$VersionDataToJson(VersionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'message': instance.message,
      'version': instance.version,
    };

ServiceData _$ServiceDataFromJson(Map<String, dynamic> json) => ServiceData(
      bankAccount: json['bankAccount'] as String,
      bankTitle: json['bankTitle'] as String,
      cancelDesc: json['cancelDesc'] as String,
      serviceEmail: json['serviceEmail'] as String,
      servicePhone: json['servicePhone'] as String,
      serviceUserId: json['serviceUserId'] as String,
      serviceUserName: json['serviceUserName'] as String,
      tax: json['tax'] as String,
    );

Map<String, dynamic> _$ServiceDataToJson(ServiceData instance) =>
    <String, dynamic>{
      'bankAccount': instance.bankAccount,
      'bankTitle': instance.bankTitle,
      'cancelDesc': instance.cancelDesc,
      'serviceEmail': instance.serviceEmail,
      'servicePhone': instance.servicePhone,
      'serviceUserId': instance.serviceUserId,
      'serviceUserName': instance.serviceUserName,
      'tax': instance.tax,
    };
