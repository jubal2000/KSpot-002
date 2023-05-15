import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpers/helpers.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:image/image.dart' as IMG;
import 'package:kspot_002/services/api_service.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../data/app_data.dart';
import '../data/common_colors.dart';
import '../data/common_sizes.dart';
import '../data/style.dart';
import '../models/etc_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../view/place/place_list_screen.dart';
import '../view_model/event_edit_view_model.dart';
import '../widget/event_group_dialog.dart';
import '../widget/dropdown_widget.dart';
import '../widget/event_time_edit_widget.dart';
import '../widget/title_text_widget.dart';

typedef JSON = Map<String, dynamic>;
typedef SnapShot = QuerySnapshot<Map<String, dynamic>>;
const String NO_IMAGE = 'assets/ui/no_image_00.png';

// ignore: non_constant_identifier_names
LOG(String msg) {
  print(msg);
}

// ignore: non_constant_identifier_names
BOL(dynamic value, {bool defaultValue = false}) {
  return value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ? value.toString() == '1' || value.toString() == 'on' || value.toString() == 'true' : defaultValue;
}

// ignore: non_constant_identifier_names
INT(dynamic value, {int defaultValue = 0}) {
  if (value is double) {
    value = value.toInt();
  }
  return value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ? int.parse(value.toString()) : defaultValue;
}

// ignore: non_constant_identifier_names
DBL(dynamic value, {double defaultValue = 0.0}) {
  return value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ? double.parse(value.toString()) : defaultValue;
}

// ignore: non_constant_identifier_names
STR(dynamic value, {String defaultValue = ''}) {
  var result = value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? value!.toString() : defaultValue;
  result = result.replaceAll('\\n', ' ');
  result = result.replaceAll('\n', ' ');
  return result;
}

// ignore: non_constant_identifier_names
DESC(dynamic value, {String defaultValue = ''}) {
  var result = value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? value!.toString() : defaultValue;
  result = result.replaceAll('\\n', '\n');
  return result;
}

// ignore: non_constant_identifier_names
TR(dynamic value, {String defaultValue = ''}) {
  return STR(value, defaultValue: defaultValue).toString().tr;
}

// ignore: non_constant_identifier_names
STR_FLAG_TEXT(dynamic value, {String defaultValue = ''}) {
  return STR(value).toString().toUpperCase().replaceFirst('   ', '');
}

// ignore: non_constant_identifier_names
STR_FLAG_ONLY(dynamic value, {String defaultValue = ''}) {
  return STR(value).toString().split(' ').first;
}

// ignore: non_constant_identifier_names
COL(dynamic value, {Color defaultValue = Colors.white}) {
  return value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? hexStringToColor(value!.toString()) : defaultValue;
}

// ignore: non_constant_identifier_names
COL2STR(dynamic value, {String defaultValue = 'ffffff'}) {
  return value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? colorToHexString(value.runtimeType == MaterialColor ? Color(value.value) : value) : defaultValue;
}

// ignore: non_constant_identifier_names
TME(dynamic value, {dynamic defaultValue = '00:00'}) {
  DateTime? result;
  try {
    result =
    value is DateTime ? value :
    value is String ? DateTime.parse(value.toString()) :
    value is Timestamp ? DateTime.fromMillisecondsSinceEpoch(value.seconds * 1000) :
    value is Map && value['seconds'] != null ? DateTime.fromMillisecondsSinceEpoch(value['seconds'] * 1000) :
    defaultValue != null && defaultValue != '' ? DateTime.parse(defaultValue!.toString())
    : DateTime.parse('00:00');
  } catch (e) {
    LOG("--> TME error : ${value.toString()} -> $e");
  }
  // LOG("--> TME result : ${result.toString()}");
  return result;
}

// ignore: non_constant_identifier_names
TME2(dynamic value, {dynamic defaultValue = '00:00'}) {
  var result = '';
  if (value == null || value == 'null') {
    result = defaultValue;
  } else {
    var timeArr = value.toString().split(':');
    if (timeArr.length > 1) {
      var count = 0;
      for (var item in timeArr) {
        if (item.length < 2) result += '0';
        result += item;
        if (count++ == 0) {
          result += ':';
        }
      }
    } else {
      result = defaultValue;
    }
  }
  LOG("--> TME2 result : $result");
  return result;
}

// ignore: non_constant_identifier_names
COMMENT_DESC(dynamic desc) {
  if (desc == null) return '';
  desc = desc.replaceAll('\\n', ' ');
  desc = desc.replaceAll('\n', ' ');
  return desc;
}

