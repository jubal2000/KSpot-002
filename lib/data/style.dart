import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

const appbar_title_font_size = 18.0;
const common_title_font_size = 14.0;
const common_desc_font_size  = 12.0;
const main_menu_font_size = 14.0;
const dialog_title_font_size = 16.0;
const dialog_desc_font_size = 14.0;
const dialog_desc_ex_font_size = 12.0;
const item_title_font_size = 14.0;
const item_title_sub_font_size = 13.0;
const item_title_info_font_size = 12.0;
const item_desc_font_size = 11.0;

TextStyle textFieldTextStyle = TextStyle(color: Colors.grey[800]);
TextStyle tapMenuTitleTextStyle = TextStyle(
    fontSize: appbar_title_font_size, color: Colors.black54, fontWeight: FontWeight.w700);

// main..
TextStyle menuItemTitleStyle = TextStyle(
    fontSize: main_menu_font_size, color: Colors.white, fontWeight: FontWeight.w600);

// dialog..
TextStyle dialogTitleTextStyle = TextStyle(
    fontSize: dialog_title_font_size, color: Colors.black87, fontWeight: FontWeight.w700);
TextStyle dialogDescTextStyle = TextStyle(
    fontSize: dialog_desc_font_size, color: Colors.black54, fontWeight: FontWeight.w400);
TextStyle dialogDescTextExStyle = TextStyle(
    fontSize: dialog_desc_ex_font_size, color: Colors.black38, fontWeight: FontWeight.w400);
TextStyle dialogDescTextErrorStyle = TextStyle(
    fontSize: dialog_desc_font_size, color: Colors.redAccent, fontWeight: FontWeight.w400);

// item..
TextStyle itemTitleStyle = TextStyle(
    fontSize: item_title_font_size, fontWeight: FontWeight.w700);
TextStyle itemSubTitleStyle = TextStyle(
    fontSize: item_title_sub_font_size, fontWeight: FontWeight.w700);
TextStyle itemTitleInverseStyle = TextStyle(
    fontSize: item_title_font_size, color: Colors.white, fontWeight: FontWeight.w700);
TextStyle itemTitleInfoStyle = TextStyle(
    fontSize: item_title_info_font_size, color: Colors.black38, fontWeight: FontWeight.w700);
TextStyle itemTitleAlertStyle = TextStyle(
    fontSize: item_title_font_size, color: Colors.redAccent, fontWeight: FontWeight.w700);
TextStyle itemTitleColorStyle = TextStyle(
    fontSize: item_title_font_size, color: Colors.deepPurple, fontWeight: FontWeight.w700);
TextStyle itemDescStyle = TextStyle(
    fontSize: item_desc_font_size, color: Colors.black54, fontWeight: FontWeight.w600);
TextStyle itemDescLinkStyle = TextStyle(
    fontSize: item_desc_font_size, color: Colors.blue, fontWeight: FontWeight.w400, decoration: TextDecoration.underline);

/// Outlines a text using shadows.
List<Shadow> outlinedText({double strokeWidth = 1, Color strokeColor = Colors.black, int precision = 4}) {
  Set<Shadow> result = HashSet();
  for (double x = 1; x < strokeWidth + precision; x++) {
    for(double y = 1; y < strokeWidth + precision; y++) {
      double offsetX = x.toDouble();
      double offsetY = y.toDouble();
      result.add(Shadow(offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
      result.add(Shadow(offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
      result.add(Shadow(offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
      result.add(Shadow(offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
    }
  }
  return result.toList();
}

// content..
TextStyle titleStyle = TextStyle(
    fontSize: common_title_font_size, fontWeight: FontWeight.w700);
TextStyle descStyle = TextStyle(
    fontSize: common_desc_font_size,
    color: Colors.black54,
    fontWeight: FontWeight.w600);
TextStyle descExStyle = TextStyle(
    fontSize: common_desc_font_size,
    color: Colors.blueAccent,
    fontWeight: FontWeight.w600);
TextStyle errorStyle = TextStyle(
    fontSize: common_desc_font_size,
    color: Colors.redAccent,
    fontWeight: FontWeight.w600);

//fontThema
enum TextFont { B, EB, H, L, M, R, SB, T, UL }

class TextInterface extends StatelessWidget {
  String title;
  Color color;
  TextFont font;
  double size;
  TextAlign align;
  TextOverflow? textOverflow;
  int lineMax;
  double height;
  TextStyle? style;
  TextDecoration? decoration;
  bool inherit = true;
  String fontData = '';

  var underLine = outlinedText(strokeWidth: 1, strokeColor: Colors.black.withOpacity(0.1));

  TextInterface(
      {
        required this.title,
        required this.color,
        required this.font,
        required this.size,
        this.align = TextAlign.start,
        this.lineMax = 1,
        this.height = 1,
        this.style,
        this.textOverflow,
        this.decoration,
      });
  @override
  Widget build(BuildContext context) {
    if (font == TextFont.B) {
      fontData = 'B';
    } else if (font == TextFont.EB) {
      fontData = 'EB';
    } else if (font == TextFont.H) {
      fontData = 'H';
    } else if (font == TextFont.L) {
      fontData = 'L';
    } else if (font == TextFont.M) {
      fontData = 'M';
    } else if (font == TextFont.R) {
      fontData = 'R';
    } else if (font == TextFont.SB) {
      fontData = 'SB';
    } else if (font == TextFont.T) {
      fontData = 'T';
    } else if (font == TextFont.UL) {
      fontData = 'UL';
    }

    return Text(
      title,
      overflow: textOverflow,
      style: style ??
          TextStyle(color: color, fontSize: size, fontFamily: fontData, decoration: decoration, height: height, inherit: inherit),
      textAlign: align, maxLines: lineMax,
    );
  }
}

class TextMiddleOverflow extends StatelessWidget {
  String title;
  Color color;
  var font;
  double size;
  TextStyle? style;
  TextAlign? align;
  TextOverflow? textOverflow;
  String fontData = '';
  TextMiddleOverflow(
      {required this.title,
        required this.color,
        required this.font,
        required this.size,
        this.align,
        this.style,
        this.textOverflow});
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (font == TextFont.B) {
      fontData = 'B';
    } else if (font == TextFont.EB) {
      fontData = 'EB';
    } else if (font == TextFont.H) {
      fontData = 'H';
    } else if (font == TextFont.L) {
      fontData = 'L';
    } else if (font == TextFont.M) {
      fontData = 'M';
    } else if (font == TextFont.R) {
      fontData = 'R';
    } else if (font == TextFont.SB) {
      fontData = 'SB';
    } else if (font == TextFont.T) {
      fontData = 'T';
    } else if (font == TextFont.UL) {
      fontData = 'UL';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Spacer(),
        Expanded(
            child: Container(
              width: width,
              child: Text(
                title.length > 3 ? title.substring(0, title.length - 3) : title,
                style:
                TextStyle(color: color, fontSize: size, fontFamily: fontData),
                maxLines: 1,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        Expanded(
            child: Container(
              width: width,
              child: Text(
                title.length > 20 ? title.substring(title.length - 20) : '',
                maxLines: 1,
                textAlign: TextAlign.start,
                style:
                TextStyle(color: color, fontSize: size, fontFamily: fontData),
              ),
            )),
        // Spacer(),
      ],
    );
  }
}
