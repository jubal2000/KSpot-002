import 'dart:collection';

import 'package:flutter/material.dart';
import '../core/common_colors.dart';
import '../core/common_sizes.dart';

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
    fontSize: item_title_font_size, color: NAVY, fontWeight: FontWeight.w700);
TextStyle itemSubTitleStyle = TextStyle(
    fontSize: item_title_sub_font_size, color: NAVY, fontWeight: FontWeight.w700);
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

// pin..
TextStyle pinTitleStyle = TextStyle(
    fontSize: pin_title_font_size, color: Colors.black, fontWeight: FontWeight.w600, height: 1.1,
    shadows: outlinedText(strokeWidth: 0.2, strokeColor: Colors.white));
TextStyle pinEditTitleStyle = TextStyle(
    fontSize: pin_edit_title_font_size, color: Colors.white, fontWeight: FontWeight.w600, height: 1.1);

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