// ignore: non_constant_identifier_names
CURRENT_DATE() {
  var format = DateFormat('yyyy-MM-dd');
  var date = DateTime.now();
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
DATETIME_STR(DateTime date) {
  var format = DateFormat('yyyy-MM-dd HH:mm');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
DATETIME_FULL_STR(DateTime date) {
  var format = DateFormat('yyyy-MM-dd_HH:mm:ss');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
TIME_DATA_DESC(dynamic data, [String defaultValue = '']) {
  var result = '';
  if (data == null || data == 'null') return defaultValue;
  if (STR(data['day']).isNotEmpty) result += data['day'].first;
  if (data['startDate'] != null)  result += data['startDate'];
  if (data['endDate'] != null)    result += '~${data['endDate']}';
  var weekStr = '';
  if (data['week'] != null && data['week'].isNotEmpty) {
    if (result.isNotEmpty) result += ' / ';
    for (var item in data['week']) {
      if (weekStr.isNotEmpty) weekStr += ', ';
      weekStr += item + ' week';
    }
    result += weekStr;
  }
  var timeStr = '';
  if (data['startTime'] != null && data['startTime'].isNotEmpty) timeStr += data['startTime'];
  if (data['endTime'] != null && data['endTime'].isNotEmpty) timeStr += '~${data['endTime']}';
  if (result.isNotEmpty && timeStr.isNotEmpty) result += ' / ';
  result += timeStr;
  return result;
}

// ignore: non_constant_identifier_names
String SERVER_TIME_STR(value, [bool isTodayCut = false]) {
  if (value == null) return '';
  var format1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  var format2 = DateFormat('HH:mm:ss');
  DateTime? date = TME(value);
  if (date != null) {
    if (isTodayCut && date.isToday()) {
      return format2.format(date).toString();
    } else {
      return format1.format(date).toString();
    }
  }
  return '';
}

// ignore: non_constant_identifier_names
String SERVER_TIME_ONE_STR(value) {
  var timeData = value as JSON;
  if (JSON_EMPTY(timeData)) return '';
  return timeData.entries.first.value['title'];
}

String SERVER_DATE_STR(value) {
  if (value == null) return '';
  var format = DateFormat('yyyy-MM-dd');
  var date = TME(value);
  if (date != null) {
    return format.format(date).toString();
  }
  return '';
}

// ignore: non_constant_identifier_names
String EVENT_TIMEDATA_TITLE_STR(value) {
  var timeData = value as JSON;
  if (JSON_EMPTY(timeData)) return '';
  var result = '';
  for (var item in timeData.entries) {
    if (STR(item.value['title']).isNotEmpty) {
      if (result.isNotEmpty) result += ' / ';
      result += STR(item.value['title']);
    }
  }
  return result;
}

// ignore: non_constant_identifier_names
String EVENT_TIMEDATA_TIME_STR(value) {
  var timeData = value as JSON;
  if (JSON_EMPTY(timeData)) return '';
  var result = '';
  for (var item in timeData.entries) {
    if (result.isNotEmpty) result += ' / ';
    if (STR(item.value['startTime']).isNotEmpty) {
      result += STR(item.value['startTime']);
    }
    result += '~';
    if (STR(item.value['endTime']).isNotEmpty) {
      result += STR(item.value['endTime']);
    }
  }
  return result;
}

// ignore: non_constant_identifier_names
String EVENT_TIMEDATA_TITLE_TIME_STR(value) {
  var timeData = value as JSON;
  if (JSON_EMPTY(timeData)) return '';
  var result = '';
  for (var item in timeData.entries) {
    if (result.isNotEmpty) result += ' / ';
    if (STR(item.value['title']).isNotEmpty) {
      result += STR(item.value['title']) + ': ';
    }
    if (STR(item.value['startTime']).isNotEmpty) {
      result += STR(item.value['startTime']);
    }
    result += '~';
    if (STR(item.value['endTime']).isNotEmpty) {
      result += STR(item.value['endTime']);
    }
  }
  return result;
}

// ignore: non_constant_identifier_names
SERVER_DATE(DateTime date) {
  Timestamp currentTime = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
  return currentTime;
}

// ignore: non_constant_identifier_names
CURRENT_SERVER_TIME() {
  Timestamp currentTime = Timestamp.fromDate(DateTime.now());
  return currentTime;
}

// ignore: non_constant_identifier_names
OFFSET_CURRENT_SERVER_TIME(Duration duration) {
  var now = DateTime.now();
  Timestamp currentTime = Timestamp.fromDate(DateTime(now.year, now.month, now.day).add(duration));
  return currentTime;
}

// ignore: non_constant_identifier_names
CURRENT_SERVER_TIME_JSON() {
  Timestamp currentTime = Timestamp.fromDate(DateTime.now());
  return {
    '_seconds' : currentTime.seconds,
    '_nanoseconds' : currentTime.nanoseconds,
  };
}

// ignore: non_constant_identifier_names
CURRENT_SERVER_DATE() {
  var now = DateTime.now();
  return SERVER_DATE(now);
}

// ignore: non_constant_identifier_names
CURRENT_LOCAL_DATE() {
  var format = DateFormat('yyyy-MM-dd HH:mm:ss');
  return format.format(DateTime.now()).toString();
}

// ignore: non_constant_identifier_names
DATE_STR(DateTime date) {
  var format = DateFormat('yyyy-MM-dd');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
TIME_STR(DateTime date) {
  var format = DateFormat('HH:mm');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
PRICE_STR(price) {
  if (price == null || price.toString().isEmpty) return '0';
  var value = 0.0;
  if (price is String) {
    value = double.parse(price);
  } else {
    value = double.parse('$price');
  }
  var priceFormat = NumberFormat('###,###,###,###.##');
  return priceFormat.format(value).toString();
}

// ignore: non_constant_identifier_names
PRICE_FULL_STR(price, currency, [bool isShowEx = true]) {
  var priceStr = PRICE_STR(price);
  return '${CURRENCY_STR(currency)}$priceStr ${isShowEx?'($currency)':''}';
}

// ignore: non_constant_identifier_names
PRICE_DATA_STR(priceData, [bool isShowEx = false]) {
  // "priceData": {
  //  "price": 50000.0,
  //  "priceSale": 1000.0,
  //  "priceSaleRatio": 10.0,
  //  "currency": "KRW",
  // },
  var price           = DBL(priceData['price']);
  var priceSale       = DBL(priceData['priceSale']);
  var priceSaleRatio  = DBL(priceData['priceSaleRatio']);
  var currency        = priceData['currency'] ?? '';
  var priceTotal      = price - priceSale - (priceSaleRatio / 100 * price);
  var priceStr        = PRICE_STR(priceTotal);
  if (priceSale > 0) {
    priceStr += '(${PRICE_STR(priceSale)} sale)';
  }
  if (priceSaleRatio > 0) {
    priceStr += '($priceSaleRatio% sale)';
  }
  return '${CURRENCY_STR(currency)}$priceStr ${isShowEx?'($currency)':''}';
}
// ignore: non_constant_identifier_names
PriceRow(priceData, [bool isShowEx = false]) {
  // "priceData": {
  //  "price": 50000.0,
  //  "priceSale": 1000.0,
  //  "priceSaleRatio": 10.0,
  //  "currency": "KRW",
  // },
  var price           = DBL(priceData['price']);
  var priceSale       = DBL(priceData['priceSale']);
  var priceSaleRatio  = DBL(priceData['priceSaleRatio']);
  var currency        = priceData['currency'] ?? '';
  var priceTotal      = price - priceSale - (priceSaleRatio / 100 * price);
  var priceStr        = PRICE_STR(price);
  var priceTotalStr   = PRICE_STR(priceTotal);
  var saleStr = '';

  if (priceSale > 0 || priceSaleRatio > 0) {
    saleStr += '(';
    if (priceSale > 0) {
      saleStr += '${PRICE_STR(priceSale)}';
    }
    if (priceSaleRatio > 0) {
      if (priceSale > 0) {
        saleStr += '/';
      }
      saleStr += '$priceSaleRatio%';
    }
    saleStr += ' ${'Discount now'.tr})';
  }

  return Row(
    children: [
      Text('${CURRENCY_STR(currency)}$priceTotalStr', style: ItemDescPriceStyle(Get.context!)),
      SizedBox(width: 5),
      Text('${CURRENCY_STR(currency)}$priceStr', style: ItemDescPriceOrgStyle(Get.context!)),
      if (saleStr.isNotEmpty)...[
        SizedBox(width: 5),
        Text(saleStr, style: ItemDescStyle(Get.context!)),
      ],
    ],
  );
}

// ignore: non_constant_identifier_names
FILE_SIZE_STR(size) {
  if (size == null || size.toString().isEmpty) return '0';
  var value = 0.0;
  if (size is String) {
    value = double.parse(size);
  } else {
    value = double.parse('$size');
  }
  var priceFormat = NumberFormat('###,###,###,###.##');
  return '${priceFormat.format(value / 1000).toString()} Kbyte';
}

var fileIconList = ['ai','avi','doc','docx','fla','html','mp3','mp4','pdf','ppt','pptx','psd','txt','xls','xlsx'];

// ignore: non_constant_identifier_names
FILE_ICON(String? ext) {
  if (ext == null) return NO_IMAGE;
  if (fileIconList.contains(ext)) {
    return 'assets/file_icons/icon_$ext.png';
  }
  return 'assets/file_icons/icon_none.png';
}

// ignore: non_constant_identifier_names
SALE_STR(value) {
  if (value == null) return '';
  double tmpNum = value;
  var format1 = NumberFormat('###,###,###,###.##');
  var format2 = NumberFormat('###,###,###,###');
  return tmpNum - tmpNum.floor() > 0 ? format1.format(tmpNum).toString() : format2.format(tmpNum).toString();
}

// ignore: non_constant_identifier_names
REMAIN_DATETIME(dynamic dateTime) {
  if (dateTime == null) {
    LOG('---> REMAIN_DATETIME is Zero');
    return 0;
  }
  var format = DateFormat('yyyy-MM-dd');
  var dateStr = '';
  try {
    if (dateTime is Map && dateTime['_seconds'] != null) {
      var date = TME(dateTime);
      dateStr = format.format(date).toString();
      LOG('---> REMAIN_DATETIME dateStr : $dateStr');
    } else {
      dateStr = dateTime;
    }
    DateTime date = format.parse(dateStr);
    LOG('---> REMAIN_DATETIME : $dateStr / ${date.difference(DateTime.now()).inDays} / ${date.difference(DateTime.now()).inHours}');
    return date.difference(DateTime.now()).inDays + (date.difference(DateTime.now()).inHours > 0 ? 1 : 0);
  } catch (e) {
    LOG('---> REMAIN_DATETIME Error : $e / $dateStr');
    return 0;
  }
}

CURRENCY_STR(String key) {
  return AppData.INFO_CURRENCY.containsKey(key) ? AppData.INFO_CURRENCY[key]['currency'] : '';
}

CURRENCY_SELECT_LIST() {
  List<JSON> _currencyList = List<JSON>.from(AppData.INFO_CURRENCY.entries.map((item) => {'key': item.key, 'title': '${item.key} ${item.value['currency']}'}).toList());
  return _currencyList;
}

// ignore: non_constant_identifier_names
JSON_START_DAY_SORT_DESC(JSON data) {
  // LOG("--> JSON_START_DAY_SORT_DESC : ${data.length}");
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return INT(data[a]['startDay']) > INT(data[b]['startDay']) ? -1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_CREATE_TIME_SORT_DESC(JSON data) {
  // LOG("--> JSON_CREATE_TIME_SORT_DESC : ${data.length}");
  try {
    if (JSON_EMPTY(data)) return JSON.from({});
    if (data.length < 2) return data;
    return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
      // LOG("--> check : ${data[a]['createTime']}");
      return data[a]['createTime'] != null && data[b]['createTime'] != null ?
      DateTime.parse(data[a]['createTime']).isBefore(DateTime.parse(data[b]['createTime'])) ? -1 : 1 : 1;
    }));
  } catch (e) {
    LOG("--> JSON_CREATE_TIME_SORT_DESC error : $e");
  }
}

// ignore: non_constant_identifier_names
JSON_UPDATE_TIME_SORT_DESC(JSON data) {
  // LOG("--> JSON_UPDATE_TIME_SORT_DESC : ${data.length}");
  if (JSON_EMPTY(data)) return JSON.from({});
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return data[a]['updateTime'] != null && data[b]['updateTime'] != null ?
    DateTime.parse(data[a]['updateTime']).isBefore(DateTime.parse(data[b]['updateTime'])) ? -1 : 1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_CREATE_TIME_SORT_ASCE(JSON data) {
  // LOG("--> JSON_CREATE_TIME_SORT_DESC : $data");
  if (JSON_EMPTY(data)) return JSON.from({});
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']} > ${data[b]['createTime']}");
    return data[a]['createTime'] != null && data[b]['createTime'] != null ?
    DateTime.parse(data[a]['createTime']).isBefore(DateTime.parse(data[b]['createTime'])) ? -1 : 1 : 1;
    // data[a]['createTime']['_seconds'] > data[b]['createTime']['_seconds'] ? 1 : -1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_TIME_STR_SORT_ASCE(JSON data) {
  // LOG("--> JSON_CREATE_TIME_SORT_DESC : $data");
  if (JSON_EMPTY(data)) return JSON.from({});
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return data[a]['createTime'] != null && data[b]['createTime'] != null ?
    data[a]['createTime'] < data[b]['createTime'] ? -1 : 1 : 1;
    // data[a]['createTime']['_seconds'] > data[b]['createTime']['_seconds'] ? 1 : -1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_TARGET_DATE_SORT_ASCE(JSON data) {
  // LOG("--> JSON_TARGET_DATE_SORT_ASCE : $data");
  try {
    if (JSON_EMPTY(data)) return JSON.from({});
    if (data.length < 2) return data;
    return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
      // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
      return DateTime.parse(STR(data[a]['targetDate'])).isBefore(DateTime.parse(STR(data[b]['targetDate']))) ? -1 : 1;
    }));
  } catch (e) {
    LOG("--> JSON_TARGET_DATE_SORT_ASCE error : $e");
  }
  return data;
}

// ignore: non_constant_identifier_names
JSON_INDEX_SORT_ASCE(JSON data) {
  // LOG("--> JSON_INDEX_SORT_ASCE : $data");
  if (JSON_EMPTY(data)) return JSON.from({});
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    if (data[a]['index'] != null) {
      return data[a]['index'] != null && data[b]['index'] != null ?
      INT(data[a]['index']) > INT(data[b]['index']) ? 1 : -1 : 0;
    } else if (data[a]['sortIndex'] != null) {
      return data[a]['sortIndex'] != null && data[b]['sortIndex'] != null ?
      INT(data[a]['sortIndex']) > INT(data[b]['sortIndex']) ? 1 : -1 : 0;
    }
    return 0;
  }));
}

// ignore: non_constant_identifier_names
EVENT_SORT_HOT(List<EventModel> data) {
  // LOG("--> JSON_INDEX_SORT_ASCE : $data");
  if (data.length < 2) return data;
  var checkDate = '${AppData.currentDate.year}-${AppData.currentDate.month}-${AppData.currentDate.day}';
  data.sort((a, b) =>
    a.sponsorCount[checkDate] != null && b.sponsorCount[checkDate] != null &&
    a.sponsorCount[checkDate]! > b.sponsorCount[checkDate]! ? -1 : 1);
  return data;
}

// ignore: non_constant_identifier_names
LIST_CREATE_TIME_SORT_DESC(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['createTime'] != null && b['createTime'] != null ?
  DateTime.parse(a['createTime']).isAfter(DateTime.parse(b['createTime'])) ? -1 : 1 : 0);
  return data;
}

// ignore: non_constant_identifier_names
LIST_CREATE_TIME_SORT_ASCE(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['createTime'] != null && b['createTime'] != null ?
  DateTime.parse(a['createTime']).isAfter(DateTime.parse(b['createTime'])) ? 1 : -1 : 0);
  return data;
}

