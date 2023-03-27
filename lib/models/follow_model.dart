import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
part 'follow_model.g.dart';

@JsonSerializable()
class FollowModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String  targetId;
  String  targetName;
  String  targetPic;
  String  userId;
  String  userName;
  String  userPic;
  DateTime  createTime;     // 생성 시간

  FollowModel({
    required this.id,
    required this.status,
    required this.targetId,
    required this.targetName,
    required this.targetPic,
    required this.userId,
    required this.userName,
    required this.userPic,
    required this.createTime,
  });
  factory FollowModel.fromJson(JSON json) => _$FollowModelFromJson(json);
  JSON toJson() => _$FollowModelToJson(this);
}