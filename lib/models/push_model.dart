import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';

part 'push_model.g.dart';

// "android":{
// "ttl":"86400s",
// "notification"{
// "click_action":"OPEN_ACTIVITY_1"
// }
// },
// "apns": {
// "headers": {
// "apns-priority": "5",
// },
// "payload": {
// "aps": {
// "category": "NEW_MESSAGE_CATEGORY"
// }
// }

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class PushModel {
  List<String> tokens;
  PushNotificationModel? notification;
  JSON? data;

  PushModel({
    required this.tokens,
    this.notification,
    this.data,
  });

  static create() {
    return PushModel(tokens: []);
  }

  factory PushModel.fromJson(JSON json) => _$PushModelFromJson(json);
  JSON toJson() => _$PushModelToJson(this);
}

@JsonSerializable()
class PushNotificationModel {
  String title;
  String body;

  PushNotificationModel(
    this.title,
    this.body,
  );

  static create() {
    return PushNotificationModel(
        '',
        ''
    );
  }

  factory PushNotificationModel.fromJson(JSON json) => _$PushNotificationModelFromJson(json);
  JSON toJson() => _$PushNotificationModelToJson(this);
}