// ignore: non_constant_identifier_names
LIST_START_TIME_SORT(List<JSON> data) {
  // LOG("--> LIST_START_TIME_SORT : $data");
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['startTime'] != null && b['startTime'] != null ?
  DateTime.parse(a['startTime']).isAfter(DateTime.parse(b['startTime'])) ? 1 : -1 : 0);
  return data;
}

// ignore: non_constant_identifier_names
LIST_DATE_SORT_ASCE(List<String> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => DateTime.parse(a).isAfter(DateTime.parse(b)) ? 1 : -1);
  return data;
}

// ignore: non_constant_identifier_names
LIST_LIKES_SORT_DESC(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => INT(a['likes']) > INT(b['likes']) ? -1 : 1);
  return data;
}

// ignore: non_constant_identifier_names
JSON_INDEX_SORT(JSON data) {
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) =>
  INT(data[a]['index']) > INT(data[b]['index']) ? 1 : -1));
}

// ignore: non_constant_identifier_names
JSON_LAST_INDEX(JSON data, int offset) {
  var result = 0;
  data.forEach((key, value) {
    var checkIndex = INT(value['index']);
    if (checkIndex > result) result = checkIndex;
  });
  return result + offset;
}

// ignore: non_constant_identifier_names
JSON_START_DAY_SORT(JSON data) {
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) =>
  INT(data[a]['startDay']) > INT(data[b]['startDay']) ? -1 : 1));
}


// ignore: non_constant_identifier_names
JSON_SEEN_SORT(JSON data) {
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) =>
  BOL(data[a]['isSeen']) && !BOL(data[b]['isSeen']) ? 1 : -1));
}

// ignore: non_constant_identifier_names
LIST_INDEX_SORT(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  data.sort((a, b) => INT(a['index']) > INT(b['index']) ? 1 : -1);
  return data;
}

// ignore: non_constant_identifier_names
LIST_LAST_INDEX(List<JSON> data, int offset) {
  var result = 0;
  for (var item in data) {
    var checkIndex = INT(item['index']);
    if (checkIndex > result) result = checkIndex;
  }
  return result + offset;
}

colorToHexString(Color color) {
  return color.value.toRadixString(16).substring(2, 8);
}

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

// ignore: non_constant_identifier_names
JSON_NOT_EMPTY(dynamic data) {
  return data != null && data.isNotEmpty;
}

// ignore: non_constant_identifier_names
JSON_EMPTY(dynamic data) {
  return !JSON_NOT_EMPTY(data);
}

// ignore: non_constant_identifier_names
LIST_NOT_EMPTY(dynamic data) {
  return data != null && List.from(data).isNotEmpty;
}

// ignore: non_constant_identifier_names
LIST_IN_ITEM(dynamic data, dynamic item) {
  return LIST_NOT_EMPTY(data) && data.contains(item);
}

// ignore: non_constant_identifier_names
LIST_EMPTY(dynamic data) {
  if (data == null) return true;
  return !LIST_NOT_EMPTY(data);
}

// ignore: non_constant_identifier_names
STR_NOT_EMPTY(dynamic data) {
  return STR(data).isNotEmpty;
}

// ignore: non_constant_identifier_names
STR_EMPTY(dynamic data) {
  return !STR_NOT_EMPTY(data);
}

// ignore: non_constant_identifier_names
PARAMETER_JSON(String key, dynamic value) {
  if (value == null) return {};
  return {key: json.encode(value)};
}

// ignore: non_constant_identifier_names
GET_COUNTRY_EXCEPT_FLAG(String value) {
  var result = '';
  var arr = value.split(' ');
  for (var i=1; i<arr.length; i++) {
    var item = arr[i];
    if (item != ' ' && result.isNotEmpty) result += ' ';
    result += item;
  }
  return result;
}

// ignore: non_constant_identifier_names
STRING_TO_UINT8LIST(String value) {
  return Uint8List.fromList(List<int>.from(value.codeUnits));
}

// ignore: non_constant_identifier_names
ADDR(dynamic desc) {
  if (desc != null) {
    var addr1 = desc['address1'] ?? '';
    return STR(addr1);
  }
  return '';
}

// ignore: non_constant_identifier_names
LATLNG(dynamic desc) {
  if (desc == null) return LatLng(0,0);
  return LatLng(DBL(desc['lat']), DBL(desc['lng']));
}

// ignore: non_constant_identifier_names
LAT(dynamic desc) {
  if (desc == null) return 0;
  return DBL(desc['lat']);
}

LNG(dynamic desc) {
  if (desc == null) return 0;
  return DBL(desc['lng']);
}

// ignore: non_constant_identifier_names
ADDR_GOOGLE(dynamic desc, String title, String pic) {
  if (desc == null) return null;
  return {'title': title, 'pic': pic, 'lat': DBL(desc['lat']), 'lng': DBL(desc['lng'])};
}

// ignore: non_constant_identifier_names
NUMBER_K(int number) {
  String result = "";
  if (number > 1000) {
    var num1 = number / 1000;
    result = num1.toStringAsFixed(1);
    result += 'K';
  } else {
    result = '$number';
  }
  return result;
}

Widget getCircleImage(String url, double size) {
  return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(size),
          child: showImageWidget(url, BoxFit.cover)
      )
  );
}

Widget showSizedImage(dynamic imagePath, double size) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(size / 8),
    child: SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.fill,
        child: showImageFit(imagePath),
      ),
    ),
  );
}

Widget showCardRoundImage(dynamic imagePath, double size,
    [BorderRadius radius = const BorderRadius.only(topLeft:Radius.circular(10), bottomLeft:Radius.circular(20))]) {
  return ClipRRect(
    borderRadius: radius,
    child: SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.fill,
        child: showImageFit(imagePath),
      ),
    ),
  );
}

Widget showSizedRoundImage(dynamic imagePath, double size, double round) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(round),
    child: SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.fill,
        child: showImageFit(imagePath),
      ),
    ),
  );
}

Widget showImage(String url, Size size, {Color? color, var fit = BoxFit.cover}) {
  return SizedBox(
      width: size.width,
      height: size.height,
      child: showImageWidget(url, fit, color:color)
  );
  // if (url.contains("http")) {
  //   return CachedNetworkImage(
  //     fit: BoxFit.cover,
  //     imageUrl: url,
  //     height: size.width,
  //     width: size.height,
  //     placeholder: (context, url) => showLoadingImageSize(size),
  //     errorWidget: (context, url, error) => Icon(Icons.error),
  //     color: color,
  //   );
  // } else {
  //   return Image.asset(
  //     url,
  //     width: size.width,
  //     height: size.height,
  //     color: color,
  //   );
  // }
}

Widget showImageFit(dynamic imagePath) {
  return showImageWidget(imagePath, BoxFit.fill);
}

Widget showImageWidget(dynamic imagePath, BoxFit fit, {Color? color}) {
  if (imagePath != null && imagePath.isNotEmpty) {
    try {
      if (imagePath.runtimeType == String && imagePath
          .toString()
          .isNotEmpty) {
        var url = imagePath.toString();
        if (url == 'empty') {
          return Container(
            width: 30,
            height: 30,
            color: Colors.transparent,
          );
        }
        if (url.contains("http")) {
          return CachedNetworkImage(
              fit: fit,
              color: color,
              imageUrl: url,
              cacheKey: url
                  .split('=')
                  .last,
              progressIndicatorBuilder: (context, url, progress) =>
                  Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(value: progress.progress),
                    ),
                  )
          );
        } else if (url.contains('/cache')) {
          return Image.file(File(url), fit: fit, color: color);
        } else if (url.contains('assets')) {
          return Image.asset(url, fit: fit, color: color);
        }
      } else if (imagePath.runtimeType == Uint8List) {
        return Image.memory(imagePath as Uint8List, fit: fit, color: color);
      }
    } catch (e) {
      LOG('--> showImage Error : $e');
    }
  }
  return Image.asset(NO_IMAGE);
}

Widget showLoadingCircleSquare(double size) {
  return Container(
      child: Center(
          child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(strokeWidth: size >= 50 ? 2 : 1)
          )
      )
  );
}

Widget showLoadingFullPage(BuildContext context) {
  return showLoadingPage(context, 150);
}

Widget showLoadingPage(BuildContext context, [int offset = 0]) {
  var size = 50.0;
  return LayoutBuilder(
    builder: (context, layout) {
      return Container(
        width:  layout.maxWidth,
        height: layout.maxHeight > offset ? layout.maxHeight - offset : double.infinity,
        color: Colors.blueGrey.withOpacity(0.1),
        child: Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(strokeWidth: size >= 50 ? 2 : 1)
          )
        )
      );
    }
  );
}

Widget showLogoLoadingPage(BuildContext context) {
  var size = 120.0;
  return LayoutBuilder(
    builder: (context, layout) {
      return Container(
        width:  layout.maxWidth,
        height: layout.maxHeight,
        color: Colors.blueGrey.withOpacity(0.1),
        child: Center(
          child: showImage('assets/ui/logo_01_00.png', Size(size, size)),
        )
      );
    }
  );
}


class showVerticalDivider extends StatelessWidget {
  showVerticalDivider(this.size,
      {Key ? key, this.color = Colors.grey, this.thickness = 1})
      : super (key: key);

  Size size = Size(20, 20);
  Color? color;
  double? thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size.width,
        height: size.height,
        child: Center(
            child: VerticalDivider(
              color: color,
              thickness: thickness,
              width: size.width,
            )
        )
    );
  }
}

class showHorizontalDivider extends StatelessWidget {
  showHorizontalDivider(this.size,
      {Key ? key, this.color, this.thickness = 1})
      : super (key: key);

  Size size;
  Color? color;
  double? thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      child: Center(
        child: Divider(
          color: color ?? Colors.grey.withOpacity(0.35),
          thickness: thickness,
          height: size.height,
        )
      )
    );
  }
}

// ignore: non_constant_identifier_names
Future<Uint8List?> ReadFileByte(String filePath) async {
  Uri myUri = Uri.parse(filePath);
  File audioFile = File.fromUri(myUri);
  Uint8List? bytes;
  await audioFile.readAsBytes().then((value) {
    bytes = Uint8List.fromList(value);
    LOG('--> reading of bytes is completed');
  }).catchError((onError) {
    LOG('--> Exception Error while reading audio from path: ${onError.toString()}');
  });
  return bytes;
}

inputLabel(BuildContext context, String label, String hint, {double width = 2, EdgeInsets? padding}) {
  return inputLabelSuffix(context, label, hint, width: width, padding: padding);
}

