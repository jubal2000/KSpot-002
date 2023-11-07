import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kspot_002/data/style.dart';
import 'package:kspot_002/utils/utils.dart';
import 'package:provider/provider.dart';

import '../services/local_service.dart';
import 'app_data.dart';
import 'common_sizes.dart';

class ThemeNotifier with ChangeNotifier {

  final lightTheme = FlexThemeData.light(
    scheme: FlexScheme.redWine,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 20,
    appBarOpacity: 0.95,
    subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    blendOnColors: false,
    ),
    keyColors: const FlexKeyColors(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.notoSans().fontFamily,
    textTheme: GoogleFonts.notoSansTextTheme(),
    // textTheme: TextTheme(
    //   headline1: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    //   headline2: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    //   headline3: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    //   headline4: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,
    //     shadows: outlinedText(strokeWidth: 2, strokeColor: Colors.grey),
    //   ),
    //   headline5: TextStyle(fontSize: 14.0,
    //     shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.grey),
    //   ),
    //   headline6: TextStyle(fontSize: 12.0,
    //     shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.grey),
    //   ),
    //   subtitle1: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
    //   subtitle2: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
    //   bodyText1: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
    //   bodyText2: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
    // ),
  );

  final darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.redWine,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 15,
    appBarStyle: FlexAppBarStyle.surface,
    appBarOpacity: 0.90,
    subThemesData: const FlexSubThemesData(
    blendOnLevel: 30,
    ),
    keyColors: const FlexKeyColors(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.notoSans().fontFamily,
    textTheme: GoogleFonts.notoSansTextTheme(),
  );

