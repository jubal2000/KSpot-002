import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
import 'etc_model.dart';

part 'credit_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class CreditModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active)
  String  androidId;      // android 구매 상품 ID
  String  iosId;          // ios 구매 상품 ID
  String  title;          // 상품 title
  String  desc;           // 상품 desc
  double  amount;         // 상품 가격
  int     quantity;       // 크래딧 갯수
  String  currency;

  CreditModel({
    required this.id,
    required this.status,
    required this.androidId,
    required this.iosId,
    required this.title,
    required this.desc,
    required this.amount,
    required this.quantity,
    required this.currency,
  });

  factory CreditModel.fromJson(JSON json) => _$CreditModelFromJson(json);
  JSON toJson() => _$CreditModelToJson(this);
}
