// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etc_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeData _$TimeDataFromJson(Map<String, dynamic> json) => TimeData(
      id: json['id'] as String,
      status: json['status'] as int,
      type: json['type'] as int,
      title: json['title'] as String,
      desc: json['desc'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      index: json['index'] as int,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      day: (json['day'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dayWeek:
          (json['dayWeek'] as List<dynamic>?)?.map((e) => e as String).toList(),
      week: (json['week'] as List<dynamic>?)?.map((e) => e as String).toList(),
      exceptDay: (json['exceptDay'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      customData: json['customData'] as List<dynamic>?,
    );

Map<String, dynamic> _$TimeDataToJson(TimeData instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'type': instance.type,
      'title': instance.title,
      'desc': instance.desc,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'index': instance.index,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'day': instance.day,
      'dayWeek': instance.dayWeek,
      'week': instance.week,
      'exceptDay': instance.exceptDay,
      'customData': instance.customData,
    };

PromotionData _$PromotionDataFromJson(Map<String, dynamic> json) =>
    PromotionData(
      id: json['id'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      typeId: json['typeId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPic: json['userPic'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$PromotionDataToJson(PromotionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'typeId': instance.typeId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPic': instance.userPic,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'updateTime': instance.updateTime.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
    };

CustomData _$CustomDataFromJson(Map<String, dynamic> json) => CustomData(
      id: json['id'] as String,
      title: json['title'] as String,
      customId: json['customId'] as String,
      parentId: json['parentId'] as String,
      desc: json['desc'] as String?,
      url: json['url'] as String?,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$CustomDataToJson(CustomData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'customId': instance.customId,
      'parentId': instance.parentId,
      'desc': instance.desc,
      'url': instance.url,
      'data': instance.data,
    };

PicData _$PicDataFromJson(Map<String, dynamic> json) => PicData(
      id: json['id'] as String,
      type: json['type'] as int,
      url: json['url'] as String,
    );

Map<String, dynamic> _$PicDataToJson(PicData instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'url': instance.url,
    };

CountryData _$CountryDataFromJson(Map<String, dynamic> json) => CountryData(
      country: json['country'] as String,
      countryState: json['countryState'] as String,
      countryFlag: json['countryFlag'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$CountryDataToJson(CountryData instance) =>
    <String, dynamic>{
      'country': instance.country,
      'countryState': instance.countryState,
      'countryFlag': instance.countryFlag,
      'createTime': instance.createTime.toIso8601String(),
    };

OptionData _$OptionDataFromJson(Map<String, dynamic> json) => OptionData(
      id: json['id'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$OptionDataToJson(OptionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
    };

BankData _$BankDataFromJson(Map<String, dynamic> json) => BankData(
      id: json['id'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      name: json['name'] as String,
      account: json['account'] as String,
      author: json['author'] as String,
    );

Map<String, dynamic> _$BankDataToJson(BankData instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'title': instance.title,
      'name': instance.name,
      'account': instance.account,
      'author': instance.author,
    };

AddressData _$AddressDataFromJson(Map<String, dynamic> json) => AddressData(
      address1: json['address1'] as String,
      address2: json['address2'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      postCode: json['postCode'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$AddressDataToJson(AddressData instance) =>
    <String, dynamic>{
      'address1': instance.address1,
      'address2': instance.address2,
      'lat': instance.lat,
      'lng': instance.lng,
      'postCode': instance.postCode,
      'country': instance.country,
      'city': instance.city,
    };

MemberData _$MemberDataFromJson(Map<String, dynamic> json) => MemberData(
      id: json['id'] as String,
      status: json['status'] as int,
      nickName: json['nickName'] as String,
      pic: json['pic'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$MemberDataToJson(MemberData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'nickName': instance.nickName,
      'pic': instance.pic,
      'createTime': instance.createTime.toIso8601String(),
    };

RecommendData _$RecommendDataFromJson(Map<String, dynamic> json) =>
    RecommendData(
      id: json['id'] as String,
      showStatus: json['showStatus'] as int,
      creditQty: json['creditQty'] as int,
      desc: json['desc'] as String,
      userId: json['userId'] as String,
      userPic: json['userPic'] as String,
      userName: json['userName'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );

Map<String, dynamic> _$RecommendDataToJson(RecommendData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'showStatus': instance.showStatus,
      'creditQty': instance.creditQty,
      'desc': instance.desc,
      'userId': instance.userId,
      'userPic': instance.userPic,
      'userName': instance.userName,
      'createTime': instance.createTime.toIso8601String(),
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
    };

DescData _$DescDataFromJson(Map<String, dynamic> json) => DescData(
      id: json['id'] as String,
      desc: json['desc'] as String,
    );

Map<String, dynamic> _$DescDataToJson(DescData instance) => <String, dynamic>{
      'id': instance.id,
      'desc': instance.desc,
    };

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) => NoticeModel(
      id: json['id'] as String,
      status: json['status'] as int,
      index: json['index'] as int,
      desc: json['desc'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      fileData: (json['fileData'] as List<dynamic>?)
          ?.map((e) => UploadFileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'index': instance.index,
      'desc': instance.desc,
      'userId': instance.userId,
      'userName': instance.userName,
      'createTime': instance.createTime.toIso8601String(),
      'fileData': instance.fileData?.map((e) => e.toJson()).toList(),
    };

BanData _$BanDataFromJson(Map<String, dynamic> json) => BanData(
      id: json['id'] as String,
      nickName: json['nickName'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$BanDataToJson(BanData instance) => <String, dynamic>{
      'id': instance.id,
      'nickName': instance.nickName,
      'createTime': instance.createTime.toIso8601String(),
    };
