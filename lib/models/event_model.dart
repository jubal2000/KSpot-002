import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:json_annotation/json_annotation.dart';
import '../utils/utils.dart';
import '../widget/event_time_edit_widget.dart';
import 'etc_model.dart';
part 'event_model.g.dart';

class EventModelEx extends EventModel {
  EventModelEx.empty(String id, {
      var title = '',
      var desc = '',
    }) :
    super(
      id: id,
      status: 1,
      title: title,
      titleKr: '',
      desc: desc,
      descKr: '',
      pic: '',
      groupId: '',
      placeId: '',
      country: '',
      countryState: '',
      userId: '',
      likeCount: 0,
      voteCount: 0,
      commentCount: 0,
      updateTime: '',
      createTime: '',

      tagData: [],
      managerData: [],
      searchData: [],
      picData: [],
      timeData: [],
      optionData: [],
      customData: [],
      promotionData: [],
    );
}

@JsonSerializable(
  explicitToJson: true,
)
class EventModel {
  String  id;
  int     status;         // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  String  title;
  String  titleKr;
  String  desc;
  String  descKr;
  String  pic;            // 대표 이미지 (Small Size)
  String  groupId;        // 그룹 ID
  String  placeId;        // 장소 ID
  String  country;        // 국가
  String  countryState;   // 도시
  String  userId;         // 소유 유저
  int     likeCount;      // 종아요 횟수
  int     voteCount;      // 추천 횟수
  int     commentCount;   // 댓글 갯수
  String  updateTime;     // 수정 시간
  String  createTime;     // 생성 시간

  List<String>?        tagData;        // tag
  List<String>?        searchData;     // 검색어 목록
  List<PicData>?       picData;        // 메인 이미지 목록
  List<TimeData>?      timeData;       // 시간 정보 목록
  List<OptionData>?    optionData;     // 옵션 정보
  List<CustomData>?    customData;     // 사용자 설정 정보
  List<PromotionData>? promotionData;  // 광고 정보
  List<ManagerData>?   managerData;    // 관리자 목록

  EventModel({
    required this.id,
    required this.status,
    required this.title,
    required this.titleKr,
    required this.desc,
    required this.descKr,
    required this.pic,
    required this.groupId,
    required this.placeId,
    required this.country,
    required this.countryState,
    required this.userId,
    required this.likeCount,
    required this.voteCount,
    required this.commentCount,

    required this.updateTime,
    required this.createTime,

    this.tagData,
    this.picData,
    this.searchData,
    this.timeData,
    this.optionData,
    this.customData,
    this.promotionData,
    this.managerData,
  });
  factory EventModel.fromJson(JSON json) => _$EventModelFromJson(json);
  JSON toJson() => _$EventModelToJson(this);


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
  //  TimeData
  //

  get getTimeDataMap {
    JSON result = {};
    if (timeData != null) {
      for (var item in timeData!) {
        result[item.id] = item.toJson();
      }
    }
    return result;
  }

  addTimeData(TimeData addItem) {
    timeData ??= [];
    LOG('--> addTimeData : ${addItem.toJson()} / ${timeData!.length}');
    int index = 0;
    for (var item in timeData!) {
      if (item.id == addItem.id) {
        timeData![index] = addItem;
        return index;
      }
      index++;
    }
    timeData!.add(addItem);
    return timeData!.indexOf(addItem);
  }

  TimeData? getTimeData(String key) {
    if (timeData != null) {
      for (var item in timeData!) {
        if (item.id == key) {
          return item;
        }
      }
    }
    return null;
  }

  removeTimeData(String key) {
    if (timeData != null) {
      for (var item in timeData!) {
        if (item.id.toLowerCase() == key.toLowerCase()) {
          timeData!.remove(item);
          return true;
        }
      }
    }
    return false;
  }

  setTimDataMap(JSON map) {
    timeData ??= [];
    timeData!.clear();
    if (map.isNotEmpty) {
      for (var item in map.entries) {
        timeData!.add(item.value);
      }
    }
    return timeData;
  }