viewLabel(BuildContext context, String label, String hint, {double width = 0, EdgeInsets? padding}) {
  return inputLabelSuffix(context, label, hint, width: width, padding: padding, fillColor: Theme.of(context).canvasColor.withOpacity(0.2));
}

inputLabelSuffix(BuildContext context, String label, String hint,
    {String suffix = '', bool isEnabled = true, double width = 1, EdgeInsets? padding, Color? fillColor}) {
  return InputDecoration(
    filled: true,
    isDense: true,
    alignLabelWithHint: true,
    hintText: hint,
    suffixText: suffix,
    labelText: label,
    enabled: isEnabled,
    contentPadding: padding ?? EdgeInsets.all(10),
    hintStyle: TextStyle(color: Theme.of(context).hintColor.withOpacity(0.5), fontSize: 10),
    fillColor: fillColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Colors.yellow),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Theme.of(context).colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width + 1, color: Theme.of(context).colorScheme.error),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Theme.of(context).focusColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Theme.of(context).primaryColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Colors.grey.withOpacity(0.5)),
    ),
  );
}

ShowToast(text, [Color backColor = Colors.black87, Color textColor = Colors.white]) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backColor,
      textColor: textColor,
      fontSize: 16.0
  );
}

ShowErrorToast(text)  {
  ShowToast(text, Colors.black87, Colors.yellow);
}

enum DropdownItemType {
  none,

  content,
  talent,
  goods,
  live,

  placeGroup,
  place,
  event,
  story,

  historyLink,
  goodsLink,
  urlLink,

  chatOpen,
  chatClose,
  message,
  unfollow,
  block,
  report,
  unReport,
  unblock,
  showDeclar,
  reDeclar,
  unDeclar,

  update,
  delete,
  edit,
  enable,
  disable,
  owner,
  cancel,
  list,
  reject,
  confirm,

  enter,
  exit,
  alarmOn,
  alarmOff,
  bookmarkOn,
  bookmarkOff,
  indexUp,
  indexDown,

  promotion,
  stop,
  pay,

  profile,
  kick,
  banList,
  title,
  noticeAdd,
  noticeShow,
  noticeSet,
  admin,
  invite,
  copy,
  toNotice,
}

class DropdownItem {
  final DropdownItemType type;
  final String? text;
  final IconData? icon;
  final bool isLine;
  final double height;
  final bool color;
  final bool alert;
  final bool manager;

  const DropdownItem(
    this.type,
    {
      this.text,
      this.icon,
      this.isLine = false,
      this.height = 40,
      this.color = false,
      this.alert = false,
      this.manager = false,
    }
  );
}


const userMenuProfile     = DropdownItem(DropdownItemType.profile, text: 'PROFILE', icon: Icons.person);
const userMenuMessage     = DropdownItem(DropdownItemType.message, text: 'SEND MESSAGE', icon: Icons.mail_outline);
const userMenuDelete      = DropdownItem(DropdownItemType.unfollow, text: 'FOLLOW CANCEL', icon: Icons.clear);
const userMenuMsgBlock    = DropdownItem(DropdownItemType.block, text: 'BLOCK', icon: Icons.mic_off);
const userMenuMsgReport   = DropdownItem(DropdownItemType.report, text: 'REPORT', icon: Icons.report_gmailerrorred);
const userMenuMsgUnReport = DropdownItem(DropdownItemType.unReport, text: 'REPORT CANCEL', icon: Icons.cancel_outlined);
const userMenuUnblock     = DropdownItem(DropdownItemType.unblock, text: 'UNBLOCK', icon: Icons.mic);
const userMenuDeclare     = DropdownItem(DropdownItemType.showDeclar, text: 'VIEW REPORT', icon: Icons.announcement_outlined);
const userMenuReDeclare   = DropdownItem(DropdownItemType.reDeclar, text: 'REPORT RESULT', icon: Icons.announcement);
const userMenuUnDeclare   = DropdownItem(DropdownItemType.unDeclar, text: 'REPORT CANCEL', icon: Icons.clear);
const userMenuKick        = DropdownItem(DropdownItemType.kick, text: 'DROP OUT', icon: Icons.clear, manager: true);
const userMenuBanList     = DropdownItem(DropdownItemType.banList, text: 'BAN LIST', icon: Icons.playlist_remove, manager: true);
const userMenuAdmin       = DropdownItem(DropdownItemType.admin, text: 'CHANGE ADMIN', icon: Icons.perm_identity, manager: true);
const userMenuLine        = DropdownItem(DropdownItemType.none, isLine: true);

class UserMenuItems {
  static const List<DropdownItem> followingMenu   = [userMenuMessage, userMenuDelete];
  static const List<DropdownItem> followerMenu    = [userMenuMessage];
  static const List<DropdownItem> messageMenu     = [userMenuMsgBlock, userMenuMsgReport];
  static const List<DropdownItem> chatUserMenu    = [userMenuProfile, userMenuMsgBlock, userMenuMsgReport];
  static const List<DropdownItem> chatAdminMenu0  = [userMenuKick];
  static const List<DropdownItem> chatAdminMenu1  = [userMenuAdmin];
  static const List<DropdownItem> blockMenu       = [userMenuUnblock];
  static const List<DropdownItem> declarMenu      = [userMenuDeclare, userMenuReDeclare, userMenuUnDeclare];

  static Widget buildItem(BuildContext context, DropdownItem item, {Function(DropdownItemType)? onSelected}) {
    var color = item.alert ? Theme.of(context).colorScheme.error : item.color ? Theme.of(context).primaryColor : Theme.of(context).hintColor;
    var style = item.alert ? itemTitleAlertStyle : item.color ? itemTitleColorStyle : itemTitleStyle;
    if (item.manager) {
      color = Theme.of(context).colorScheme.tertiary;
    }

    return GestureDetector(
      onTap: () {
        if (onSelected != null) onSelected(item.type);
      },
      child: Container(
        constraints: BoxConstraints(
          minHeight: item.isLine ? 3 : 45,
        ),
        child: Row(
          children: [
            if (!item.isLine)...[
              Icon(
                  item.icon,
                  color: color,
                  size: 20
              ),
              SizedBox(width: 5),
              if (item.text != null)...[
                SizedBox(width: 3),
                Text(item.text!.tr, style: style, maxLines: 1),
              ]
            ],
            if (item.isLine)...[
              Expanded(
                child: showHorizontalDivider(Size(double.infinity, 3), color: Theme.of(context).dividerColor),
              )
            ]
          ]
        )
      )
    );
  }
}

const dropMenuEnter       = DropdownItem(DropdownItemType.enter, text: 'ENTER', icon: Icons.login);
const dropMenuExit        = DropdownItem(DropdownItemType.exit, text: 'LEAVE', icon: Icons.logout);
const dropMenuAlarmOn     = DropdownItem(DropdownItemType.alarmOn, text: 'ALARM ON', icon: Icons.notifications_active);
const dropMenuAlarmOff    = DropdownItem(DropdownItemType.alarmOff, text: 'ALARM OFF', icon: Icons.notifications_off_outlined);
const dropMenuIndexBkOn   = DropdownItem(DropdownItemType.bookmarkOn, text: 'FIX TOP', icon: Icons.bookmark_add_outlined);
const dropMenuIndexBkOff  = DropdownItem(DropdownItemType.bookmarkOff, text: 'FIX RELEASE', icon: Icons.bookmark_remove_outlined);
const dropMenuIndexUp     = DropdownItem(DropdownItemType.indexUp, text: 'MOVE UP', icon: Icons.arrow_upward);
const dropMenuIndexDown   = DropdownItem(DropdownItemType.indexDown, text: 'MOVE DOWN', icon: Icons.arrow_downward);
const dropMenuTitle       = DropdownItem(DropdownItemType.title, text: 'TITLE CHANGE', icon: Icons.title, manager: true);
const dropMenuNoticeShow  = DropdownItem(DropdownItemType.noticeShow, text: 'NOTICE', icon: Icons.campaign_outlined);
const dropMenuNoticeSet   = DropdownItem(DropdownItemType.noticeSet, text: 'NOTICE SET', icon: Icons.campaign_rounded, manager: true);
const dropMenuNoticeAdd   = DropdownItem(DropdownItemType.noticeAdd, text: 'NOTICE ADD', icon: Icons.campaign_rounded, manager: true);
const dropMenuCopy        = DropdownItem(DropdownItemType.copy, text: 'COPY MESSAGE', icon: Icons.copy);
const dropMenuDelete      = DropdownItem(DropdownItemType.delete, text: 'DELETE IT', icon: Icons.delete_forever);
const dropMenuToNotice    = DropdownItem(DropdownItemType.toNotice, text: 'TO NOTICE', icon: Icons.campaign, manager: true);
const dropMenuInvite      = DropdownItem(DropdownItemType.invite, text: 'USER INVITE', icon: Icons.person_add_alt_1_outlined, manager: true);
const dropMenuLine        = DropdownItem(DropdownItemType.none, isLine: true);


class DropdownItems {
  static const List<DropdownItem> eventAddItem    = [placeGroup, place, event];
  static const List<DropdownItem> chatAddItem     = [chatOpen, chatClose, message];
  static const List<DropdownItem> messageAddItem  = [message];
  static const List<DropdownItem> storyAddItem    = [story];
  static const List<DropdownItem> homeAddItems    = [placeGroup, place, event];
  static const List<DropdownItem> homeAddItem0    = [event, story];
  static const List<DropdownItem> homeAddItem10   = [place];
  static const List<DropdownItem> homeAddItem11   = [placeGroup, place];
  static const List<DropdownItem> homeAddItem2    = [event];
  static const List<DropdownItem> homeAddItem3    = [talent, goods];
  static const List<DropdownItem> placeItems0     = [disable, edit, delete, promotion];
  static const List<DropdownItem> placeItems1     = [enable, edit, delete];
  static const List<DropdownItem> placeItems2     = [report];
  static const List<DropdownItem> contentAddItems = [content, talent, goods/*, live*/];
  static const List<DropdownItem> bannerEditItems = [historyLink, goodsLink, update, delete];
  static const List<DropdownItem> storyItems0     = [disable, edit, delete];
  static const List<DropdownItem> storyItems1     = [enable, edit, delete];
  static const List<DropdownItem> storyItems2     = [report];
  static const List<DropdownItem> promotionNone   = [promotionList];
  static const List<DropdownItem> promotionStart  = [cancel];
  static const List<DropdownItem> promotionRemove = [delete];
  static const List<DropdownItem> promotionManager0 = [promotionPay]; // promotionStatus : wait
  static const List<DropdownItem> promotionManager1 = [promotionStop]; // promotionStatus : activate
  static const List<DropdownItem> reserve0          = [cancel];
  static const List<DropdownItem> reserve1          = [delete];
  static const List<DropdownItem> reserve2          = [confirm, reject];
  static const List<DropdownItem> secondItems = [];
  static const List<DropdownItem> chatRoomMenu0     = [dropMenuEnter];
  static const List<DropdownItem> chatRoomMenu1     = [dropMenuExit];
  static const List<DropdownItem> chatRoomMenu2     = [dropMenuExit, dropMenuNoticeShow];
  static const List<DropdownItem> chatUserInvite    = [dropMenuInvite];
  static const List<DropdownItem> chatRoomAdmin0    = [dropMenuTitle, dropMenuNoticeAdd, userMenuBanList];
  static const List<DropdownItem> chatRoomAdmin1    = [dropMenuTitle, dropMenuNoticeAdd];
  static const List<DropdownItem> chatRoomAdmin2    = [dropMenuNoticeAdd];
  static const List<DropdownItem> chatItemMenu0     = [dropMenuCopy];
  static const List<DropdownItem> chatItemMenu1     = [dropMenuDelete];
  static const List<DropdownItem> chatItemMenu2     = [dropMenuToNotice];

