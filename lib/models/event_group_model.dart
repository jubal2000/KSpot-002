import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';

part 'event_group_model.g.dart';

class EventGroupModelEx extends EventGroupModel {
  EventGroupModelEx.empty(String id,
      {
        var title = '',
        var desc = '',
      }) : super(
    id: id,
    status: 0,
    title: title,
    titleKr: '',
    desc: desc,
    descKr: '',
    pic: '',
    contentType: '',
    updateTime: DateTime(0),
    createTime: DateTime(0),

    tagData: [],
    searchData: [],
  );
}


@JsonSerializable()
class EventGroupModel {
  String    id;
  int       status;
  String    title;
  String    titleKr;
  String    desc;
  String    descKr;
  String    pic;            // title image
  String    contentType;    // content type id
  DateTime  updateTime;     // update time
  DateTime  createTime;     // create time

  List<String>? tagData;      // tag
  List<String>? searchData;   // 검색어 목록

  EventGroupModel({
    required this.id,
    required this.status,
    required this.title,
    required this.titleKr,
    required this.desc,
    required this.descKr,
    required this.pic,
    required this.contentType,
    required this.updateTime,
    required this.createTime,

    this.tagData,
    this.searchData,
  });

  factory EventGroupModel.fromJson(JSON json) => _$EventGroupModelFromJson(json);
  JSON toJson() => _$EventGroupModelToJson(this);
}
