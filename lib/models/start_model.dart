import 'package:get/get.dart';
import '../utils/utils.dart';

import 'package:json_annotation/json_annotation.dart';
part 'start_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class StartModel {
  String      id;
  String      title;
  int         serverStatus;
  String      serverStatusMsg;
  int         infoVersion;
  ServiceData promotionInfo;
  ServiceData serviceInfo;
  Map<String, VersionData> appVersion;
  StartModel({
    required this.id,
    required this.title,
    required this.serverStatus,
    required this.serverStatusMsg,
    required this.infoVersion,
    required this.promotionInfo,
    required this.serviceInfo,
    required this.appVersion,
  });

  factory StartModel.fromJson(JSON json) => _$StartModelFromJson(json);
  JSON toJson() => _$StartModelToJson(this);
}

@JsonSerializable()
class VersionData {
  String      id;
  int         type;
  String      message;
  String      version;
  VersionData({
    required this.id,
    required this.type,
    required this.message,
    required this.version,
  });

  factory VersionData.fromJson(JSON json) => _$VersionDataFromJson(json);
  JSON toJson() => _$VersionDataToJson(this);
}

@JsonSerializable()
class ServiceData {
  String      bankAccount;
  String      bankTitle;
  String      cancelDesc;
  String      serviceEmail;
  String      servicePhone;
  String      serviceUserId;
  String      serviceUserName;
  String      tax;
  ServiceData({
    required this.bankAccount,
    required this.bankTitle,
    required this.cancelDesc,
    required this.serviceEmail,
    required this.servicePhone,
    required this.serviceUserId,
    required this.serviceUserName,
    required this.tax
  });

  factory ServiceData.fromJson(JSON json) => _$ServiceDataFromJson(json);
  JSON toJson() => _$ServiceDataToJson(this);
}
