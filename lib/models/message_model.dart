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
  DateTime  updateTime;     // 수정 시간
  DateTime  createTime;     // 생성 시간

  List<String>? picData;
  List<String>? openTimeData; // 읽은 시간

  @JsonKey(includeFromJson: false)
  DateTime? cacheTime;    // for local cache refresh time..

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

    this.picData,
    this.openTimeData,
  });
  factory MessageModel.fromJson(JSON json) => _$MessageModelFromJson(json);
  JSON toJson() => _$MessageModelToJson(this);
}

@JsonSerializable()
class MessageGroupModel {
  String  id;
  String  lastMessage;
  String  userId;
  String  userName;
  String  userPic;
  String  updateTime;     // 수신 시간

  @JsonKey(includeFromJson: false)
  DateTime? cacheTime;    // for local cache refresh time..

  MessageGroupModel({
    required this.id,
    required this.lastMessage,
    required this.userId,
    required this.userName,
    required this.userPic,
    required this.updateTime,
  });
  factory MessageGroupModel.fromJson(JSON json) => _$MessageGroupModelFromJson(json);
  JSON toJson() => _$MessageGroupModelToJson(this);
}