  static const content      = DropdownItem(DropdownItemType.content, text: 'HISTORY +', icon: Icons.movie_creation);
  static const talent       = DropdownItem(DropdownItemType.talent, text: 'TALENT +', icon: Icons.star);
  static const goods        = DropdownItem(DropdownItemType.goods, text: 'GOODS +', icon: Icons.card_giftcard);
  static const live         = DropdownItem(DropdownItemType.live, text: 'LIVE +', icon: Icons.live_tv);

  static const placeGroup   = DropdownItem(DropdownItemType.placeGroup, text: 'SPOT GROUP', icon: Icons.map_outlined);
  static const place        = DropdownItem(DropdownItemType.place, text: 'SPOT', icon: Icons.place_outlined);
  static const event        = DropdownItem(DropdownItemType.event, text: 'EVENT', icon: Icons.event_available);
  static const story        = DropdownItem(DropdownItemType.story, text: 'STORY', icon: Icons.school_outlined);
  static const chatOpen     = DropdownItem(DropdownItemType.chatOpen, text: 'PUBLIC CHAT', icon: Icons.lock_open_outlined);
  static const chatClose    = DropdownItem(DropdownItemType.chatClose, text: 'PRIVATE CHAT', icon: Icons.lock_outline);
  static const message      = DropdownItem(DropdownItemType.message, text: '1:1 MESSAGE', icon: Icons.mail_outlined);

  static const historyLink  = DropdownItem(DropdownItemType.historyLink, text: 'HISTORY LINK', icon: Icons.link);
  static const goodsLink    = DropdownItem(DropdownItemType.goodsLink, text: 'GOODS LINK', icon: Icons.link);
  static const urlLink      = DropdownItem(DropdownItemType.urlLink, text: 'URL LINK', icon: Icons.link);

  static const update       = DropdownItem(DropdownItemType.update, text: 'IMAGE EDIT', icon: Icons.card_giftcard);
  static const delete       = DropdownItem(DropdownItemType.delete, text: 'DELETE', icon: Icons.delete_forever_sharp);
  static const edit         = DropdownItem(DropdownItemType.edit, text: 'EDIT', icon: Icons.edit_outlined);
  static const enable       = DropdownItem(DropdownItemType.enable, text: 'ENABLE' , icon: Icons.visibility_outlined);
  static const disable      = DropdownItem(DropdownItemType.disable, text: 'DISABLE', icon: Icons.visibility_off_outlined);

  static const report       = DropdownItem(DropdownItemType.report, text: 'REPORT', icon: Icons.report_gmailerrorred);
  static const promotion    = DropdownItem(DropdownItemType.promotion, text: 'PROMOTION', icon: Icons.star_border, color: true);
  static const promotionList    = DropdownItem(DropdownItemType.list, text: 'PROMOTION RECORD', icon: Icons.playlist_add_check);
  static const promotionPay     = DropdownItem(DropdownItemType.pay, text: 'PAYMENT OK', icon: Icons.attach_money, color: true);
  static const promotionStop    = DropdownItem(DropdownItemType.stop, text: 'PAYMENT CANCEL', icon: Icons.cancel, color: true);

  static const cancel       = DropdownItem(DropdownItemType.cancel, text: 'CANCEL', icon: Icons.cancel_outlined);
  static const confirm      = DropdownItem(DropdownItemType.confirm, text: 'CONFIRM', icon: Icons.done);
  static const reject       = DropdownItem(DropdownItemType.reject, text: 'REJECT', icon: Icons.cancel);

  static const line         = DropdownItem(DropdownItemType.none, isLine: true, height: 15);
  static const space        = DropdownItem(DropdownItemType.none, height: 5);

  static Widget buildItem(BuildContext context, DropdownItem item) {
    var color = item.alert ? Theme.of(context).colorScheme.error : item.color ? Theme.of(context).primaryColor : Theme.of(context).hintColor;
    var style = item.alert ? itemTitleAlertStyle : item.color ? itemTitleColorStyle : itemTitleStyle;
    if (item.manager) {
      color = Theme.of(context).colorScheme.tertiary;
    }
    return Row(
        children: [
          if (!item.isLine)...[
            Icon(
                item.icon,
                color: color,
                size: 20
            ),
            SizedBox(width: 5),
            if (item.text != null)...[
              SizedBox(width: 3),
              Text(item.text!.tr, style: style, maxLines: 1),
            ]
          ],
          if (item.isLine)...[
            Expanded(
              child: showHorizontalDivider(Size(double.infinity, 2), color: Colors.grey),
            )
          ]
        ]
    );
  }
}

class Tile extends StatelessWidget {
  Tile({
    Key? key,
    required this.index,
    this.title,
    this.mapInfo,
    this.extent,
    this.color,
    this.bottomSpace,
    this.onSelect,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? color;
  final String? title;
  final JSON? mapInfo;
  final Function(JSON)? onSelect;

  final TextStyle titleStyle   = TextStyle(fontSize: 12, color: NAVY, fontWeight: FontWeight.w700);
  final TextStyle titleExStyle = TextStyle(fontSize: 8, color: Colors.black38, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: () {
        if (onSelect != null) onSelect!(mapInfo ?? {});
      },
      child: Container(
        height: extent,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color ?? Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (mapInfo == null && title != null)...[
                Text(title!, style: titleStyle, textAlign: TextAlign.center),
              ],
              if (mapInfo != null)...[
                Text(STR(mapInfo!['title_kr']), style: titleStyle, textAlign: TextAlign.center),
                SizedBox(height: 3),
                Text(STR(mapInfo!['title']), style: titleExStyle, textAlign: TextAlign.center),
              ]
              // Text('$index', style: titleStyle),
            ],
          )
        ),
      )
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}

class IceTile extends StatelessWidget {
  IceTile({
    Key? key,
    required this.index,
    this.title,
    this.mapInfo,
    this.extent,
    this.color = Colors.white,
    this.borderColor = NAVY,
    this.bottomSpace,
    this.onSelect,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color color;
  final Color borderColor;
  final String? title;
  final JSON? mapInfo;
  final Function(JSON)? onSelect;

  final TextStyle titleStyle   = TextStyle(fontSize: 12, color: NAVY, fontWeight: FontWeight.w700, shadows: outlinedText(strokeWidth: 0.4, strokeColor: Colors.white));
  final TextStyle titleExStyle = TextStyle(fontSize: 8, color: Colors.blueGrey, fontWeight: FontWeight.w700, shadows: outlinedText(strokeWidth: 0.4, strokeColor: Colors.white));

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: () {
        if (onSelect != null) onSelect!(mapInfo ?? {});
      },
      child: Container(
        height: extent,
        color: color,
        child: Stack(
          children: [
            if (color != Colors.transparent && mapInfo != null)...[
              showImageFit('assets/ui/main/${mapInfo!['id']}.png'),
              BottomCenterAlign(
                child: Container(
                  height: 6,
                  color: borderColor.withOpacity(0.6),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (mapInfo == null && title != null)...[
                      Text(title!, style: titleStyle, textAlign: TextAlign.center),
                    ],
                    if (mapInfo != null)...[
                      if (Get.locale.toString() == 'ko_KR')...[
                        Text(STR(mapInfo!['title_kr']), style: titleStyle, textAlign: TextAlign.center),
                        SizedBox(height: 3),
                        Text(STR(mapInfo!['title']), style: titleExStyle, textAlign: TextAlign.center),
                      ],
                      if (Get.locale.toString() != 'ko_KR')...[
                        Text(STR(mapInfo!['title']), style: titleStyle, textAlign: TextAlign.center),
                      ]
                    ],
                    SizedBox(height: 5),
                    // Text('$index', style: titleStyle),
                  ],
                )
              ),
            ],
          ]
        )
      )
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({
    Key? key,
    required this.index,
    required this.width,
    required this.height,
  }) : super(key: key);

  final int index;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://picsum.photos/$width/$height?random=$index',
      width: width.toDouble(),
      height: height.toDouble(),
      fit: BoxFit.cover,
    );
  }
}

TextCheckBox(BuildContext context, String title, bool value,
    {
      var subTitle = '',
      var padding = EdgeInsets.zero,
      var height = 30.0,
      var textSpace = 10.0,
      var isExpanded = true,
      Color? textColor,
      Function(bool)? onChanged
    }) {
  return Container(
    padding: padding,
    child: Column(
      children: [
        Row(
          children: [
            if (isExpanded)
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: textColor ?? Theme.of(context).primaryColor.withOpacity(0.5), fontWeight: FontWeight.w800)
                ),
              ),
            if (!isExpanded)...[
              Text(
                title,
                style: TextStyle(fontSize: 14, color: textColor ?? Theme.of(context).primaryColor.withOpacity(0.5), fontWeight: FontWeight.w800)
              ),
              SizedBox(width: textSpace),
            ],
            Switch(
              value: value,
              onChanged: onChanged,
            )
          ]
        ),
        if (subTitle.isNotEmpty)...[
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Text(
              subTitle,
              style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600)
            ),
          ),
        ]
      ]
    )
  );
}

