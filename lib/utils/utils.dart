import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:helpers/helpers.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:image/image.dart' as IMG;
import 'package:material_tag_editor/tag_editor.dart';

import '../data/app_data.dart';
import '../data/common_colors.dart';
import '../data/common_sizes.dart';
import '../data/style.dart';

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
  return value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? value!.toString() : defaultValue;
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
    result = value != null && value != 'null' && value!.toString().isNotEmpty
        ? value is String ? DateTime.parse(value.toString()) : DateTime.fromMillisecondsSinceEpoch(value['_seconds']*1000)
        : defaultValue != null && defaultValue != ''
        ? DateTime.parse(defaultValue!.toString())
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
String SERVER_TIME_STR(value) {
  if (value == null) return '';
  var format = DateFormat('yyyy-MM-dd hh:mm:ss');
  var date = TME(value);
  if (date != null) {
    return format.format(date).toString();
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
DESC(dynamic desc) {
  var tmp = desc != null ? desc.replaceAll('\\n', '\n') : '';
  return STR(tmp);
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
  LOG("--> JSON_START_DAY_SORT_DESC : ${data.length}");
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return INT(data[a]['startDay']) > INT(data[b]['startDay']) ? -1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_CREATE_TIME_SORT_DESC(JSON data) {
  LOG("--> JSON_CREATE_TIME_SORT_DESC : ${data.length}");
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return data[a]['createTime'] != null && data[b]['createTime'] != null ?
    data[a]['createTime']['_seconds'] > data[b]['createTime']['_seconds'] ? -1 : 1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_UPDATE_TIME_SORT_DESC(JSON data) {
  LOG("--> JSON_UPDATE_TIME_SORT_DESC : ${data.length}");
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return data[a]['updateTime'] != null && data[b]['updateTime'] != null ?
    data[a]['updateTime']['_seconds'] > data[b]['updateTime']['_seconds'] ? -1 : 1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_CREATE_TIME_SORT_ASCE(JSON data) {
  // LOG("--> JSON_CREATE_TIME_SORT_DESC : $data");
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return data[a]['createTime'] != null && data[b]['createTime'] != null ?
    data[a]['createTime']['_seconds'] > data[b]['createTime']['_seconds'] ? 1 : -1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_TARGET_DATE_SORT_ASCE(JSON data) {
  LOG("--> JSON_TARGET_DATE_SORT_ASCE : $data");
  try {
    if (JSON_EMPTY(data)) return {};
    if (data.length < 2) return data;
    return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
      // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
      return DateTime.parse(STR(data[a]['targetDate'])).compareTo(DateTime.parse(STR(data[b]['targetDate']))).isNegative ? -1 : 1;
    }));
  } catch (e) {
    LOG("--> JSON_TARGET_DATE_SORT_ASCE error : $e");
  }
  return data;
}

// ignore: non_constant_identifier_names
JSON_INDEX_SORT_ASCE(JSON data) {
  // LOG("--> JSON_INDEX_SORT_ASCE : $data");
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return data[a]['index'] != null && data[b]['index'] != null ?
    INT(data[a]['index']) > INT(data[b]['index']) ? 1 : -1 : 0;
  }));
}

// ignore: non_constant_identifier_names
LIST_CREATE_TIME_SORT_DESC(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['createTime'] != null && b['createTime'] != null ?
  a['createTime']['_seconds'] > b['createTime']['_seconds'] ? -1 : 1 : 1);
  return data;
}

// ignore: non_constant_identifier_names
LIST_CREATE_TIME_SORT_ASCE(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['createTime'] != null && b['createTime'] != null ?
  a['createTime']['_seconds'] > b['createTime']['_seconds'] ? 1 : -1 : 1);
  return data;
}

// ignore: non_constant_identifier_names
LIST_START_TIME_SORT(List<JSON> data) {
  LOG("--> LIST_START_TIME_SORT : $data");
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['startTime'] != null && b['startTime'] != null ?
  a['startTime']['_seconds'] > b['startTime']['_seconds'] ? 1 : -1 : 1);
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
LIST_EMPTY(dynamic data) {
  if (data == null) return false;
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
  // LOG('--> showImageWidget : $imagePath');
  try {
    if (imagePath != null && imagePath.runtimeType == String && imagePath
        .toString()
        .isNotEmpty) {
      var url = imagePath.toString();
      if (url.contains("http")) {
        return CachedNetworkImage(
          fit: fit,
          color: color,
          imageUrl: url,
          progressIndicatorBuilder: (context, url, progress) => CircularProgressIndicator(value: progress.progress),
        );
      } else if (url.contains('/cache')) {
        return Image.file(File(url), color: color);
      } else {
        return Image.asset(url, fit: fit, color: color);
      }
    } else if (imagePath.runtimeType == Uint8List) {
      return Image.memory(imagePath as Uint8List, fit: fit, color: color);
    }
  } catch (e) {
    LOG('--> showImage Error : $e');
  }
  return Image.asset(NO_IMAGE);
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

Widget showLoadingImage() {
  return showLoadingImageSquare(50.0);
}

Widget showLoadingImageSize(Size size) {
  return Container(
    width: size.width,
    height: size.height,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(8))
    ),
  );
}

