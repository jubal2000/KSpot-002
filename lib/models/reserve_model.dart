
import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
part 'reserve_model.g.dart';


@JsonSerializable()
class ReserveData {
  String id;
  int    status;        // item status: 0:removed 1:active
  String reserveStatus; // request, cancel, confirm, reject, close
  String desc;
  int    peoples;
  double price;
  double priceTotal;    // price * peoples
  String currency;
  String targetId;
  String targetType;    // event, place...
  String targetTitle;
  String targetDate;
  String userId;        // request user id
  String userName;
  String userPic;
  DateTime updateTime;
  DateTime createTime;
  String? confirmId;     // confirm user id
  String? confirmDesc;
  DateTime? confirmTime;
  ReserveData({
    required this.id,
    required this.status,
    required this.reserveStatus,
    required this.desc,
    required this.peoples,
    required this.price,
    required this.priceTotal,
    required this.currency,
    required this.targetId,
    required this.targetType,
    required this.targetTitle,
    required this.targetDate,
    required this.userId,
    required this.userName,
    required this.userPic,
    required this.updateTime,
    required this.createTime,

    this.confirmId,
    this.confirmDesc,
    this.confirmTime,
  });
  factory ReserveData.fromJson(JSON json) => _$ReserveDataFromJson(json);
  JSON toJson() => _$ReserveDataToJson(this);
}