  getDateTimeStr(DateTime checkDate) {
    final date = getDateTimeData(checkDate);
    return date != null ? '${date.startTime} ~ ${date.endTime}' : '';
  }

  getDateTimeTitleStr(DateTime checkDate) {
    final date = getDateTimeData(checkDate);
    return date != null ? '${date.title} : ${date.startTime} ~ ${date.endTime}' : '';
  }

  getDateTimeTitle(DateTime checkDate) {
    final date = getDateTimeData(checkDate);
    return date != null ? date.title : '';
  }

  TimeData? getDateTimeData(DateTime checkDate, [String title = '']) {
    if (timeData == null) return null;
    for (var item in timeData!) {
      if (LIST_NOT_EMPTY(item.day)) {
        for (var time in item.day!) {
          var startDate = DateTime.parse(time);
          if (startDate.toString().split(' ').first == checkDate.toString().split(' ').first) return item;
        }
        return null;
      } else {
        // LOG('--> Date Range init : ${item.value['startDate']} ~ ${item.value['endDate']}');
        if (STR(item.startDate).isEmpty) item.startDate = DateTime.now().toString();
        var startDate = DateTime.parse('${item.startDate!} 00:00:00.000');
        if (STR(item.endDate).isEmpty) item.endDate = startDate.add(Duration(days: 364)).toString();
        var endDate = DateTime.parse('${item.endDate!} 23:59:59.999');
        var duration  = endDate.difference(startDate).inDays + 1;
        // LOG('--> Date Range : ${item.value['startDate']} ~ ${item.value['endDate']} => $duration / ${item.value['week']}');
        for (var i=0; i<duration; i++) {
          var day = startDate.add(Duration(days: i));
          var dayStr = day.toString().split(' ').first;
          // if (checkDate.isAfter(startDate) && checkDate.isBefore(endDate)) {
          if (checkDate.isSameDay(day)) {
            // LOG('--> [$title] getDateTimeData day range ok : ${checkDate.toString()} / ${startDate.toString()} / ${endDate.toString()}');
            var isShow = LIST_NOT_EMPTY(item.exceptDay!) || !item.exceptDay!.contains(dayStr);
            if (isShow && LIST_NOT_EMPTY(item.week) && !item.week!.contains(weekText.first)) {
              var wm = day.weekOfMonth;
              isShow = ((wm < weekText.length && item.week!.contains(weekText[wm])) || wm >= weekText.length) &&
                  (wm == day.lastWeek && item.week!.contains(weekText.last) || wm != day.lastWeek);
              // LOG('--> [$title] day.weekOfMonth : $wm / ${item.week} => ${isShow ? 'show' : 'hide'}');
            }
            if (isShow && LIST_NOT_EMPTY(item.dayWeek) && !item.dayWeek!.contains(dayWeekText.first)) {
              var wm = day.weekday;
              isShow = item.dayWeek!.contains(dayWeekText[wm]);
              // LOG('--> [$title] day.weekday : $wm / ${item.dayWeek} => ${isShow ? 'show' : 'hide'}');
            }
            if (isShow) {
              return item;
            }
          }
        }
      }
    }
    return null;
  }

  //------------------------------------------------------------------------------------------------------
  //  TimeData
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
        managerData!.add(ManagerData.fromJson(item.value));
      }
    }
    return managerData;
  }

  //------------------------------------------------------------------------------------------------------
  //  CustomData
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

  setCustomDataMap(JSON map) {
    customData ??= [];
    customData!.clear();
    if (map.isNotEmpty) {
      for (var item in map.entries) {
        customData!.add(CustomData.fromJson(item.value));
      }
    }
    return customData;
  }

  //------------------------------------------------------------------------------------------------------
  //  TagData
  //

  addTagData(String tag) {
    tagData ??= [];
    if (!tagData!.contains(tag)) {
      tagData!.add(tag);
    }
    return tagData!.indexOf(tag);
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

// addOptionData(OptionData item) {
  //   optionData ??= [];
  //   if (!optionData!.contains(item)) {
  //     optionData!.add(item);
  //   }
  //   return optionData!.indexOf(item);
  // }
}
