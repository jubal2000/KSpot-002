// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushModel _$PushModelFromJson(Map<String, dynamic> json) => PushModel(
      notification: PushNotificationModel.fromJson(
          json['notification'] as Map<String, dynamic>),
      tokens:
          (json['tokens'] as List<dynamic>).map((e) => e as String).toList(),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PushModelToJson(PushModel instance) => <String, dynamic>{
      'notification': instance.notification.toJson(),
      'tokens': instance.tokens,
      'data': instance.data,
    };

PushNotificationModel _$PushNotificationModelFromJson(
        Map<String, dynamic> json) =>
    PushNotificationModel(
      title: json['title'] as String,
      body: json['body'] as String,
    );

Map<String, dynamic> _$PushNotificationModelToJson(
        PushNotificationModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
    };
