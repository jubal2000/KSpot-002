import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
import 'etc_model.dart';

part 'place_model.g.dart';

class PlaceModelEx extends PlaceModel {
  PlaceModelEx.empty(String id) : super(
    id: id,
    status: 0,
    title: '',
    titleKr: '',
    desc: '',
    descKr: '',
    pic: '',
    groupId: '',
    userId: '',
    country: '',
    countryState: '',
    address: '',
    address2: '',
    email: '',
    mobile: '',
    updateTime: '',
    createTime: '',

    tagData: [],
    managerData: [],
    searchData: [],
    picData: [],
    optionData: [],
    customData: [],
  );
}


@JsonSerializable()
class PlaceModel {
  String      id;
  int         status;
  String      title;
  String      titleKr;
  String      desc;
  String      descKr;
  String      pic;            // title image
  String      groupId;        // group id
  String      userId;         // create user id
  String      country;        // 국가
  String      countryState;   // 도시
  String      address;        // 주소
  String      address2;       // 상세주소
  String      email;          // 이메일
  String      mobile;         // 전화번호
  String      updateTime;     // update time
  String      createTime;     // create time

  List<String>?        tagData;        // tag
  List<String>?        managerData;    // 관리자 ID 목록
  List<String>?        searchData;     // 검색어 목록
  List<PicData>?       picData;        // 메인 이미지 목록
  List<OptionData>?    optionData;     // 옵션 정보
  List<CustomData>?    customData;     // 사용자 설정 정보

  PlaceModel({
    required this.id,
    required this.status,
    required this.title,
    required this.titleKr,
    required this.desc,
    required this.descKr,
    required this.pic,
    required this.groupId,
    required this.userId,
    required this.country,
    required this.countryState,
    required this.address,
    required this.address2,
    required this.email,
    required this.mobile,
    required this.updateTime,
    required this.createTime,

    this.tagData,
    this.picData,
    this.managerData,
    this.searchData,
    this.optionData,
    this.customData,
  });

  factory PlaceModel.fromJson(JSON json) => _$PlaceModelFromJson(json);
  JSON toJSON() => _$PlaceModelToJson(this);
}
