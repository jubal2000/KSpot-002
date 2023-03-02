import 'dart:typed_data';

import '../utils/utils.dart';

import 'package:json_annotation/json_annotation.dart';
part 'upload_model.g.dart';

@JsonSerializable()
class UploadFileModel {
  String      id;
  int         status;
  String      name;
  int         size;
  String      extension;
  String      thumb;
  String      url;
  String?     path;

  @JsonKey(ignore: true)
  Uint8List?  data;
  @JsonKey(ignore: true)
  Uint8List?  thumbData;

  UploadFileModel({
    required this.id,
    required this.status,
    required this.name,
    required this.size,
    required this.extension,
    required this.thumb,
    required this.url,
    required this.path,

    this.data,
  });

  factory UploadFileModel.fromJson(JSON json) => _$UploadFileModelFromJson(json);
  JSON toJson() => _$UploadFileModelToJson(this);
}
