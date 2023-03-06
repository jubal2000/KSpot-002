import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/chat_model.dart';
import '../models/etc_model.dart';
import '../models/event_group_model.dart';
import '../models/event_model.dart';
import '../models/follow_model.dart';
import '../models/message_model.dart';
import '../models/place_model.dart';
import '../models/start_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utils/utils.dart';
import '../view_model/app_view_model.dart';
import '../view_model/chat_view_model.dart';
import '../view_model/event_view_model.dart';
import '../view_model/message_view_model.dart';
import '../view_model/story_view_model.dart';

const SCROLL_SPEED = 250;
const APP_VERSION = '0.0.1';

const ORG_SCREEN_WITH = 411;
const NICKNAME_LENGTH = 12;
const TITLE_LENGTH = 24;
const PASSWORD_LENGTH = 12;
const DESC_LENGTH = 999;
const STORY_DESC_LENGTH = 500;
const COMMENT_LENGTH = 999;
const IMAGE_SIZE_MAX = 512.0;
const PIC_IMAGE_SIZE_MAX = 2048.0;
const PIN_IMAGE_SIZE_MAX = 12.0;
const UPLOAD_FILE_MAX = 5;
const CHAT_NOTICE_MAX = 5;

const FACE_CIRCLE_SIZE_L = 120.0;
const FACE_CIRCLE_SIZE_M = 50.0;
const FACE_CIRCLE_SIZE_S = 40.0;
const FACE_CIRCLE_SIZE_SS = 30.0;
const FACE_CIRCLE_SIZE_SE = 20.0;

const GOOGLE_MAP_KEY = 'AIzaSyD4ESmTaou10BumFoJ7DQ7jkTI7emh4Hvo';

class HomeListType {
  static int get list     => 0;
  static int get map      => 1;
  static int get calendar => 2;
}

enum CommentType {
  none,
  message,
  comment,
  qna,
  history,
  serviceQnA,
  placeGroup,
  place,
  event,
  story,
}

enum SearchKeys {
  events,
  classes,
  message,
  follow0,
  follow1,
  goods0,
  goods1,
}

class AppData {
  static final AppData _singleton = AppData._internal();

  AppData._internal();

  FirebaseService? firebase;

  static var isDevMode = true;

  static var appViewModel       = AppViewModel();
  static var eventViewModel     = EventViewModel();
  static var storyViewModel     = StoryViewModel();
  static var chatViewModel      = ChatViewModel();
  static var messageViewModel   = MessageViewModel();

  static var defaultInfoID = 'info0001';

  static StartModel? startInfo;
  static UserModel userInfo = UserModelEx.empty('');
  static UserModel loginInfo = UserModelEx.empty('');

  static JSON listSelectData = {};
  static int? localDataVer;
  static List<String>? localAppData;
  static List<String> searchHistoryList = [];

  static var currentThemeMode = false;
  static var currentThemeIndex = 0;
  static LatLng? currentLocation;
  static var defaultCountryFlag = '🇰🇷    Korea South';
  static var defaultCountry = 'Korea South';
  static var defaultState = '';
  static var defaultCity = '';
  static var currentCountryFlag = '';
  static var currentCountry = '';
  static var currentCountryCode = '';
  static var currentState = '';
  static var currentCity = '';
  static var currentDate = DateTime.now();
  static List<CountryData> countrySelectList = [];
  static CalendarController? calenderController;
  static var calendarMode = CalendarView.month;
  static EventGroupModel? currentEventGroup;
  static var currentContentType = '';
  static var currentCurrency = '';
  static var dynamicLinkPath = '';

  static var isEventGroupGridMode = true;
  static var isMainActive = true;
  static var isSignUpMode = false;

  static JSON selectEventTime = {};
  static JSON chatReadLog = {};
  static JSON messageReadLog = {};
  static JSON startInfoData = {};
  static JSON localInfo = {};
  static JSON infoData = {};
  static JSON timeData = {};
  static JSON serviceQnAData = {};
  static List<String> refreshChatList = [];

  static Map<String, PlaceModel>    placeData = {};
  static Map<String, EventModel>    eventData = {};
  static Map<String, UserModel>     userData = {};
  static Map<String, UserModel>     blockUserData = {}; // 차단된 유저 목록
  static Map<String, MessageModel>  messageData = {};
  static Map<String, FollowModel>   followData = {};

  static BuildContext? topMenuContext;
  static List<GlobalKey> searchWidgetKey = List.generate(SearchKeys.values.length, (index) => GlobalKey());

