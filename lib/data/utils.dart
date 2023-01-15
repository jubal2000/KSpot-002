import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:helpers/helpers.dart';

import 'common_colors.dart';
import 'style.dart';

typedef JSON = Map<String, dynamic>;
typedef SnapShot = QuerySnapshot<Map<String, dynamic>>;
const String NO_IMAGE = 'assets/icons/app_icon_01.png';

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
TIME_DATA_DESC(dynamic data, [String defaultValue = '']) {
  var result = '';
  if (data == null || data == 'null') return defaultValue;
  if (STR(data['dayData']).isNotEmpty) result += data['dayData'].first;
  if (data['startDate'] != null)  result += data['startDate'];
  if (data['endDate'] != null)    result += '~' + data['endDate'];
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
  if (data['endTime'] != null && data['endTime'].isNotEmpty) timeStr += '~' + data['endTime'];
  if (result.isNotEmpty && timeStr.isNotEmpty) result += ' / ';
  result += timeStr;
  return result;
}

// ignore: non_constant_identifier_names
FROM_SERVER_DATA(data) {
  return SET_SERVER_TIME_ALL(data);
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME_ALL(data) {
  if (data is Map) {
    for (var item in data.entries) {
      data[item.key] = SET_SERVER_TIME_ALL_ITEM(item.value);
    }
  } else if (data is List) {
    data = SET_SERVER_TIME_ALL_ITEM(data);
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME_ALL_ITEM(data) {
  if (data is Timestamp) {
    data = SET_SERVER_TIME(data);
  } else if (data is Map) {
    data = SET_SERVER_TIME_ALL(data);
  } else if (data is List) {
    for (var i=0; i<data.length; i++) {
      data[i] = SET_SERVER_TIME_ALL_ITEM(data[i]);
    }
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME(timestamp) {
  if (timestamp is Timestamp) {
    return {
      '_seconds': timestamp.seconds,
      '_nanoseconds': timestamp.nanoseconds,
    };
  } else {
    return timestamp;
  }
}

// ignore: non_constant_identifier_names
TO_SERVER_DATA(data) {
  return SET_TO_SERVER_TIME_ALL(data);
}

// ignore: non_constant_identifier_names
SET_TO_SERVER_TIME_ALL(data) {
  if (data is Map) {
    if (data['_seconds'] != null) {
      return Timestamp(data['_seconds'], data['_nanoseconds']);
    }
    for (var item in data.entries) {
      data[item.key] = SET_TO_SERVER_TIME_ALL_ITEM(item.value);
    }
  } else if (data is List) {
    data = SET_TO_SERVER_TIME_ALL_ITEM(data);
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_TO_SERVER_TIME_ALL_ITEM(data) {
  if (data is Map) {
    data = SET_TO_SERVER_TIME_ALL(data);
  } else if (data is List) {
    for (var i=0; i<data.length; i++) {
      data[i] = SET_TO_SERVER_TIME_ALL_ITEM(data[i]);
    }
  }
  return data;
}

// ignore: non_constant_identifier_names
DESC(dynamic desc) {
  var tmp = desc != null ? desc.replaceAll('\\n', '\n') : '';
  return STR(tmp);
}

// ignore: non_constant_identifier_names
CURRENT_SERVER_TIME() {
  Timestamp currentTime = Timestamp.fromDate(DateTime.now());
  return currentTime;
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

PARAMETER_JSON(String key, dynamic value) {
  return {key: json.encode(value)};
}

Widget showImage(String url, Size size, [Color? color]) {
  return SizedBox(
      width: size.width,
      height: size.height,
      child: showImageWidget(url, BoxFit.cover, color:color)
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

enum DropdownItemType {
  none,

  content,
  talent,
  goods,
  live,

  placeGroup,
  place,
  placeEvent,
  placeClass,
  placeStory,
  eventStory,

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
  static const List<DropdownItem> homeAddItems    = [placeGroup, place, placeEvent];
  static const List<DropdownItem> homeAddItem0    = [placeStory, eventStory];
  static const List<DropdownItem> homeAddItem10   = [place];
  static const List<DropdownItem> homeAddItem11   = [placeGroup, place];
  static const List<DropdownItem> homeAddItem2    = [placeEvent, placeClass];
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
  static const placeEvent   = DropdownItem(DropdownItemType.placeEvent, text: 'EVENT +', icon: Icons.event_available);
  static const placeClass   = DropdownItem(DropdownItemType.placeClass, text: 'CLASS +', icon: Icons.school_outlined);
  static const placeStory   = DropdownItem(DropdownItemType.placeStory, text: 'SPOT STORY +', icon: Icons.photo_camera_outlined);
  static const eventStory   = DropdownItem(DropdownItemType.eventStory, text: 'EVENT STORY +', icon: Icons.photo_camera_outlined);

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

class RoundedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double height;
  final String label;
  final Color textColor, backgroundColor, borderColor;
  final bool fullWidth;
  final EdgeInsets padding;
  final double? fontSize;
  const RoundedButton({
    Key? key,
    @required this.onPressed,
    required this.label,
    this.height = 50,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.blue,
    this.borderColor = Colors.blue,
    this.fullWidth = true,
    this.padding = const EdgeInsets.symmetric(vertical: 9, horizontal: 30),
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 30,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 1.4,
            color: borderColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textColor,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
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