Widget showLoadingImageSquare(double size) {
  return Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(8))
    ),
  );
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

Widget showLoadingPage(BuildContext context, int offset) {
  var size = 50.0;
  return LayoutBuilder(
    builder: (context, layout) {
      return Container(
        width:  layout.maxWidth,
        height: layout.maxHeight - offset,
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
      {Key ? key, this.color = Colors.grey, this.thickness = 1})
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
              color: color,
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

inputLabel(BuildContext context, String label, String hint, {double width = 2}) {
  return inputLabelSuffix(context, label, hint, width:width);
}

inputLabelSuffix(BuildContext context, String label, String hint, {String suffix = '', bool isEnabled = true, double width = 1}) {
  return InputDecoration(
    filled: true,
    isDense: true,
    alignLabelWithHint: true,
    hintText: hint,
    suffixText: suffix,
    labelText: label,
    enabled: isEnabled,
    contentPadding: EdgeInsets.all(10),
    hintStyle: TextStyle(color: Theme.of(context).hintColor.withOpacity(0.5), fontSize: 14),
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

ShowToast(text, [Color backColor = Colors.black45, Color textColor = Colors.white]) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: backColor,
      textColor: textColor,
      fontSize: 14.0
  );
}

ShowErrorToast(text)  {
  ShowToast(text, Colors.black45, Colors.deepPurpleAccent);
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

  message,
  unfollow,
  block,
  report,
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

  promotion,
  stop,
  pay,
}

class DropdownItem {
  final DropdownItemType type;
  final String? text;
  final IconData? icon;
  final bool isLine;
  final double height;
  final bool color;
  final bool alert;

  const DropdownItem(
      this.type,
      {
        this.text,
        this.icon,
        this.isLine = false,
        this.height = 40,
        this.color = false,
        this.alert = false,
      }
      );
}

class DropdownItems {
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

  static const content      = DropdownItem(DropdownItemType.content, text: 'HISTORY +', icon: Icons.movie_creation);
  static const talent       = DropdownItem(DropdownItemType.talent, text: 'TALENT +', icon: Icons.star);
  static const goods        = DropdownItem(DropdownItemType.goods, text: 'GOODS +', icon: Icons.card_giftcard);
  static const live         = DropdownItem(DropdownItemType.live, text: 'LIVE +', icon: Icons.live_tv);

  static const placeGroup   = DropdownItem(DropdownItemType.placeGroup, text: 'SPOT GROUP +', icon: Icons.map_outlined);
  static const place        = DropdownItem(DropdownItemType.place, text: 'SPOT +', icon: Icons.place_outlined);
  static const event        = DropdownItem(DropdownItemType.event, text: 'EVENT +', icon: Icons.event_available);
  static const story        = DropdownItem(DropdownItemType.story, text: 'STORY +', icon: Icons.school_outlined);

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
    final color = item.alert ? Theme.of(context).colorScheme.error : item.color ? Theme.of(context).primaryColor : Theme.of(context).hintColor;
    final style = item.alert ? itemTitleAlertStyle : item.color ? itemTitleColorStyle : itemTitleStyle;
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
      Function(bool)? onChanged
    }) {
  return Container(
      padding: padding,
      child: Column(
          children: [
            Container(
                height: height,
                padding: padding,
                child: Row(
                    children: [
                      Expanded(
                        child: Text(
                            title,
                            style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor.withOpacity(0.5), fontWeight: FontWeight.w800)),
                      ),
                      Switch(
                        value: value,
                        onChanged: onChanged,
                      )
                    ]
                )
            ),
            if (subTitle.isNotEmpty)...[
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    // border: Border.all(color: Colors.grey),
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
SubTitle(BuildContext context, String title, {double height = 40, double topPadding = 0, double bottomPadding = 0, Widget? child}) {
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
SubTitleSmall(BuildContext context, String title, [double height = 30, double topPadding = 0, double bottomPadding = 0]) {
  return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500, fontSize: 12))
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
RoundRectButtonEx(BuildContext context, String title, {double height = 40, bool isEnabled = true, Function()? onPressed}) {
  return SizedBox(
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
              side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(isEnabled ? 0.5 : 0.2), width: 2)
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

TagTextField(List<String>? tagList, Function(List<String>)? onChanged) {
  return TagTextEditField(tagList, 'Tag'.tr, '', true, onChanged);
}

TagTextEditField(List<String>? tagList, String hintText, String disabledHeadText, bool enabled, Function(List<String>)? onChanged, {Function(int, String)? onSelected}) {
  tagList ??= [];
  return StatefulBuilder(
      builder: (context, setState) {
        return TagEditor(
            length: tagList!.length,
            delimiters: const [',', '/', '#', ' '],
            hasAddButton: false,
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