  final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    primarySwatch: Colors.grey,
    dividerColor: Colors.black12,
    backgroundColor: const Color(0xFF202020),
    canvasColor: const Color(0xFF202020),
    selectedRowColor: Colors.grey,
    hintColor: Colors.grey,
    unselectedWidgetColor: Colors.grey,
    toggleableActiveColor: Colors.deepPurple,
    shadowColor: Colors.grey[800],
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: TextTheme(
      headline1: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white70),
      headline2: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
      headline3: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white70),
      headline4: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white70,
        shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.grey),
      ),
      headline5: TextStyle(fontSize: 14.0, color: Colors.grey[200],
        shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.grey),
      ),
      headline6: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white70),
      subtitle1: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white70),
      subtitle2: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
      bodyText1: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.white70),
      bodyText2: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.white),
    ),
  );

  final _lightTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.white,
    primarySwatch: Colors.grey,
    dividerColor: Colors.grey,
    backgroundColor: const Color(0xFFE5E5E5),
    canvasColor: const Color(0xFFE5E5E5),
    selectedRowColor: Colors.white,
    hintColor: Colors.black,
    unselectedWidgetColor: Colors.grey,
    toggleableActiveColor: Colors.deepPurple,
    shadowColor: Colors.grey[800],
    iconTheme: IconThemeData(color: Colors.grey),
    textTheme: TextTheme(
      headline1: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
      headline2: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.deepOrange),
      headline3: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black87),
      headline4: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black87,
        shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.grey),
      ),
      headline5: TextStyle(fontSize: 14.0, color: Colors.black54,
        shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.grey),
      ),
      headline6: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),
      subtitle1: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
      subtitle2: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.deepOrange),
      bodyText1: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.black54),
      bodyText2: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
    ),
  );

  var _themeData = ThemeData();
  ThemeData getTheme() => _themeData;
  int  getThemeIndex() => themeIndex;
  bool getMode() => themeMode;

  var themeIndex = FlexScheme.indigo.index;
  var themeMode  = false;

  ThemeNotifier() {
    if (themeMode) {
      _themeData = FlexThemeData.light(
        scheme: schemeList[themeIndex],
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 15,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
        ),
        keyColors: const FlexKeyColors(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts
            .notoSans()
            .fontFamily,
      );
    } else {
      _themeData = FlexThemeData.dark(
        scheme: schemeList[themeIndex],
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 15,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
        ),
        keyColors: const FlexKeyColors(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts
            .notoSans()
            .fontFamily,
      );
    }
    // notifyListeners();
    // StorageManager.readData('themeIndex').then((value1) {
    //   StorageManager.readData('themeMode').then((value2) {
    //     LOG('--> local theme data : $value1 / $value2');
    //     themeMode  = BOL(value2 ?? '1');
    //     themeIndex = value1 ?? 0;
    //     AppData.currentThemeMode  = themeMode;
    //     AppData.currentThemeIndex = themeIndex;
    //     notifyListeners();
    //   });
    // });
  }

  String setModeRotate(ThemeData currentTheme) {
    var _themeList = [
      lightTheme,
      darkTheme,
    ];
    var _themeText = [
      'LIGHT MODE',
      'DARK MODE'
    ];
    var _saveText = [
      'light',
      'dark'
    ];
    var index = _themeList.indexOf(currentTheme);
    if (++index >= _themeList.length) index = 0;
    _themeData = _themeList[index];
    AppData.currentThemeMode = index == 0;
    StorageManager.saveData('SchemeMode', AppData.currentThemeMode ? '1' : '');
    notifyListeners();
    return _themeText[index];
  }

  String setFlexSchemeRotate() {
    if (++themeIndex >= schemeList.length) themeIndex = 0;
    return refreshFlexScheme();
  }

  refreshFlexScheme() {
    if (themeMode) {
      _themeData = FlexThemeData.light(
        scheme: schemeList[themeIndex],
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 15,
        appBarStyle: FlexAppBarStyle.surface,
        appBarOpacity: 0.90,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
        ),
        keyColors: const FlexKeyColors(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts
            .notoSans()
            .fontFamily,
      );
    } else {
      _themeData = FlexThemeData.dark(
        scheme: schemeList[themeIndex],
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 15,
        appBarStyle: FlexAppBarStyle.surface,
        appBarOpacity: 0.90,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
        ),
        keyColors: const FlexKeyColors(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts
            .notoSans()
            .fontFamily,
      );
    }
    notifyListeners();
    var title = schemeTextList[themeIndex];
    return title;
  }

  String toggleSchemeMode() {
    themeMode = !themeMode;
    if (--themeIndex < 0) themeIndex = schemeList.length-1;
    StorageManager.saveData('SchemeMode', themeMode ? '1' : '0');
    var theme = setFlexSchemeRotate();
    AppData.currentThemeMode = themeMode;
    LOG('--> setModeRotate : ${AppData.currentThemeMode}');
    return themeMode ? 'LIGHT MODE - $theme' : 'DARK MODE - $theme';
  }

  void setMode(bool mode) {
    themeMode = mode;
    StorageManager.saveData('themeMode', mode ? '1' : '');
    notifyListeners();
  }

  void setIndex(int index) {
    themeIndex = index;
    StorageManager.saveData('themeIndex', index);
    notifyListeners();
  }
  
  void setTheme(bool mode, int index) {
    themeMode  = mode;
    themeIndex = index;
    StorageManager.saveData('themeMode', mode ? '1' : '');
    StorageManager.saveData('themeIndex', index);
    refreshFlexScheme();
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', '');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', '1');
    notifyListeners();
  }
}

TitleColor(BuildContext context) {
  return Theme.of(context).primaryColor;
}

SubTitleColor(BuildContext context) {
  return Theme.of(context).colorScheme.tertiary;
}

DescColor(BuildContext context) {
  return Theme.of(context).textTheme.bodySmall!.color;
}

DescInfoColor(BuildContext context) {
  return Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.5);
}

OutLineColor(BuildContext context) {
  return Theme.of(context).primaryColor.withOpacity(0.35);
}

LineColor(BuildContext context) {
  return Theme.of(context).primaryColor.withOpacity(0.25);
}

ItemCancelColor(BuildContext context) {
  return Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.25);
}

ItemConfirmColor(BuildContext context) {
  return Theme.of(context).textTheme.bodySmall!.color;
}

ItemReadyColor(BuildContext context) {
  return Theme.of(context).primaryColor.withOpacity(0.35);
}

DialogBackColor(BuildContext context) {
  return Theme.of(context).dialogBackgroundColor;
}

ProfileBackColor(BuildContext context) {
  return Theme.of(context).secondaryHeaderColor;
}

///////////////////////////////////////////////////////////

ButtonTitleStyle(BuildContext context) {
  return TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 18);
}

ButtonTitleInverseStyle(BuildContext context) {
  return TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.w800, fontSize: 18);
}

MainTitleStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, height: 1.3);
}

DialogTitleStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600);
}

DialogDescStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600);
}

DialogDescBoldStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800);
}

DialogDescErrorStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).errorColor, fontWeight: FontWeight.w800);
}

DialogDescExStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600);
}

DialogDescExErrorStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).errorColor, fontWeight: FontWeight.w600);
}

DialogLoadingDescStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w400);
}

AppBarTitleStyle(BuildContext context) {
  return TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800);
}

AppBarTitleExStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w600);
}

AppBarTitleOutlineStyle(BuildContext context, Color borderColor, {Color? color}) {
  return TextStyle(fontSize: 18, color: color ?? Theme.of(context).textTheme.bodyMedium!.color, fontWeight: FontWeight.w600,
      shadows: outlinedText(strokeColor: borderColor), height: 1.1);
}

AppBarTitleShadowStyle(BuildContext context, Color borderColor, {Color? color}) {
  return TextStyle(fontSize: 18, color: color ?? Theme.of(context).textTheme.bodyMedium!.color, fontWeight: FontWeight.w600,
      shadows: shadowText(strokeColor: borderColor), height: 1.1);
}

SubTitleStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).focusColor.withOpacity(0.8), fontWeight: FontWeight.w800);
}

SubTitleExStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor.withOpacity(0.5), fontWeight: FontWeight.w600);
}

SubTitleBackColor(BuildContext context) {
  return Theme.of(context).focusColor;
}

ItemTitleExLargeStyle(BuildContext context, {Color? color, double? fontSize, FontWeight? fontWeight}) {
  return TextStyle(fontSize: fontSize ?? 20, color: color ?? Theme.of(context).primaryColor, fontWeight: fontWeight ?? FontWeight.w800);
}

ItemButtonStyle(BuildContext context, {Color? color, double? fontSize, FontWeight? fontWeight}) {
  return TextStyle(fontSize: fontSize ?? 20, color: color ?? Theme.of(context).colorScheme.inversePrimary, fontWeight: fontWeight ?? FontWeight.w800);
}

ItemTitleLargeStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium!.color, fontWeight: FontWeight.w800);
}

ItemTitleLargeHotStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800);
}

ItemTitleLargeErrorStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w800);
}

ItemTitleLargeDisableStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).disabledColor, fontWeight: FontWeight.w600);
}

ItemTitleLargeInverseStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.w800);
}

ItemTitleLargeInverseNormalStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.w600);
}

ItemTitleInverseStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.w600);
}

ItemTitleOutlineStyle(BuildContext context, Color borderColor) {
  return TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800,
      shadows: outlinedText(strokeColor: borderColor));
}

ItemTitleStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600);
}

ItemTitle2Style(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor.withOpacity(0.8), fontWeight: FontWeight.w600);
}

ItemTitleBoldStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).textTheme.titleSmall!.color, fontWeight: FontWeight.w800);
}

ItemTitleNormalStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).textTheme.titleSmall!.color);
}

ItemTitleDisableStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).disabledColor.withOpacity(0.5));
}

ItemTitleHotStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w800);
}

ItemTitleAlertStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).errorColor, fontWeight: FontWeight.w600);
}

ItemTitleExStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor.withOpacity(0.65), fontWeight: FontWeight.w600);
}

ItemDescStyle(BuildContext context, {double fontSize = 12.0}) {
  return TextStyle(fontSize: fontSize, color: Theme.of(context).textTheme.titleSmall!.color, height: 1.1);
}

ItemDescColorStyle(BuildContext context, [var color = Colors.yellowAccent]) {
  return TextStyle(fontSize: 12, color: color, height: 1.1);
}

ItemDescColorBoldStyle(BuildContext context, [var color = Colors.yellowAccent]) {
  return TextStyle(fontSize: 12, color: color, height: 1.1, fontWeight: FontWeight.w600);
}

ItemDescBoldStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).hintColor.withOpacity(0.8), height: 1.1, fontWeight: FontWeight.w800);
}

ItemDescBoldInverseStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.surface.withOpacity(0.8), height: 1.1, fontWeight: FontWeight.w800);
}

ItemDescPriceStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.tertiary, height: 1.1, fontWeight: FontWeight.w800);
}

ItemDescPriceOrgStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Colors.grey, height: 1.1, fontWeight: FontWeight.w800, decoration: TextDecoration.lineThrough);
}

ItemDescSelectStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, height: 1.1, fontWeight: FontWeight.w600);
}

ItemDescAlertStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).errorColor);
}

ItemChatNameStyle(BuildContext context, [bool isOwner = false]) {
  return TextStyle(fontSize: 14, color: isOwner ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w600);
}

ItemChatTimeStyle(BuildContext context) {
  return TextStyle(fontSize: 10, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600);
}

ItemChatReadStyle(BuildContext context, [bool isOpened = true]) {
  return TextStyle(fontSize: 10,
      color: isOpened ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error, fontWeight: FontWeight.w400);
}

ItemDescAlertSmallStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).errorColor);
}

ItemDescHintStyle(BuildContext context) {
  var _mode = true;
  Consumer<ThemeNotifier>(
    builder: (context, theme, _) {
      _mode = theme.getMode();
      return Container();
    }
  );
  return TextStyle(fontSize: 14, color: _mode ? Colors.purple : Colors.purpleAccent);
}

ItemDescDisableStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).primaryColor.withOpacity(0.5));
}

ItemDescExStyle(BuildContext context) {
  return TextStyle(fontSize: 11, color: Theme.of(context).hintColor.withOpacity(0.75));
}

ItemDescEx2Style(BuildContext context) {
  return TextStyle(fontSize: 11, color: Theme.of(context).errorColor);
}

ItemDescExInfoStyle(BuildContext context) {
  return TextStyle(fontSize: 10, color: Theme.of(context).primaryColor.withOpacity(0.5));
}

ItemDescOutlineStyle(BuildContext context, [Color borderColor = Colors.white24]) {
  return TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w400,
      shadows: outlinedText(strokeColor: borderColor));
}

ItemDescOutlineExStyle(BuildContext context, {Color borderColor = Colors.black}) {
  return TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600,
      shadows: outlinedText(strokeColor: borderColor), height: 1.1);
}

CardTitleStyle(BuildContext context) {
  return TextStyle(fontSize: 12, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600, height: 1.1);
}

CardDescStyle(BuildContext context) {
  return TextStyle(fontSize: 11, color: Theme.of(context).hintColor.withOpacity(0.75), fontWeight: FontWeight.w400, height: 1.1);
}

CardNameStyle(BuildContext context) {
  return TextStyle(fontSize: 11, color: Theme.of(context).hintColor.withOpacity(0.75), fontWeight: FontWeight.w600, height: 1.1);
}

DescNameStyle(BuildContext context, {double fontSize = 15}) {
  return TextStyle(fontSize: fontSize, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600);
}

DescNameMyStyle(BuildContext context, {double fontSize = 16}) {
  return TextStyle(fontSize: fontSize, color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w800);
}

DescTitleLargeStyle(BuildContext context) {
  return TextStyle(fontSize: 18, color: Theme.of(context).primaryColor.withOpacity(0.85));
}

DescTitleStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600);
}

DescBodyStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).hintColor.withOpacity(0.85));
}

DescBodyPriceStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600);
}

DescBodyTextStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).hintColor, fontWeight: FontWeight.w500);
}

DescBodyBoldTextStyle(BuildContext context) {
  return TextStyle(fontSize: 16, color: Theme.of(context).hintColor, fontWeight: FontWeight.w800);
}

DescBodyExStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor.withOpacity(0.75));
}

ItemButtonNormalStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary);
}

ItemButtonDisableStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary.withOpacity(0.5));
}

DescBodyInfoStyle(BuildContext context, [double opacity = 0.5]) {
  return TextStyle(fontSize: 12, color: Theme.of(context).primaryColor.withOpacity(opacity), height: 1);
}

GroupTitleOutlineStyle(BuildContext context, Color borderColor) {
  return TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500,
      shadows: outlinedText(strokeColor: borderColor), height: 1.1);
}

ChatTitleStyle(BuildContext context) {
  return TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600);
}

SubTitleBar(BuildContext context, String title, {double horizontalPadding = 20, double height = UI_SUB_BAR_HEIGHT, IconData? icon, Function(String)? onActionSelect}) {
  Widget? child;
  if (icon != null) {
    child = Icon(icon, size: height * 0.8, color: Theme.of(context).primaryColor);
  }
  return SubTitleBarEx(context, title, horizontalPadding: horizontalPadding, height: height, child: child, onActionSelect:onActionSelect);
}