// ignore: non_constant_identifier_names
SubTitle(BuildContext context, String title, {double height = 30, double topPadding = 0, double bottomPadding = 0, Widget? child}) {
  return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: SubTitleColor(context), fontWeight: FontWeight.w800)),
          if (child != null)...[
            SizedBox(width: 10.w),
            child
          ]
        ]
      )
  );
}

// ignore: non_constant_identifier_names
SubTitleSmall(BuildContext context, String title, {double height = 30, double topPadding = 0, double bottomPadding = 0, Color? color}) {
  return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Text(title, style: TextStyle(color: color ?? Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500, fontSize: 12))
  );
}

// ignore: non_constant_identifier_names
SubTitleEx(BuildContext context, String text, String desc, [double height = 30, double topPadding = 0, double bottomPadding = 0]) {
  return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Row(
          children: [
            Text(text, style: TextStyle(color: SubTitleColor(context), fontWeight: FontWeight.w800)),
            SizedBox(width: 5),
            Text(desc, style: TextStyle(color: DescColor(context), fontWeight: FontWeight.w600, fontSize: 12)),
          ]
      )
  );
}


// ignore: non_constant_identifier_names
RoundRectButton(String title, double? height, Function()? onPressed) {
  final _titleStyle  = TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16);
  return SizedBox(
    height: height ?? 40,
    child: ElevatedButton(
      onPressed: () {
        if (onPressed != null) onPressed();
      },
      child: Text(title, style: _titleStyle),
      style: ElevatedButton.styleFrom(
          primary: Colors.white,
          minimumSize: Size.zero, // Set this
          padding: EdgeInsets.symmetric(horizontal: 15), // and this
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey, width: 2)
          )
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
RoundRectButtonEx(BuildContext context, String title, {double height = 40, double? width, bool isEnabled = true, Function()? onPressed}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      onPressed: () {
        if (isEnabled && onPressed != null) onPressed();
      },
      child: Text(title, style: isEnabled ? ItemButtonNormalStyle(context) : ItemButtonDisableStyle(context)),
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.25),
          minimumSize: Size.zero, // Set this
          padding: EdgeInsets.symmetric(horizontal: 15), // and this
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              // side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(isEnabled ? 0.5 : 0.2), width: 2)
          )
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
ShowImageCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.square,
    CropAspectRatioPreset.ratio3x2,
    CropAspectRatioPreset.original,
    CropAspectRatioPreset.ratio4x3,
    CropAspectRatioPreset.ratio16x9
  ];
  return await startImageCroper(imageFilePath, CropStyle.rectangle, preset, CropAspectRatioPreset.original, false);
}

// ignore: non_constant_identifier_names
ShowUserPicCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.square,
  ];
  return await startImageCroper(imageFilePath, CropStyle.circle, preset, CropAspectRatioPreset.square, false);
}

// ignore: non_constant_identifier_names
ShowBannerImageCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.ratio16x9
  ];
  return await startImageCroper(imageFilePath, CropStyle.rectangle, preset, CropAspectRatioPreset.ratio16x9, false);
}

startImageCroper(String imageFilePath, CropStyle cropStyle, List<CropAspectRatioPreset> preset, CropAspectRatioPreset initPreset, bool lockAspectRatio) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    cropStyle: cropStyle,
    sourcePath: imageFilePath,
    aspectRatioPresets: preset,
    maxWidth: 1024,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Image size edit'.tr,
          toolbarColor: Colors.purple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: initPreset,
          lockAspectRatio: lockAspectRatio),
      IOSUiSettings(
        title: 'Image size edit'.tr,
      ),
    ],
  );
  return croppedFile?.path;
}

Future resizeImage(Uint8List data, double maxSize) async {
  Uint8List? resizedData = data;
  try {
    var img = IMG.decodeImage(data);
    bool isResized = false;
    if (img != null) {
      var nWidth  = img.width.toDouble();
      var nHeight = img.height.toDouble();
      if (nWidth > nHeight) {
        if (nWidth > maxSize) {
          nWidth = maxSize;
          nHeight *= nWidth / img.width;
          isResized = true;
        }
      } else {
        if (nHeight > maxSize) {
          nHeight = maxSize;
          nWidth *= nHeight / img.height;
          isResized = true;
        }
      }
      if (isResized) {
        LOG('--> resize : ${img.width} x ${img.height} => $nWidth x $nHeight');
        img = IMG.copyResize(img, width: nWidth.toInt(), height: nHeight.toInt());
      }
      resizedData = IMG.encodeJpg(img, quality: 100) as Uint8List?;
      return resizedData;
    }
  } catch (e) {
    LOG('--> resize error : $e');
    return resizedData;
  }
}

class _Chip extends StatelessWidget {
  _Chip({
    required this.label,
    required this.onDeleted,
    required this.index,
    this.enabled = true,
    this.headText = '',
    this.onSelected
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final ValueChanged<int>? onSelected;
  final int index;
  String headText;
  bool enabled;

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return Chip(
        backgroundColor: Theme
            .of(context)
            .canvasColor,
        useDeleteButtonTooltip: false,
        labelPadding: EdgeInsets.fromLTRB(5, 2, 0, 2),
        label: Text(label),
        deleteIcon: Icon(Icons.close, size: 18),
        deleteIconColor: Colors.grey,
        onDeleted: () {
          onDeleted(index);
        },
      );
    } else {
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: Text('$headText$label'),
        ),
        onTap: () {
          if (onSelected != null) onSelected!(index);
        },
      );
    }
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

TagTextList(BuildContext context, List<String> tagList, {String headTitle = '', bool showBackground = true, Function(String)? onSelected}) {
  List<Widget> chipList = [];
  for (var item in tagList) {
    if (item.isNotEmpty) {
      chipList.add(GestureDetector(
          onTap: () {
            if (onSelected != null) onSelected(item);
          },
          child: Container(
            padding: showBackground ? EdgeInsets.symmetric(horizontal: 10, vertical: 5) : EdgeInsets.zero,
            margin: EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
                color: showBackground ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: Text('$headTitle$item',
                style: showBackground ? ItemTitleExStyle(context) :
                headTitle == '#' ? DescBodyExStyle(context) :  DescBodyExStyle(context)),
          )
      )
      );
    }
  }
  return Wrap(
    spacing: 5,
    children: chipList,
  );
}

TagTextField(List<String>? tagList, Function(List<String>)? onChanged) {
  return TagTextEditField(tagList, 'Search Tag'.tr, '', true, onChanged);
}

TagTextEditField(List<String>? tagList, String hintText, String disabledHeadText, bool enabled, Function(List<String>)? onChanged, {Function(int, String)? onSelected}) {
  tagList ??= [];
  return StatefulBuilder(
      builder: (context, setState) {
        return TagEditor(
            length: tagList!.length,
            delimiters: const [',', '/', '#', ' '],
            hasAddButton: true,
            resetTextOnSubmitted: true,
            enabled: enabled,
            minTextFieldWidth: enabled ? 160 : 0,
            inputDecoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(5),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14),
              hoverColor: Theme.of(context).primaryColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Colors.transparent),
              ),          ),
            onTagChanged: (newValue) {
              setState(() {
                tagList!.add(newValue);
                if (onChanged != null) onChanged(tagList);
              });
            },
            tagBuilder: (context, index) => _Chip(
              index: index,
              label: tagList![index],
              enabled : enabled,
              headText: disabledHeadText,
              onDeleted: (index) {
                setState(() {
                  tagList!.removeAt(index);
                  if (onChanged != null) onChanged(tagList);
                });
              },
              onSelected: (index) {
                if (onSelected != null) onSelected(index, tagList![index]);
              },
            )
        );
      }
  );
}

unFocusAll(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
  // for (var item in AppData.searchWidgetKey) {
  //   if (item.currentState != null) {
  //     var state = item.currentState as SearchWidgetState;
  //     state.clearFocus(false);
  //   }
  // }
}

// ignore: non_constant_identifier_names
OutlineIcon(IconData icon, double size, Color color, {var shadowColor = Colors.black54, double x = 1, double y = 1,}) {
  return Container(
      width: size + 2,
      height: size + 2,
      child: Stack(
        alignment: Alignment.center,
          children: [
            Positioned(
              left: x-1,
              top: y-1,
              child: Icon(icon, size: size, color: shadowColor),
            ),
            Positioned(
              left: x-1,
              top: y+1,
              child: Icon(icon, size: size, color: shadowColor),
            ),
            Positioned(
              left: x+1,
              top: y-1,
              child: Icon(icon, size: size, color: shadowColor),
            ),
            Positioned(
              left: x+1,
              top: y+1,
              child: Icon(icon, size: size, color: shadowColor),
            ),
            Positioned(
              left: x-1,
              top: y,
              child: Icon(icon, size: size, color: shadowColor),
            ),
            Positioned(
              left: x+1,
              top: y,
              child: Icon(icon, size: size, color: shadowColor),
            ),
            Positioned(
              left: x,
              top: y+1,
              child: Icon(icon, size: size, color: shadowColor),
            ),
            Positioned(
              left: x,
              top: y-1,
              child: Icon(icon, size: size, color: shadowColor),
            ),
            Positioned(
              left: x,
              top: y,
              child: Icon(icon, size: size, color: color),
            ),
          ]
      )
  );
}

Widget showSendMessageWidget(BuildContext context, UserModel targetInfo, {double iconSize = 20, String title = '', Function(int)? onChangeCount}) {
  // LOG('--> ShowBookmarkWidget : $type / $targetId / $targetPic');
  var _iconColor = Theme.of(context).primaryColor;

  return Container(
    width: title.isNotEmpty ? 50 : 30,
    height: title.isNotEmpty ? 60 : 40,
    child: Center (
      child: GestureDetector(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message_outlined, color: _iconColor, size: iconSize),
              if (title.isNotEmpty)...[
                Text(title, style: ItemDescExStyle(context))
              ]
            ]
        ),
        onTap: () {
          startChattingScreen(context, targetInfo);
        },
      ),
    ),
  );
}

startChattingScreen(BuildContext context, UserModel targetInfo) async {
  final api = Get.find<ApiService>();
  var searchText = '';
  // await api.getMessageData();
  // AppData.refreshMessageGroup(0, _searchText);
  // var targetId = STR(targetInfo['id']);
  // LOG('--> AppData.messageGroup [$targetId] : $targetInfo');
  // Navigator.push(context, MaterialPageRoute(builder: (context) =>
  //     ChattingScreen(
  //         0,
  //         List<JSON>.from(AppData.messageGroup[targetId] ?? {}),
  //         targetInfo['id'],
  //         targetInfo['nickName'],
  //         targetInfo['pic'],
  //         key: AppData.newMessageKey))).then((value) {
  // });
}

