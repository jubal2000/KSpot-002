import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/start_model.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';

const SCROLL_SPEED = 250;
const APP_VERSION = '0.0.1';
const ORG_SCREEN_WITH = 411;
const NICKNAME_LENGTH = 12;
const GOOGLE_MAP_KEY = 'AIzaSyD4ESmTaou10BumFoJ7DQ7jkTI7emh4Hvo';

class AppData {
  static final AppData _singleton = AppData._internal();
  AppData._internal();

  static var isDevMode = true;
  static StartModel? startData;
  static UserModel   userInfo  = UserModel(userId: '');
  static UserModel   loginInfo = UserModel(userId: '');

  static JSON listSelectData = {};
  static int? localDataVer;
  static List<String>? localAppData;

  static var currentThemeMode = false;
  static var currentThemeIndex = 0;
  static LatLng? currentLocation;
  static var defaultCountryFlag = '🇰🇷    Korea South';
  static var defaultCountry     = 'Korea South';
  static var defaultState       = '';
  static var defaultCity        = '';
  static var currentCountry     = 'Korea South';
  static var currentCountryFlag = '🇰🇷';
  static var currentCountryCode = '';
  static var currentState       = 'Seoul';
  static var currentCity        = '';
  static var currentCurrency    = '';
  static var currentCategory    = '';
  static var dynamicLinkPath    = '';

  static var isPlaceGroupGridMode = true;

  static DateTime? currentDate;
  static JSON currentPlaceGroup = {};
  static JSON selectEventTime = {};
  static JSON messageReadLog = {};
  static JSON localInfo = {};
  static JSON infoData = {};

  static BuildContext? topMenuContext;

  static JSON INFO_NOTICE         = infoData['notice'       ] ??= {};
  static JSON INFO_FAQ            = infoData['faq'          ] ??= {};
  static JSON INFO_CATEGORY_GROUP = infoData['categoryGroup'] ??= {};
  static JSON INFO_CATEGORY_TYPE  = infoData['categoryType' ] ??= {};
  static JSON INFO_CATEGORY       = infoData['category'     ] ??= {};
  static JSON INFO_CONTENT_TYPE   = infoData['contentType'  ] ??= {};
  static JSON INFO_CONTENT        = infoData['content'      ] ??= {};
  static JSON INFO_REFUND         = infoData['refund'       ] ??= {};
  static JSON INFO_DECLAR         = infoData['declar'       ] ??= {};
  static JSON INFO_CURRENCY       = infoData['currency'     ] ??= {};
  static JSON INFO_CUSTOMFIELD    = infoData['customField'  ] ??= {};
  static JSON INFO_PROMOTION      = infoData['promotion'    ] ??= {};

  static JSON INFO_HISTORY_OPTION = infoData['option'] != null ? infoData['option']['history'] ??= {} : {};
  static JSON INFO_TALENT_OPTION  = infoData['option'] != null ? infoData['option']['talent'] ??= {} : {};
  static JSON INFO_GOODS_OPTION   = infoData['option'] != null ? infoData['option']['goods'] ??= {} : {};
  static JSON INFO_PUSH_OPTION    = infoData['option'] != null ? infoData['option']['push'] ??= {} : {};
  static JSON INFO_PLAY_OPTION    = infoData['option'] != null ? infoData['option']['autoPlay'] ??= {} : {};
  static JSON INFO_SHOP_OPTION    = infoData['option'] != null ? infoData['option']['shop'] ??= {} : {};
  static JSON INFO_EVENT_OPTION   = infoData['option'] != null ? infoData['option']['event'] ??= {} : {};


  // ignore: non_constant_identifier_names
  static String get USER_ID => AppData.userInfo?.userId ?? '';
  // ignore: non_constant_identifier_names
  static int get USER_STATUS => AppData.userInfo?.status ?? 0;
  // ignore: non_constant_identifier_names
  static bool get IS_ADMIN => USER_STATUS == 2;

  // ignore: non_constant_identifier_names
  static String get USER_NICKNAME => AppData.userInfo?.nickName ?? '';
  // ignore: non_constant_identifier_names
  static set USER_NICKNAME(String value) {
    AppData.userInfo?.nickName = value;
  }

  // ignore: non_constant_identifier_names
  static String get USER_PIC => AppData.userInfo?.pic ?? '';
  // ignore: non_constant_identifier_names
  static set USER_PIC(String value) {
    AppData.userInfo?.pic = value;
  }

  // ignore: non_constant_identifier_names
  static String get USER_PHONE => AppData.userInfo?.mobile ?? '';
  // ignore: non_constant_identifier_names
  static set USER_PHONE(String value) {
    AppData.userInfo?.mobile = value;
  }

  // ignore: non_constant_identifier_names
  static String get USER_EMAIL => AppData.userInfo?.email ?? '';
  // ignore: non_constant_identifier_names
  static set USER_EMAIL(String value) {
    AppData.userInfo?.email = value;
  }
}
