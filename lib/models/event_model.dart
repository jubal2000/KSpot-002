import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
part 'event_model.g.dart';

class EventModeEx extends EventModel {
  EventModeEx.empty(
      String id,
      {
        int    status = 0,
        String title = '',
        String desc = '',
        String pic = '',
        String groupId = '',
        String placeId = '',
        double enterFee = 0,
        String reserveFee = '',
        String currency = '',
        String country = '',
        String countryState = '',
        String userId = '',
        int reservePeriod = 0,
        int likeCount = 0,
        int voteCount = 0,
        int commentCount = 0,
        String updateTime = '',
        String createTime = '',

        List<String>? tagData,
        List<String>? managerData,
        List<String>? searchData,
        List<PicData>? picData,
        List<TimeData>? timeData,
        List<OptionData>? optionData,
        List<PromotionData>? promotionData,
      }) : super(
        id: id,
        status: status,
        title: title,
        desc: desc,
        pic: pic,
        groupId: groupId,
        placeId: placeId,
        enterFee: enterFee,
        reserveFee: reserveFee,
        currency: currency,
        country: country,
        countryState: countryState,
        userId: userId,
        reservePeriod: reservePeriod,
        likeCount: likeCount,
        voteCount: voteCount,
        commentCount: commentCount,
        updateTime: updateTime,
        createTime: createTime,

        tagData: [],
        managerData: [],
        searchData: [],
        picData: [],
        timeData: [],
        optionData: [],
        promotionData: [],
      );
}

@JsonSerializable()
class EventModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String  title;
  String  desc;
  String  pic;            // 대표 이미지 (Small Size)
  String  groupId;        // 그룹 ID
  String  placeId;        // 장소 ID
  double  enterFee;       // 현장 입장료
  String  reserveFee;     // 예매 입장료
  String  currency;       // 통화단위 (KRW, USD..)
  String  country;        // 국가
  String  countryState;   // 도시
  String  userId;         // 소유 유저
  int     reservePeriod;  // 예약 기간 (0:예약불가)
  int     likeCount;      // 종아요 횟수
  int     voteCount;      // 추천 횟수
  int     commentCount;   // 댓글 갯수
  String  updateTime;     // 수정 시간
  String  createTime;     // 생성 시간

  List<String>        tagData;        // tag
  List<String>        managerData;    // 관리자 ID 목록
  List<String>        searchData;     // 검색어 목록
  List<PicData>       picData;        // 메인 이미지 목록
  List<TimeData>      timeData;       // 시간 정보 목록
  List<OptionData>    optionData;     // 옵션 정보
  List<PromotionData> promotionData;  // 광고설정 정보

  EventModel({
    required this.id,
    required this.status,
    required this.title,
    required this.desc,
    required this.pic,
    required this.groupId,
    required this.placeId,
    required this.enterFee,
    required this.reserveFee,
    required this.currency,
    required this.country,
    required this.countryState,
    required this.userId,
    required this.reservePeriod,
    required this.likeCount,
    required this.voteCount,
    required this.commentCount,

    required this.updateTime,
    required this.createTime,

    required this.tagData,
    required this.picData,
    required this.managerData,
    required this.searchData,
    required this.timeData,
    required this.optionData,
    required this.promotionData,
  });
  factory EventModel.fromJson(JSON json) => _$EventModelFromJson(json);
  JSON toJson() => _$EventModelToJson(this);

  TimeData? getTimeData(String key) {
    for (var item in timeData) {
      if (item.id.toLowerCase() == key.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  subTimeData(String key) {
    for (var item in timeData) {
      if (item.id.toLowerCase() == key.toLowerCase()) {
        timeData.remove(item);
        return true;
      }
    }
    return false;
  }
}

@JsonSerializable()
class TimeData {
  String      id = '';
  int         status = 0;       // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String      title = '';
  String      desc = '';
  String      startDate = '';   // 시작일
  String      endDate = '';     // 종료일
  String      startTime = '';   // 시작시간
  String      endTime = '';     // 종료시간
  int         index = 0;
  List<String> day = [];        // 특별한 날 선택
  List<String> dayWeek = [];    // 요일 선택 (월, 화..)
  List<String> week = [];       // 주간 선택 (첫째주, 마지막주..)
  List<String> exceptDay = [];  // 제외 날 선택
  TimeData({
    id,
    status,
    title,
    desc,
    startDate,
    endDate,
    startTime,
    endTime,
    index,
    day,
    dayWeek,
    week,
    exceptDay,
  });
  factory TimeData.fromJson(JSON json) => _$TimeDataFromJson(json);
  JSON toJson() => _$TimeDataToJson(this);
}

@JsonSerializable()
class PromotionData {
  String id = '';
  int    status = 0;            // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String title = '';
  String typeId = '';           // 프로모션 type ID
  String startDate = '';        // 시작일
  String endDate = '';          // 종료일
  String startTime = '';        // 시작시간
  String endTime = '';          // 종료시간
  PromotionData({
    id,
    status,
    title,
    typeId,
    startDate,
    endDate,
    startTime,
    endTime,
  });
  factory PromotionData.fromJson(JSON json) => _$PromotionDataFromJson(json);
  JSON toJson() => _$PromotionDataToJson(this);
}

@JsonSerializable()
class OptionData {
  String id = '';
  bool   value = false;
  OptionData({
    id,
    value,
  });
  factory OptionData.fromJson(JSON json) => _$OptionDataFromJson(json);
  JSON toJson() => _$OptionDataToJson(this);
}

@JsonSerializable()
class PicData {
  String id;
  int    type; // 이미지 종류 (0:photo, 1:movie..)
  String url;
  String? data;
  PicData({
    required this.id,
    required this.type,
    required this.url,
    required this.data,
  });
  factory PicData.fromJson(JSON json) => _$PicDataFromJson(json);
  JSON toJson() => _$PicDataToJson(this);
}