  static JSON INFO_NOTICE = JSON.from(infoData['notice' ] ??= {});
  static JSON INFO_FAQ = JSON.from(infoData['faq' ] ??= {});
  // static JSON INFO_CATEGORY_GROUP = JSON.from(infoData['categoryGroup'] ??= {});
  // static JSON INFO_CATEGORY_TYPE = JSON.from(infoData['categoryType' ] ??= {});
  // static JSON INFO_CATEGORY = JSON.from(infoData['category' ] ??= {});
  static JSON INFO_CONTENT_TYPE = JSON.from(infoData['contentType' ] ??= {});
  static JSON INFO_CONTENT = JSON.from(infoData['content' ] ??= {});
  static JSON INFO_REFUND = JSON.from(infoData['refund' ] ??= {});
  static JSON INFO_DECLAR = JSON.from(infoData['declar' ] ??= {});
  static JSON INFO_CURRENCY = JSON.from(infoData['currency' ] ??= {});
  static JSON INFO_CUSTOMFIELD = JSON.from(infoData['customField' ] ??= {});
  static JSON INFO_PROMOTION = JSON.from(infoData['promotion' ] ??= {});

  static JSON INFO_STORY_OPTION = infoData['option'] != null ? JSON.from(infoData['option']['story'] ??= {}) : {};
  static JSON INFO_TALENT_OPTION = infoData['option'] != null ? JSON.from(infoData['option']['talent'] ??= {}) : {};
  static JSON INFO_GOODS_OPTION = infoData['option'] != null ? JSON.from(infoData['option']['goods'] ??= {}) : {};
  static JSON INFO_PUSH_OPTION = infoData['option'] != null ? JSON.from(infoData['option']['push'] ??= {}) : {};
  static JSON INFO_PLAY_OPTION = infoData['option'] != null ? JSON.from(infoData['option']['autoPlay'] ??= {}) : {};
  static JSON INFO_SHOP_OPTION = infoData['option'] != null ? JSON.from(infoData['option']['shop'] ??= {}) : {};
  static JSON INFO_EVENT_OPTION = infoData['option'] != null ? JSON.from(infoData['option']['event'] ??= {}) : {};

  static var mainListType = HomeListType.list;

  // ignore: non_constant_identifier_names
  static String get USER_ID => AppData.userInfo.id;

  // ignore: non_constant_identifier_names
  static int get USER_STATUS => AppData.userInfo.status;

  // ignore: non_constant_identifier_names
  static int get USER_LEVEL => AppData.userInfo.status;

  // ignore: non_constant_identifier_names
  static bool get IS_ADMIN => USER_STATUS > 1;

  // ignore: non_constant_identifier_names
  static bool get IS_LOGIN => AppData.userInfo.loginType == 'phone';

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

  // user links..

  // ignore: non_constant_identifier_names
  static List<String> get USER_EVENT_GROUP_LIKE => AppData.userInfo.likeGroup ?? List<String>.from([]);
  // ignore: non_constant_identifier_names
  static set USER_EVENT_GROUP_LIKE(List<String> value) {
    AppData.userInfo.likeGroup = value;
  }

  // ignore: non_constant_identifier_names
  static List<String> get USER_PLACE_LIKE => AppData.userInfo.likePlace ?? List<String>.from([]);
  // ignore: non_constant_identifier_names
  static set USER_PLACE_LIKE(List<String> value) {
    AppData.userInfo.likePlace = value;
  }

  // ignore: non_constant_identifier_names
  static List<String> get USER_EVENT_LIKE => AppData.userInfo.likeEvent ?? List<String>.from([]);
  // ignore: non_constant_identifier_names
  static set USER_EVENT_LIKE(List<String> value) {
    AppData.userInfo.likeEvent = value;
  }

  // ignore: non_constant_identifier_names
  static List<String> get USER_USER_LIKE => AppData.userInfo.likeUser ?? List<String>.from([]);
  // ignore: non_constant_identifier_names
  static set USER_USER_LIKE(List<String> value) {
    AppData.userInfo.likeUser = value;
  }

  static initStartInfo(JSON info) {
    infoData = info;
    LOG('--> initData eventGroup : ${infoData['eventGroup']}');
    if (JSON_NOT_EMPTY(infoData['eventGroup'])) {
      currentEventGroup ??= EventGroupModel.fromJson(infoData['eventGroup'].entries.first.value);
    }
    LOG('--> initData contentType : ${infoData['contentType']}');
    if (JSON_NOT_EMPTY(infoData['contentType']) && currentContentType.isEmpty) {
      var item = infoData['contentType'].entries.first;
      AppData.currentContentType = item.key;
    }
  }

  static setStatusBarColor([bool isDark = false]) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
    ));
  }
}
