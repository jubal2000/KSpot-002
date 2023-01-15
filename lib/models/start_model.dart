import 'package:get/get.dart';
import '../core/utils.dart';

import 'package:json_annotation/json_annotation.dart';
part 'start_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class StartModel {
  String      id;
  int         infoVersion;
  String      androidVersion;
  bool        androidUpdate;
  String      iosVersion;
  bool        iosUpdate;
  StartModel({
    required this.id,
    required this.infoVersion,
    required this.androidVersion,
    required this.androidUpdate,
    required this.iosVersion,
    required this.iosUpdate,
  });

  factory StartModel.fromJson(JSON json) => _$StartModelFromJson(json);
  JSON toJSON() => _$StartModelToJson(this);
}
