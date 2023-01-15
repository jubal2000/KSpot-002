import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/common_colors.dart';
import '../core/common_sizes.dart';

final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: NAVY,
    primaryColorBrightness: Brightness.light,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.grey[800],
        fontSize: appbar_title_font_size,
        fontWeight: FontWeight.w800,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed, //선택된 버튼 이동/고정
      selectedLabelStyle: TextStyle(fontSize: bottom_navi_label_font_size),
      unselectedLabelStyle: TextStyle(fontSize: bottom_navi_label_font_size),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(common_m_radius))),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
      primary: NAVY,
      elevation: 0,
      side: BorderSide(color: NAVY, width: 1),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(common_m_radius))),
      // side: BorderSide(color: Colors.grey[800]!),
    )),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(
          vertical: common_s_gap, horizontal: common_xs_gap),
      filled: true,
      fillColor: BG_COLOR,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.zero),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.zero),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.zero),
      // focusedBorder: InputBorder.none,
      // disabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide.none, borderRadius: BorderRadius.zero),

      // enabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
      // disabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
      // focusedBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
    ),
    indicatorColor: Colors.grey);
