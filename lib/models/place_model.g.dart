// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceModel _$PlaceModelFromJson(Map<String, dynamic> json) => PlaceModel(
      id: json['id'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      titleKr: json['titleKr'] as String?,
      desc: json['desc'] as String,
      descKr: json['descKr'] as String?,
      pic: json['pic'] as String,
      themeColor: json['themeColor'] as String?,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      address: AddressData.fromJson(json['address'] as Map<String, dynamic>),
      email: json['email'] as String,
      updateTime: DateTime.parse(json['updateTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
      phoneData: (json['phoneData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      picData: (json['picData'] as List<dynamic>?)
          ?.map((e) => PicData.fromJson(e as Map<String, dynamic>))
          .toList(),
      managerData: (json['managerData'] as List<dynamic>?)
          ?.map((e) => MemberData.fromJson(e as Map<String, dynamic>))
          .toList(),
      optionData: (json['optionData'] as List<dynamic>?)
          ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      tagData:
          (json['tagData'] as List<dynamic>?)?.map((e) => e as String).toList(),
    )..customData = (json['customData'] as List<dynamic>?)
        ?.map((e) => CustomData.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$PlaceModelToJson(PlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'titleKr': instance.titleKr,
      'desc': instance.desc,
      'descKr': instance.descKr,
      'pic': instance.pic,
      'themeColor': instance.themeColor,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'country': instance.country,
      'countryState': instance.countryState,
      'address': instance.address.toJson(),
      'email': instance.email,
      'updateTime': instance.updateTime.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
      'phoneData': instance.phoneData,
      'picData': instance.picData?.map((e) => e.toJson()).toList(),
      'managerData': instance.managerData?.map((e) => e.toJson()).toList(),
      'customData': instance.customData?.map((e) => e.toJson()).toList(),
      'optionData': instance.optionData?.map((e) => e.toJson()).toList(),
      'tagData': instance.tagData,
    };
