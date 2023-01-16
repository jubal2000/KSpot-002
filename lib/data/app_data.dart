import 'package:flutter/material.dart';
import '../models/start_model.dart';
import 'utils.dart';

const SCROLL_SPEED = 250;
const APP_VERSION = '0.0.1';
const ORG_SCREEN_WITH = 411;

class AppData {
  static final AppData _singleton = AppData._internal();
  AppData._internal();

  static StartModel? startData;
  static JSON userInfo = {};
  static JSON listSelectData = {};

  static int? localDataVer;
  static List<String>? localAppData;

  static var currentThemeMode = false;
  static var currentThemeIndex = 0;
}
