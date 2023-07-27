// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushModel _$PushModelFromJson(Map<String, dynamic> json) => PushModel(
      tokens:
          (json['tokens'] as List<dynamic>).map((e) => e as String).toList(),
      notification: json['notification'] == null
          ? null
          : PushNotificationModel.fromJson(
              json['notification'] as Map<String, dynamic>),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PushModelToJson(PushModel instance) {
  final val = <String, dynamic>{
    'tokens': instance.tokens,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('notification', instance.notification?.toJson());
  writeNotNull('data', instance.data);
  return val;
}

PushNotificationModel _$PushNotificationModelFromJson(
        Map<String, dynamic> json) =>
    PushNotificationModel(
      json['title'] as String,
      json['body'] as String,
    );

Map<String, dynamic> _$PushNotificationModelToJson(
        PushNotificationModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
    };