Widget showPlaceAddButton(BuildContext context, Size size, Function onRefresh) {
  return Container(
    width: size.width,
    height: size.height,
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.25),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: GestureDetector(
          onTap: () {
            AppData.listSelectData.clear();
            Get.to(() => PlaceListScreen())!.then((result) {

            });
              // Navigator.push(context, MaterialPageRoute(
              //     builder: (context) => EventListScreen(isSelectable: true, topTitle: "EVENT SELECT".tr))).then((result) {
              //   onRefresh();
              // });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_outlined, color: Theme.of(context).primaryColor.withOpacity(0.5), size: 18),
              Text('Select'.tr, style: DescBodyInfoStyle(context, 0.8), textAlign: TextAlign.center)
            ],
          ),
        )
    ),
  );
}

Widget showIconButton(Widget icon, Function()? onTap, [Size? size]) {
  var _width  = size != null ? size.width   : 40.0;
  var _height = size != null ? size.height  : 30.0;
  return GestureDetector(
    onTap: () {
      if (onTap != null) onTap();
    },
    child: Container(
      width: _width,
      height: _height,
      padding: EdgeInsets.all(5),
      color: Colors.transparent,
      child: icon,
    ),
  );
}

checkPromotionDateRangeFromData(JSON item, [String type = 'promotion_listTop']) {
  if (item[type] == null) return false;
  return INT(item[type]['status']) > 0 &&
      checkPromotionDateRange(STR(item[type]['startDate']), STR(item[type]['endDate']));
}

checkPromotionDateRange(String startDate, String endDate, [DateTime? targetTime]) {
  LOG('--> checkPromotionDateRange: $startDate / $endDate');
  try {
    var start = DateTime.parse(startDate);
    var end   = DateTime.parse(endDate);
    return checkDateRange(start, end, targetTime);
  } catch (e) {
    LOG('--> checkPromotionDateRange error: $e');
  }
  return false;
}

checkDateRange(DateTime start, DateTime end, [DateTime? targetTime]) {
  // LOG('--> checkDateRange: $start / $end - $targetTime');
  var now = targetTime ?? DateTime.now();
  // LOG('--> now.compareTo : ${now.compareTo(start)} / ${now.compareTo(end)}');
  return now.compareTo(start) > 0 && now.compareTo(end) < 0;
}

Widget ContentTypeSelectWidget(BuildContext context, String selectId, Function(String) onChanged) {
  if (selectId.isEmpty) selectId = AppData.INFO_CONTENT_TYPE.entries.first.key;
  List<JSON> itemList = [];
  // set category group dropdown
  for (var item in AppData.INFO_CONTENT_TYPE.entries) {
    itemList.add({
      'key': item.key,
      'title': STR(item.value['title']).toString().tr,
    });
  }
  LOG('--> ContentTypeSelectWidget : $selectId - $itemList');
  return Container(
      height: 60,
      child: Row(
        children: [
          DropDownMenuWidget(itemList, selectKey: selectId, onSelected: (key) {
            onChanged(key);
          }),
        ],
      )
  );
}

Future<String> loadTerms() async {
  return await rootBundle.loadString('assets/html/terms_0.html');
}

Future<String> loadCondition() async {
  return await rootBundle.loadString('assets/html/terms_1.html');
}

contentAddButton(context, title, {
    EdgeInsets padding = EdgeInsets.zero,
    var icon = Icons.add_outlined,
    var height = 60.0,
    Function(String)? onPressed,
  }) {
  return Container(
      padding: padding,
      constraints: BoxConstraints(
        minHeight: height,
      ),
      child: ElevatedButton(
        onPressed: () {
          if (onPressed != null) onPressed(title);
        },
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor.withOpacity(0.25),
            minimumSize: Size.zero, // Set this
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            SizedBox(height: 3),
            Text(title, style: ItemDescStyle(context), maxLines: 3, textAlign: TextAlign.center)
          ],
        ),
      )
  );
}

showGroupTabWidget(context, onUpdate, Widget? child) {
  return Container(
      width: MediaQuery.of(context).size.width,
      height: 40,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                EventGroupSelectDialog(context,
                    AppData.currentEventGroup!.id,
                    AppData.currentContentType).then((_) {
                  onUpdate();
                });
              },
              child: Row(
                children: [
                  if (AppData.currentEventGroup!.pic.isNotEmpty)...[
                    showImage(AppData.currentEventGroup!.pic, Size(30, 30)),
                    // getCircleImage(AppData.currentPlaceGroup['pic'], 30),
                    SizedBox(width: 8),
                  ],
                  Text(STR(AppData.currentEventGroup!.title).toString().toUpperCase(),
                      style: AppBarTitleStyle(context)),
                ],
              ),
            ),
          ),
          if (child != null)
            child,
        ],
      )
  );
}

// ignore: must_be_immutable
class ListItemEx extends StatelessWidget {
  ListItemEx(this.id, this.title, {Key? key,
    this.titleEx = '', this.itemHeight = 50, this.isTitle = false, this.isLast = false,
    this.callback}) : super(key: key);
  String id;
  String title;
  String titleEx;
  double itemHeight;
  bool isTitle;
  bool isLast;
  Function(String)? callback;

  @override
  Widget build(BuildContext context) {
    if (isTitle) {
      return Container(
          height: 50,
          color: Colors.grey.withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(title, style: ItemTitleLargeStyle(context)),
            ],
          )
      );
    } else {
      return GestureDetector(
          onTap: () {
            LOG("--> ListItemEx onTap : $id -> $title");
            if (callback != null) callback!(id);
          },
          child: Container(
              height: itemHeight,
              color: Colors.transparent,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Text(title, style: callback != null ? ItemTitleLargeStyle(context) : ItemTitleLargeDisableStyle(context)),
                            if (titleEx.isNotEmpty)...[
                              SizedBox(width: 10),
                              Text(titleEx, style: ItemTitleStyle(context)),
                            ],
                            Expanded(child: SizedBox(height: 1)),
                            if (callback != null)
                              Icon(Icons.arrow_forward_ios, color: Theme.of(context).hintColor.withOpacity(0.2)),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 2,
                        color: Theme.of(context).dividerColor,
                        indent: 0,
                        endIndent: 0,
                      ),
                  ]
              )
          )
      );
    }
  }
}

// ignore: non_constant_identifier_names
RoundRectIconTextButton(BuildContext context, String title, IconData icon, Function()? onPressed) {
  // final _titleStyle  = TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14);
  return Container(
    height: 40,
    child: ElevatedButton(
      onPressed: () {
        if (onPressed != null) onPressed();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          SizedBox(width: 5),
          Text(title, style: TextStyle(color: Theme.of(context).primaryColor)),
        ],
      ),
      style: ElevatedButton.styleFrom(
          minimumSize: Size.zero, // Set this
          padding: EdgeInsets.symmetric(horizontal: 15), // and this
          shadowColor: Colors.transparent,
          primary: Theme.of(context).primaryColor.withOpacity(0.25),
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5))
          )
      ),
    ),
  );
}

RoundRectIconButton(IconData icon, double height, Function()? onPressed) {
  return RoundColorRectIconButton(icon, height, Colors.grey, 1, onPressed);
}

// ignore: non_constant_identifier_names
RoundColorRectIconButton(IconData icon, double height, Color color, double width, Function()? onPressed) {
  return Container(
    height: height,
    child: ElevatedButton(
      onPressed: () {
        if (onPressed != null) onPressed();
      },
      child: Icon(icon, size: height * 0.8, color: color),
      style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: Colors.white,
          minimumSize: Size.zero, // Set this
          padding: EdgeInsets.symmetric(horizontal: 10), // and this
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color, width: width)
          )
      ),
    ),
  );
}

IconButtonWidget(IconData icon, double size, Color color, Function()? onPressed) {
  return GestureDetector(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Icon(icon, size: size - 10, color: color),
    ),
    onTap: () {
      if (onPressed != null) onPressed();
    },
  );
}

// ignore: non_constant_identifier_names
CheckOwner(dynamic userId) {
  if (userId == null) return false;
  return AppData.USER_ID == userId;
}

// ignore: non_constant_identifier_names
CheckManager(JSON jsonData) {
  if (JSON_EMPTY(jsonData)) return false;
  if (STR(jsonData['userId']) == AppData.USER_ID) return true;
  if (LIST_NOT_EMPTY(jsonData['managerData'])) {
    for (var item in jsonData['managerData']) {
      if (STR(item['id']) == AppData.USER_ID) return true;
    }
  }
  // if (JSON_NOT_EMPTY(jsonData['guestData'])) {
  //   if (jsonData['guestData'].containsKey(AppData.USER_ID)) return true;
  // }
  return false;
}

// ignore: non_constant_identifier_names
REMIAN_TIME(DateTime dateTime, [String tailText = '']) {
  if (dateTime.isAfter(DateTime.now())) return '';
  var remainTime = DateTime.now().difference(dateTime);
  // LOG('--> remainTime : $dateTime / $remainTime');
  return remainTime.inDays == 365 ? '1 ${'year'.tr}$tailText' :
  remainTime.inDays > 365 ? '${(remainTime.inDays / 365).round()} ${'years'.tr}$tailText' :
  remainTime.inDays == 30 ? '1 ${'month'.tr}$tailText' :
  remainTime.inDays > 30 ? '${(remainTime.inDays / 30).round()} ${'months'.tr}$tailText' :
  remainTime.inDays == 1 ? '1 ${'day'.tr}$tailText' :
  remainTime.inDays > 0 ? '${remainTime.inDays} ${'days'.tr}$tailText' :
  remainTime.inHours == 1 ? '1 ${'hour'.tr}$tailText' :
  remainTime.inHours > 0 ? '${remainTime.inHours} ${'hours'.tr}$tailText' :
  remainTime.inMinutes == 1 ? '1 ${'minute'.tr}$tailText' :
  remainTime.inMinutes > 0 ? '${remainTime.inMinutes} ${'minutes'.tr}$tailText' :
  '${remainTime.inSeconds} ${'sec'.tr}';
}

