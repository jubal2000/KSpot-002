
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_data.dart';
import '../core/utils.dart';

const _LocalData = 'local_data.txt';
File? _LocalDataSet;

class LocalService extends GetxService {
  Future<LocalService> init() async {
    await initService();
    return this;
  }

  JSON _localData = {};

  Future<void> initService() async {
    await readLocalData();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  LOCAL INFO
//

// Get the data file
  Future<File> get fileLocalInfo async {
    if (_LocalDataSet != null) return _LocalDataSet!;
    _LocalDataSet = await _initLocalData();
    return _LocalDataSet!;
  }

// Inititalize file
  Future<File> _initLocalData() async {
    final _directory = await getApplicationDocumentsDirectory();
    final _path = _directory.path;
    LOG('--> _initFileLocalInfo : $_path');
    return File('$_path/$_LocalData');
  }

  Future<void> writeLocalData(String key, JSON data) async {
    _localData[key] = data;
    LOG('--> writeLocalInfo : $_localData');
    StorageManager.saveData('localInfo', jsonEncode(_localData));
  }

  Future<bool> readLocalData() async {
    _localData = {};
    var localInfo = await StorageManager.readData('localInfo');
    if (localInfo == null) return false;
    _localData = jsonDecode(localInfo);
    LOG('--> readLocalData : $_localData');
    return true;
  }
}


class StorageManager {
  static void saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      prefs.setInt(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    } else {
      LOG("--> StorageManager error : Invalid Type (${value.runtimeType})");
    }
  }

  static Future<dynamic> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic obj = prefs.get(key);
    LOG('--> readData : $key / $obj / ${obj.runtimeType}');
    return obj;
  }

  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