SubTitleBarEx(BuildContext context, String title, {double horizontalPadding = 20, double height = UI_SUB_BAR_HEIGHT, Widget? child, Function(String)? onActionSelect}) {
  return GestureDetector(
    onTap: () {
      if (onActionSelect != null) onActionSelect(title);
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: SubTitleBackColor(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: SubTitleStyle(context)),
          if (child != null)
            child,
        ]
      )
    )
  );
}

RoundSubTitleBarEx(BuildContext context, String title, {IconData? icon, double horizontalPadding = 10, double height = UI_SUB_BAR_HEIGHT, Widget? child, Function(String)? onActionSelect}) {
  return GestureDetector(
      onTap: () {
        if (onActionSelect != null) onActionSelect(title);
      },
      child: Container(
          width: double.infinity,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(height),
              child: Container(
                  height: height,
                  color: SubTitleBackColor(context),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: SubTitleStyle(context)),
                        if (child != null)
                          child,
                      ]
                  )
              )
          )
      )
  );
}

List<FlexScheme> schemeList = [
  FlexScheme.material,
  FlexScheme.materialHc,
  FlexScheme.blue,
  FlexScheme.indigo,
  FlexScheme.hippieBlue,
  FlexScheme.aquaBlue,
  FlexScheme.brandBlue,
  FlexScheme.deepBlue,
  FlexScheme.sakura,
  FlexScheme.mandyRed,
  FlexScheme.red,
  FlexScheme.redWine,
  FlexScheme.purpleBrown,
  FlexScheme.green,
  FlexScheme.money,
  FlexScheme.jungle,
  FlexScheme.greyLaw,
  FlexScheme.wasabi,
  FlexScheme.gold,
  FlexScheme.mango,
  FlexScheme.amber,
  FlexScheme.vesuviusBurn,
  FlexScheme.deepPurple,
  FlexScheme.ebonyClay,
  FlexScheme.barossa,
  FlexScheme.shark,
  FlexScheme.bigStone,
  FlexScheme.damask,
  FlexScheme.bahamaBlue,
  FlexScheme.mallardGreen,
  FlexScheme.espresso,
  FlexScheme.outerSpace,
  FlexScheme.blueWhale,
  FlexScheme.sanJuanBlue,
  FlexScheme.rosewood,
  FlexScheme.blumineBlue,
  FlexScheme.flutterDash,
  FlexScheme.materialBaseline,
  FlexScheme.verdunHemlock,
  FlexScheme.dellGenoa,
];

List<String> schemeTextList = [
  "material",
  "materialHc",
  "blue",
  "indigo",
  "hippieBlue",
  "aquaBlue",
  "brandBlue",
  "deepBlue",
  "sakura",
  "mandyRed",
  "red",
  "redWine",
  "purpleBrown",
  "green",
  "money",
  "jungle",
  "greyLaw",
  "wasabi",
  "gold",
  "mango",
  "amber",
  "vesuviusBurn",
  "deepPurple",
  "ebonyClay",
  "barossa",
  "shark",
  "bigStone",
  "damask",
  "bahamaBlue",
  "mallardGreen",
  "espresso",
  "outerSpace",
  "blueWhale",
  "sanJuanBlue",
  "rosewood",
  "blumineBlue",
  "flutterDash",
  "materialBaseline",
  "verdunHemlock",
  "dellGenoa",
];

List<String> schemeShotTextList = [
  "material",
  "materHC",
  "blue",
  "indigo",
  "hippieBL",
  "aquaBL",
  "brandBL",
  "deepBL",
  "sakura",
  "mandyR",
  "red",
  "redWine",
  "p.Brown",
  "green",
  "money",
  "jungle",
  "greyLaw",
  "wasabi",
  "gold",
  "mango",
  "amber",
  "v.Burn",
  "d.Purple",
  "ebonyClay",
  "barossa",
  "shark",
  "bigStone",
  "damask",
  "bahamaBL",
  "m.Green",
  "espresso",
  "outerSpace",
  "blueWhale",
  "sanJuanBL",
  "rosewood",
  "blumineBL",
  "flutt.Dash",
  "mater.BL",
  "v.Hemlock",
  "dellGenoa",
];