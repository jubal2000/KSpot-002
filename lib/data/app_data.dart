import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/etc_model.dart';
import '../models/start_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utils/utils.dart';

const SCROLL_SPEED = 250;
const APP_VERSION = '0.0.1';

const ORG_SCREEN_WITH = 411;
const NICKNAME_LENGTH = 12;
const TITLE_LENGTH = 24;
const DESC_LENGTH = 999;
const COMMENT_LENGTH = 999;
const IMAGE_SIZE_MAX = 512.0;

const FACE_CIRCLE_SIZE_L = 120.0;
const FACE_CIRCLE_SIZE_M = 50.0;
const FACE_CIRCLE_SIZE_S = 40.0;

const GOOGLE_MAP_KEY = 'AIzaSyD4ESmTaou10BumFoJ7DQ7jkTI7emh4Hvo';

class AppData {
  static final AppData _singleton = AppData._internal();
  AppData._internal();

  FirebaseService? firebase;

  static var isDevMode = true;

  static String defaultInfoID = 'info0001';

  static StartModel? startInfo;
  static UserModel   userInfo  = UserModelEx.empty('');
  static UserModel   loginInfo = UserModelEx.empty('');

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
  static var currentCountryFlag = '';
  static var currentCountry     = '';
  static var currentCountryCode = '';
  static var currentState       = '';
  static var currentCity        = '';
  static List<CountryData> countrySelectList = [];

  static var currentCurrency    = '';
  static var currentCategory    = '';
  static var dynamicLinkPath    = '';

  static var isPlaceGroupGridMode = true;

  static DateTime? currentDate;
  static JSON currentPlaceGroup = {};
  static JSON selectEventTime = {};
  static JSON messageReadLog = {};
  static JSON startInfoData = {};
  static JSON localInfo = {};
  static JSON infoData = {};
  static JSON timeData = {};

  static BuildContext? topMenuContext;

  static JSON INFO_NOTICE         = JSON.from(infoData['notice'       ] ??= {});
  static JSON INFO_FAQ            = JSON.from(infoData['faq'          ] ??= {});
  static JSON INFO_CATEGORY_GROUP = JSON.from(infoData['categoryGroup'] ??= {});
  static JSON INFO_CATEGORY_TYPE  = JSON.from(infoData['categoryType' ] ??= {});
  static JSON INFO_CATEGORY       = JSON.from(infoData['category'     ] ??= {});
  static JSON INFO_CONTENT_TYPE   = JSON.from(infoData['contentType'  ] ??= {});
  static JSON INFO_CONTENT        = JSON.from(infoData['content'      ] ??= {});
  static JSON INFO_REFUND         = JSON.from(infoData['refund'       ] ??= {});
  static JSON INFO_DECLAR         = JSON.from(infoData['declar'       ] ??= {});
  static JSON INFO_CURRENCY       = JSON.from(infoData['currency'     ] ??= {});
  static JSON INFO_CUSTOMFIELD    = JSON.from(infoData['customField'  ] ??= {});
  static JSON INFO_PROMOTION      = JSON.from(infoData['promotion'    ] ??= {});

  static JSON INFO_HISTORY_OPTION = infoData['option'] != null ? JSON.from(infoData['option']['history'] ??= {}) : {};
  static JSON INFO_TALENT_OPTION  = infoData['option'] != null ? JSON.from(infoData['option']['talent'] ??= {}) : {};
  static JSON INFO_GOODS_OPTION   = infoData['option'] != null ? JSON.from(infoData['option']['goods'] ??= {}) : {};
  static JSON INFO_PUSH_OPTION    = infoData['option'] != null ? JSON.from(infoData['option']['push'] ??= {}) : {};
  static JSON INFO_PLAY_OPTION    = infoData['option'] != null ? JSON.from(infoData['option']['autoPlay'] ??= {}) : {};
  static JSON INFO_SHOP_OPTION    = infoData['option'] != null ? JSON.from(infoData['option']['shop'] ??= {}) : {};
  static JSON INFO_EVENT_OPTION   = infoData['option'] != null ? JSON.from(infoData['option']['event'] ??= {}) : {};


  // ignore: non_constant_identifier_names
  static String get USER_ID => AppData.userInfo.id;
  // ignore: non_constant_identifier_names
  static int get USER_STATUS => AppData.userInfo.status;
  // ignore: non_constant_identifier_names
  static bool get IS_ADMIN => USER_STATUS > 1;

  // ignore: non_constant_identifier_names
  static String get USER_NICKNAME => AppData.userInfo.nickName;
  // ignore: non_constant_identifier_names
  static set USER_NICKNAME(String value) {
    AppData.userInfo.nickName = value;
  }

  // ignore: non_constant_identifier_names
  static String get USER_PIC => AppData.userInfo.pic;
  // ignore: non_constant_identifier_names
  static set USER_PIC(String value) {
    AppData.userInfo.pic = value;
  }

  // ignore: non_constant_identifier_names
  static String get USER_PHONE => AppData.userInfo.mobile;
  // ignore: non_constant_identifier_names
  static set USER_PHONE(String value) {
    AppData.userInfo.mobile = value;
  }

  // ignore: non_constant_identifier_names
  static String get USER_EMAIL => AppData.userInfo.email;
  // ignore: non_constant_identifier_names
  static set USER_EMAIL(String value) {
    AppData.userInfo.email = value;
  }
}
