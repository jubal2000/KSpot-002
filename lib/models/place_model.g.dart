// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceModel _$PlaceModelFromJson(Map<String, dynamic> json) => PlaceModel(
      id: json['id'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      titleKr: json['titleKr'] as String,
      desc: json['desc'] as String,
      descKr: json['descKr'] as String,
      pic: json['pic'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      address: AddressData.fromJson(json['address'] as Map<String, dynamic>),
      email: json['email'] as String,
      updateTime: json['updateTime'] as String,
      createTime: json['createTime'] as String,
      tagData:
          (json['tagData'] as List<dynamic>?)?.map((e) => e as String).toList(),
      picData: (json['picData'] as List<dynamic>?)
          ?.map((e) => PicData.fromJson(e as Map<String, dynamic>))
          .toList(),
      managerData: (json['managerData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      searchData: (json['searchData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      phoneData: (json['phoneData'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      optionData: (json['optionData'] as List<dynamic>?)
          ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      customData: (json['customData'] as List<dynamic>?)
          ?.map((e) => CustomData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlaceModelToJson(PlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'titleKr': instance.titleKr,
      'desc': instance.desc,
      'descKr': instance.descKr,
      'pic': instance.pic,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'country': instance.country,
      'countryState': instance.countryState,
      'address': instance.address.toJson(),
      'email': instance.email,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'tagData': instance.tagData,
      'managerData': instance.managerData,
      'searchData': instance.searchData,
      'phoneData': instance.phoneData,
      'picData': instance.picData?.map((e) => e.toJson()).toList(),
      'optionData': instance.optionData?.map((e) => e.toJson()).toList(),
      'customData': instance.customData?.map((e) => e.toJson()).toList(),
    };