// ignore: non_constant_identifier_names
REMIAN_TIME_STYLE(DateTime dateTime, TextStyle style, TextStyle styleNow) {
  if (dateTime.isAfter(DateTime.now())) return style;
  var remainTime = DateTime.now().difference(dateTime);
  // LOG('--> remainTime : $dateTime / $remainTime');
  return remainTime.inHours > 0 ? style : styleNow;
}

REMIAN_TIME_TEXTSPAN(DateTime dateTime, [
  TextStyle style = const TextStyle(fontSize: 12),
  TextStyle styleNow = const TextStyle(fontSize: 12), String tailText = '']) {
  return TextSpan(text: REMIAN_TIME(dateTime, tailText), style: REMIAN_TIME_STYLE(dateTime, style, styleNow));
}

// ignore: non_constant_identifier_names
CreateSearchWordList(JSON jsonData) {
  var checkItem = ['title', 'desc'];
  List<String> result = [];
  for (var item in checkItem) {
    result.addAll(CreateSearchWordItem(jsonData[item]));
  }
  return result;
}

// ignore: non_constant_identifier_names
CreateSearchWordItem(String? text) {
  List<String> result = [];
  if (text != null && text.isNotEmpty) {
    var array = text.split(' ');
    for (var item in array) {
      var addItem = item.toString();
      if (addItem.length > 1) {
        result.add(item.toString());
        var removedItem = RemoveSearchWordItem(item);
        if (removedItem.length > 1 && !result.contains(removedItem)) result.add(removedItem);
        // debugPrint('--> [$text] : $result / $removedItem');
      }
    }
  }
  return result;
}

// ignore: non_constant_identifier_names
String RemoveSearchWordItem(String text) {
  debugPrint('--> remove word: $text');
  if (text.length > 1) {
    var checkWord = ['있습니다','합니다','입니다','팝니다','갑니다','옴니다','부터','은','는','이','가','을','를','와','과',',','!','?','.'];
    for (var word in checkWord) {
      if (text.length > word.length) {
        var item = text.substring(text.length - word.length, text.length);
        if (item == word) {
          debugPrint('--> check: $item / $word -> $text / ${text.substring(0, text.length - word.length)}');
          return RemoveSearchWordItem(text.substring(0, text.length - word.length));
        }
      }
    }
    return text;
  }
  return '';
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day &&
        now.month == month &&
        now.year == year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  int get weekOfMonth {
    var date = this;
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    // int sum = (firstDayOfMonth.weekday == 7 ? 1 : firstDayOfMonth.weekday - 1) + date.day;
    int sum = firstDayOfMonth.weekday - 1 + date.day;
    if (sum % 7 == 0) {
      return sum ~/ 7;
    } else {
      return sum ~/ 7 + 1;
    }
  }

  int get lastWeek {
    var date = this;
    var lastDay = DateTime(date.year, date.month + 1, 0);
    return lastDay.weekOfMonth;
  }

  bool isSameDay(DateTime target) {
    return target.year == year && target.month == month && target.day == day;
  }

  DateTime applyTimeOfDay({required int hour, required int minute}) {
    return DateTime(year, month, day, hour, minute);
  }
}

extension MapHelpers on Map {
  bool compareTo(Map target) {
    if (length != target.length) return false;
    for (var item in target.entries) {
      if (!containsKey(item.key)) return false;
    }
    return true;
  }
}

extension ListHelpers on List {
  bool equals(List list) {
    if(length!=list.length) return false;
    return every((item) => list.contains(item));
  }
}

bool checkDateTimeShow(JSON? timeData, DateTime checkDate) {
  if (timeData == null) return false;
  // var _defaultBgColor = Colors.blueGrey;
  for (var item in timeData.entries) {
    // var eventId = item.value['eventId'] ?? '';
    // var placeId = item.value['placeId'] ?? '';
    // LOG('--> timeList.entries item : ${item.value['day']}');
    if (LIST_NOT_EMPTY(item.value['day'])) {
      for (var time in item.value['day']) {
        var startDate = DateTime.parse(time);
        // LOG('--> Day check : ${startDate.toString().split(' ').first} / ${checkDate.toString().split(' ').first}');
        if (startDate.toString().split(' ').first == checkDate.toString().split(' ').first) return true;
        // var dayStr = startDate.toString().split(' ').first;
        // var markColor = COL(item.value['themeColor'], defaultValue:_defaultBgColor);
        // var appoint = setCalendarDaySource(item.key, eventId, placeId, dayStr, item.value, markColor);
        // if (appoint != null) appointments.add(appoint);
      }
      return false;
    } else {
      // LOG('--> Date Range init : ${item.value['startDate']} ~ ${item.value['endDate']}');
      if (STR(item.value['startDate']).isEmpty) item.value['startDate'] = DateTime.now().toString().split(' ').first;
      var startDate = DateTime.parse(STR(item.value['startDate']));
      if (STR(item.value['endDate']).isEmpty) item.value['endDate'] = startDate.add(Duration(days: 364)).toString().split(' ').first;
      var endDate = DateTime.parse(STR(item.value['endDate']));
      var duration  = endDate.difference(startDate).inDays + 1;
      // LOG('--> Date Range : ${item.value['startDate']} ~ ${item.value['endDate']} => $duration / ${item.value['week']}');
      for (var i=0; i<duration; i++) {
        var day = startDate.add(Duration(days: i));
        var dayStr = day.toString().split(' ').first;
        var isShow = item.value['exceptDay'] == null || !item.value['exceptDay'].contains(dayStr);
        if (isShow && LIST_NOT_EMPTY(item.value['week']) && !item.value['week'].contains(weekText.first)) {
          var wm = day.weekOfMonth;
          isShow = ((wm < weekText.length && item.value['week'].contains(weekText[wm])) || wm >= weekText.length) &&
              (wm == day.lastWeek && item.value['week'].contains(weekText.last) || wm != day.lastWeek);
          // LOG('--> week [$dayStr / ${day.weekday}] : $wm / ${day.lastWeek} => $isShow');
        }
        if (isShow && LIST_NOT_EMPTY(item.value['dayWeek']) && !item.value['dayWeek'].contains(dayWeekText.first)) {
          var wm = day.weekday;
          isShow = item.value['dayWeek'].contains(dayWeekText[wm]);
          // LOG('--> weekday [$dayStr] : $wm / ${dayWeekText[wm]} => $isShow');
        }
        if (isShow) {
          return true;
          // var markColor = COL(item.value['themeColor'], defaultValue:_defaultBgColor).withOpacity(0.75);
          // var appoint = setCalendarDaySource(item.key, eventId, placeId, dayStr, item.value, markColor);
          // if (appoint != null) {
          //   appointments.add(appoint);
          // }
        } else {
          // LOG('--> exceptDayData : $dayStr');
        }
      }
    }
  }
  return false;
}

showDatePickerText(BuildContext context, DateTime date) {
  String month     = DateFormat.M(Get.locale.toString()).format(date);
  String dayOfWeek = DateFormat.E(Get.locale.toString()).format(date);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          DateMonthText(context, month, color: Theme.of(context).hintColor),
          DateWeekText (context, dayOfWeek, color: Theme.of(context).indicatorColor),
        ],
      ),
      SizedBox(width: 5),
      DateDayText(context, '${date.day}', fontSize: UI_FONT_SIZE_LT, color: Theme.of(context).indicatorColor),
    ],
  );
}


showAgreeStep(context, viewModel) {
  var textColor = Theme.of(context).hintColor;
  return LayoutBuilder(
      builder: (context, layout) {
        return Container(
            height: layout.maxHeight,
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: FutureBuilder(
                                future: loadTerms(),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return Html(
                                        data: snapshot.data,
                                        style: {
                                          "p" : Style(color: textColor),
                                          "h2": Style(color: textColor),
                                          "h3": Style(color: textColor),
                                          "h4": Style(color: textColor),
                                        }
                                    );
                                  } else {
                                    return Center(
                                      child: showLoadingCircleSquare(50),
                                    );
                                  }
                                }
                            )
                        )
                    )
                ),
                if (!viewModel.isShowOnly)...[
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Checkbox(
                          value: viewModel.agreeChecked,
                          onChanged: (status) {
                            viewModel.setCheck(status ?? false);
                          }
                      ),
                      Text(
                        'I agree to the Privacy Policy'.tr,
                        style: ItemTitleStyle(context),
                      )
                    ],
                  ),
                ]
              ],
            )
        );
      }
  );
}

inputChatSuffix(BuildContext context) {
  return InputDecoration(
    filled: true,
    isDense: true,
    fillColor: Theme.of(context).dividerColor,
    contentPadding: EdgeInsets.all(10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(color: Theme.of(context).indicatorColor.withOpacity(0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(color: Theme.of(context).indicatorColor.withOpacity(0.8)),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(color: Theme.of(context).indicatorColor.withOpacity(0.5)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(color: Theme.of(context).errorColor),
    ),
  );
}

COMPARE_GROUP_COUNTRY(JSON s) {
  return s['groupId'] == AppData.currentEventGroup!.id &&
         s['country'] == AppData.currentCountry &&
         (AppData.currentState.isEmpty || s['countryState'] == AppData.currentState);
}

final extImageList = [
  'gif',
  'jpg',
  'jpeg',
  'png',
  'bmp',
  'tif',
  'tiff',
];

IS_IMAGE_FILE(String? ext) {
  if (ext == null) return false;
  return extImageList.contains(ext.toLowerCase());
}

class StatefulWrapper extends StatefulWidget {
  final Function onInit;
  final Widget child;
  const StatefulWrapper({required this.onInit, required this.child});
  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper> {
  @override
  void initState() {
    if(widget.onInit != null) {
      widget.onInit();
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

getFileSavePath() async {
  var tempDir = '';
  bool dirDownloadExists = true;
  if (Platform.isIOS) {
    var dir = await getDownloadsDirectory();
    if (dir == null) return;
    tempDir = dir.path;
  } else {
    tempDir = "/storage/emulated/0/Download/";
    dirDownloadExists = await Directory(tempDir).exists();
    if(dirDownloadExists){
      tempDir = "/storage/emulated/0/Download/";
    }else{
      tempDir = "/storage/emulated/0/Downloads/";
    }
  }
  return tempDir;
}

Route createAniRoute(Widget target) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => target,
    transitionDuration: Duration(milliseconds: ROUTE_ANI_DURATION),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end   = Offset.zero;
      var curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
