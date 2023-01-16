import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/start_model.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';

const SCROLL_SPEED = 250;
const APP_VERSION = '0.0.1';
const ORG_SCREEN_WITH = 411;
const GOOGLE_MAP_KEY = 'AIzaSyD4ESmTaou10BumFoJ7DQ7jkTI7emh4Hvo';

class AppData {
  static final AppData _singleton = AppData._internal();
  AppData._internal();

  static StartModel? startData;
  static UserModel?  userInfo;
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
  static DateTime? currentDate;
  static JSON currentPlaceGroup = {};
  static JSON selectEventTime = {};
  static JSON messageReadLog = {};

  static BuildContext? topMenuContext;
}
