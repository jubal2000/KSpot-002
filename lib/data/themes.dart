import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/common_colors.dart';
import '../data/common_sizes.dart';

const double common_m_radius = 8.0;
const String APP_ICON_XL = 'assets/ui/app_icon_00.png';
const String APP_LOGO_XL = 'assets/ui/logo_01_00.png';

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
        fontWeight: FontWeight.w800,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed, //선택된 버튼 이동/고정
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
    indicatorColor: Colors.grey
);

final ThemeData darkTheme = ThemeData(
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
        fontWeight: FontWeight.w800,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed, //선택된 버튼 이동/고정
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
    indicatorColor: Colors.grey
);

