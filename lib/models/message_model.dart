import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String  desc;
  String  targetId;
  String  targetName;
  String  targetPic;
  String  senderId;
  String  senderName;
  String  senderPic;
  String  updateTime;     // 수정 시간
  String  createTime;     // 생성 시간

  List<String>? imageData;

  MessageModel({
    required this.id,
    required this.status,
    required this.desc,
    required this.targetId,
    required this.targetName,
    required this.targetPic,
    required this.senderId,
    required this.senderName,
    required this.senderPic,
    required this.updateTime,
    required this.createTime,

    this.imageData,
  });
  factory MessageModel.fromJson(JSON json) => _$MessageModelFromJson(json);
  JSON toJson() => _$MessageModelToJson(this);
}