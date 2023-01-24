import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
import 'etc_model.dart';

part 'place_model.g.dart';

class PlaceModelEx extends PlaceModel {
  PlaceModelEx.empty(String id,
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
    groupId: '',
    userId: '',
    country: '',
    countryState: '',
    address: AddressData(
      address1: '',
      address2: '',
      lat: 0.0,
      lng: 0.0,
    ),
    email: '',
    updateTime: '',
    createTime: '',

    tagData: [],
    managerData: [],
    searchData: [],
    phoneData: [],
    picData: [],
    optionData: [],
    customData: [],
  );
}


@JsonSerializable(
  explicitToJson: true,
)
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
  AddressData address;       // 주소 정보
  String      email;          // 이메일
  String      updateTime;     // update time
  String      createTime;     // create time

  List<String>?        tagData;        // tag
  List<String>?        managerData;    // 관리자 ID 목록
  List<String>?        searchData;     // 검색어 목록
  List<String>?        phoneData;      // 전화번호 목록
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
    required this.email,
    required this.updateTime,
    required this.createTime,

    this.tagData,
    this.picData,
    this.managerData,
    this.searchData,
    this.phoneData,
    this.optionData,
    this.customData,
  });

  factory PlaceModel.fromJson(JSON json) => _$PlaceModelFromJson(json);
  JSON toJson() => _$PlaceModelToJson(this);
}
