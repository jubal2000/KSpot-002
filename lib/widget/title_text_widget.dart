import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/common_sizes.dart';
import '../data/style.dart';
import '../data/themes.dart';
import '../utils/utils.dart';

TitleText(context, title1, title2,
    {double fontSize = UI_FONT_SIZE_LX, var align = MainAxisAlignment.center}) {
  return Row(
    mainAxisAlignment: align,
    children: [
      TextInterface(
          title: title1,
          color: Theme.of(context).primaryColor,
          font: TextFont.M,
          size: fontSize.sp),
      SizedBox(width: 10.w),
      TextInterface(
          title: title2,
          color: Theme.of(context).primaryColorDark,
          font: TextFont.M,
          size: fontSize.sp)
    ],
  );
}

TitleColorText(context, title, List<String> colorText,
    {double fontSize = UI_FONT_SIZE_H}) {
  List<String> showText = title.split(' ');
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: showText
        .map((item) => TextInterface(
            title: '$item ',
            color: colorText.contains(item)
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColorDark,
            font: TextFont.M,
            size: fontSize.sp))
        .toList(),
  );
}

TopTitleText(context, title,
    {double fontSize = UI_FONT_SIZE_LT,
    var align = MainAxisAlignment.start,
    var showBack = false,
    Function()? onAction}) {
  return GestureDetector(
      onTap: () {
        if (onAction != null) onAction();
      },
      child:  Row(
        mainAxisAlignment: align,
        children: [
          SizedBox(width: UI_HORIZONTAL_SPACE),
          if (showBack) ...[
            Icon(Icons.arrow_back_ios,
                size: 28.h, color: Theme.of(context).primaryColor),
          ],
          TextInterface(
              title: title,
              color: Theme.of(context).primaryColor,
              font: TextFont.SB,
              size: fontSize.sp),
      ]));
}

TabTitleSelectText(context, text, {double fontSize = UI_FONT_SIZE_M}) {
  return TextInterface(
      title: text,
      color: Theme.of(context).primaryColorDark,
      font: TextFont.L,
      size: fontSize.sp,
      align: TextAlign.center);
}

TabTitleNormalText(context, text, {double fontSize = UI_FONT_SIZE_M}) {
  return TextInterface(
      title: text,
      color: Theme.of(context).primaryColorDark.withOpacity(0.5),
      font: TextFont.L,
      size: fontSize.sp,
      align: TextAlign.center);
}

SubTitleText(context, text,
    {double fontSize = UI_FONT_SIZE_S,
    int maxLine = 1,
    double height = 1,
    Color color = Colors.black}) {
  return TextInterface(
      title: text,
      color: color,
      font: TextFont.L,
      size: fontSize.sp,
      align: TextAlign.center,
      lineMax: maxLine,
      height: height);
}

SubTitleBoldText(context, text,
    {double fontSize = UI_FONT_SIZE_MS,
    int maxLine = 1,
    double height = 1,
    Color color = Colors.black}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColorDark,
      font: TextFont.B,
      size: fontSize.sp,
      align: TextAlign.center,
      lineMax: maxLine,
      height: height);
}

SubTitleColorText(context, title, List<String> colorText,
    {JSON replaceStr = const {}, double fontSize = UI_FONT_SIZE_S}) {
  if (replaceStr.isNotEmpty) {
    for (var key in replaceStr.keys) {
      title = title.replaceAll(key, replaceStr[key]);
    }
  }
  List<String> showText = title.split(' ');
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: showText
        .map((item) => TextInterface(
            title: '$item ',
            color: colorText.contains(item)
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColorDark,
            font: TextFont.M,
            size: fontSize.sp))
        .toList(),
  );
}

ContentTitleText(context, text,
    {double fontSize = UI_FONT_SIZE_H,
      var color = Colors.black,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColorDark,
      font: TextFont.B,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

ContentSubTitleText(context, text,
    {double fontSize = UI_FONT_SIZE_M,
    var color = Colors.black87,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColorDark.withOpacity(0.85),
      font: TextFont.SB,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

ContentStatusText(context, text,
    {double fontSize = UI_FONT_SIZE_M,
    var color = Colors.blue,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColor,
      font: TextFont.B,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

ContentDescText(context, text,
    {double fontSize = UI_FONT_SIZE_M,
    var color = Colors.black87,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColorDark.withOpacity(0.85),
      font: TextFont.L,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

ContentDescExText(context, text,
    {double fontSize = UI_FONT_SIZE_M,
    var color = Colors.black45,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColorDark.withOpacity(0.45),
      font: TextFont.L,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

ContentInfoText(context, text,
    {double fontSize = UI_FONT_SIZE_SX,
    var color = Colors.black45,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColorDark.withOpacity(0.45),
      font: TextFont.L,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

ContentInfoExText(context, text,
    {double fontSize = UI_FONT_SIZE_SX,
    var color = Colors.black26,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColorDark.withOpacity(0.25),
      font: TextFont.L,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

ItemTitleText(context, text,
    {double fontSize = UI_FONT_SIZE_M,
    var color = Colors.black,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColorDark,
      font: TextFont.SB,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

SelectTitleText(context, text,
    {double fontSize = UI_FONT_SIZE_L,
    var color = Colors.black,
    var lineMax = 1,
    var height = 1.1,
    var align = TextAlign.start}) {
  return TextInterface(
      title: text,
      color: color = Theme.of(context).primaryColor,
      font: TextFont.SB,
      size: fontSize.sp,
      align: align,
      lineMax: lineMax,
      height: height);
}

MnemonicNumberText(text, {double fontSize = UI_FONT_SIZE_LX, var color = Colors.black, var lineMax = 1, var height = 1.1, var align = TextAlign.center}) {
  return TextInterface(title: text, color: color, font: TextFont.EB, size: fontSize.sp, align: align, lineMax: lineMax, height: height);
}


//스케치 코인 텍스트
SketchText(context, coin) {
  var width = MediaQuery.of(context).size.width;
  var f = NumberFormat('###,###,###,###,###,###.######');
  String coinText = f.format(coin);

  return Container(
    margin: EdgeInsets.only(top: 34.h),
    width: width,
    height: 27.h,
    alignment: Alignment.center,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextInterface(
            title: coinText,
            color: Theme.of(context).primaryColor,
            font: TextFont.B,
            size: 22.sp),
        Container(
          margin: EdgeInsets.only(top: 5.h, left: 6.w),
          child: TextInterface(
              title: 'Sketch',
              color: Color(0xffFFFFFF),
              font: TextFont.B,
              size: 12.sp),
        ),
      ],
    ),
  );
}
