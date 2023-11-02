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
    themeColor: '',
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
    updateTime: DateTime.now(),
    createTime: DateTime.now(),
  );
}


@JsonSerializable(
  explicitToJson: true,
)
class PlaceModel {
  String      id;
  int         status;
  String      title;
  String?     titleKr;
  String      desc;
  String?     descKr;
  String      pic;            // title image
  String?     themeColor;
  String      groupId;        // group id
  String      userId;         // create user id
  String      country;        // 국가
  String      countryState;   // 도시
  AddressData address;       // 주소 정보
  String      email;          // 이메일
  DateTime    updateTime;     // update time
  DateTime    createTime;     // create time

  List<String>?        phoneData;      // 전화번호 목록
  List<PicData>?       picData;        // 메인 이미지 목록
  List<MemberData>?    managerData;    // 관리자 목록
  List<CustomData>?    customData;     // 사용자 설정 정보
  List<OptionData>?    optionData;     // 옵션 정보
  List<String>?        tagData;        // 옵션 정보

  @JsonKey(includeFromJson: false)
  DateTime? cacheTime;    // for local cache refresh time..

  PlaceModel({
    required this.id,
    required this.status,
    required this.title,
    this.titleKr,
    required this.desc,
    this.descKr,
    required this.pic,
    required this.themeColor,
    required this.groupId,
    required this.userId,
    required this.country,
    required this.countryState,
    required this.address,
    required this.email,
    required this.updateTime,
    required this.createTime,

    this.phoneData,
    this.picData,
    this.managerData,
    this.optionData,
    this.tagData,
  });

  factory PlaceModel.fromJson(JSON json) => _$PlaceModelFromJson(json);
  JSON toJson() => _$PlaceModelToJson(this);

  //------------------------------------------------------------------------------------------------------
  //  PicData
  //

  get getPicDataList {
    List<JSON> result = [];
    if (picData != null) {
      for (var item in picData!) {
        result.add(item.toJson());
      }
    }
    return result;
  }

  //------------------------------------------------------------------------------------------------------
  //  ManagerData
  //

  get getManagerDataMap {
    JSON result = {};
    if (managerData != null) {
      for (var item in managerData!) {
        result[item.id] = item.toJson();
      }
    }
    return result;
  }

  removeManagerData(String key) {
    if (managerData != null) {
      for (var item in managerData!) {
        if (item.id.toLowerCase() == key.toLowerCase()) {
          managerData!.remove(item);
          return true;
        }
      }
    }
    return false;
  }

  setManagerDataMap(JSON map) {
    managerData ??= [];
    managerData!.clear();
    if (map.isNotEmpty) {
      for (var item in map.entries) {
        managerData!.add(MemberData.fromJson(item.value));
      }
    }
    return managerData;
  }

  //------------------------------------------------------------------------------------------------------
  //  OptionData
  //

  get getOptionDataMap {
    JSON result = {};
    if (optionData != null) {
      for (var item in optionData!) {
        result[item.id] = item.toJson();
      }
    }
    return result;
  }

  getOptionValue(String key) {
    final optionMap = getOptionDataMap;
    return optionMap[key] != null && optionMap[key]['value'] == '1';
  }

  setOptionDataMap(JSON map) {
    optionData ??= [];
    optionData!.clear();
    if (map.isNotEmpty) {
      for (var item in map.entries) {
        optionData!.add(OptionData(
          id: item.key,
          value: item.value['value'],
        ));
      }
    }
    return optionData;
  }

  //------------------------------------------------------------------------------------------------------
  //  OptionData
  //

  get getCustomDataMap {
    JSON result = {};
    if (customData != null) {
      for (var item in customData!) {
        result[item.id] = item.toJson();
      }
    }
    return result;
  }
}
