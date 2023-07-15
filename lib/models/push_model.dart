import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';

part 'push_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class PushModel {
  PushNotificationModel notification;
  List<String> tokens;
  JSON? data;

  PushModel({
    required this.notification,
    required this.tokens,
    this.data,
  });

  static create() {
    return PushModel(notification: PushNotificationModel.create(), tokens: []);
  }

  factory PushModel.fromJson(JSON json) => _$PushModelFromJson(json);
  JSON toJson() => _$PushModelToJson(this);
}

@JsonSerializable()
class PushNotificationModel {
  String      title;
  String      body;

  PushNotificationModel({
    required this.title,
    required this.body,
  });

  static create() {
    return PushNotificationModel(
      title: '',
      body: ''
    );
  }

  factory PushNotificationModel.fromJson(JSON json) => _$PushNotificationModelFromJson(json);
  JSON toJson() => _$PushNotificationModelToJson(this);
}
