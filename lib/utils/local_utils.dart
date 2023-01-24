import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kspot_002/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';
// import 'dart:html' as html;


const _fileLocalInfo = 'info_file.txt';
File? _fileLocalInfoSet;

const _fileStartInfo = 'start_info_file.txt';
File? _fileStartInfoSet;

const _fileUser = 'user_file.txt';
File? _fileUserSet;

const _fileMain = 'main_file.txt';
File? _fileMainSet;
JSON  _mainSet = {};

const _fileMainSeen = 'main_seen_file.txt';
File? _fileMainSeenSet;
JSON  _mainSeenSet = {};

const _fileSearchResult = 'search_file.txt';
File? _fileSearchResultSet;
JSON  _serchResultSet = {};

initLocalData() async {
  _mainSeenSet.clear();
  _serchResultSet.clear();

  await readLocalInfo();
  await readCountryLocal();

  AppData.currentCurrency       = STR(AppData.localInfo['currentCurrency']);
  AppData.isEventGroupGridMode  = BOL(AppData.localInfo['isEventGroupGridMode']);
  AppData.currentEventGroup     = AppData.localInfo['currentEventGroup'] ?? {};
  AppData.currentContentType    = AppData.localInfo['currentContentType'] ?? '';
  AppData.messageReadLog        = AppData.localInfo['messageReadLog'] ?? {};
  AppData.loginInfo.loginType   = AppData.localInfo['loginType'] ?? '';
  AppData.loginInfo.mobile      = AppData.localInfo['phone'] ?? '';
  AppData.loginInfo.mobileIntl  = AppData.localInfo['phoneIntl'] ?? '';
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  LOCAL INFO
//

// Get the data file
Future<File> get fileLocalInfo async {
  if (_fileLocalInfoSet != null) return _fileLocalInfoSet!;
  _fileLocalInfoSet = await _initFileLocalInfo();
  return _fileLocalInfoSet!;
}

// Inititalize file
Future<File> _initFileLocalInfo() async {
  final _directory = await getApplicationDocumentsDirectory();
  final _path = _directory.path;
  LOG('--> _initFileLocalInfo : $_path');
  return File('$_path/$_fileLocalInfo');
}

Future<void> writeLocalInfo() async {
  LOG('--> writeLocalInfo : ${AppData.localInfo}');
  StorageManager.saveData('localInfo', jsonEncode(AppData.localInfo));
  // try {
  //   if (kIsWeb) {
  //     // html.window.localStorage[_fileLocalInfo] = jsonEncode(_localInfotSet);
  //     StorageManager.saveData('localInfo', jsonEncode(AppData.localInfo));
  //   } else {
  //     final File fl = await fileLocalInfo;
  //     await fl.writeAsString(jsonEncode(AppData.localInfo));
  //   }
  // } catch (e) {
  //   LOG('--> writeLocalInfo error : $e');
  // }
}

Future<bool> readLocalInfo() async {
  AppData.localInfo = {};
  var localInfo = await StorageManager.readData('localInfo');
  if (localInfo == null) return false;
  AppData.localInfo = jsonDecode(localInfo);
  return true;
  // try {
  //   if (kIsWeb) {
  //   // if (html.window.localStorage[_fileLocalInfo] != null) {
  //   //   _localInfotSet = jsonDecode(html.window.localStorage[_fileLocalInfo]!);
  //   // }
  //     var localInfo = jsonDecode(await StorageManager.readData('localInfo'));
  //     if (localInfo == null) return false;
  //     AppData.localInfo = localInfo;
  //   } else {
  //     final File fl = await fileLocalInfo;
  //     final _content = await fl.readAsString();
  //     AppData.localInfo = jsonDecode(_content);
  //   }
  //   LOG('--> readLocalInfo : ${AppData.localInfo}');
  //   return true;
  // } catch (e) {
  //   log('--> readLocalInfo error : $e');
  //   return false;
  // }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MAIN
//


// Get the data file
Future<File> get fileMain async {
  if (_fileMainSet != null) return _fileMainSet!;
  _fileMainSet = await _initFileMain();
  return _fileMainSet!;
}

// Inititalize file
Future<File> _initFileMain() async {
  final _directory = await getApplicationDocumentsDirectory();
  final _path = _directory.path;
  log('--> _initFileMain');
  return File('$_path/$_fileMain');
}

Future<void> addAndWriteMain(JSON mainItem) async {
  addMain(mainItem).then((value) =>
      writeMain()
  );
}

addMain(JSON mainItem) async {
  _mainSet[mainItem['id']] = mainItem;
  log('--> addMain : ${mainItem['id']} / ${mainItem.length}');
  return mainItem['id'];
}

Future<void> writeMain() async {
  try {
    if (kIsWeb) {
      // print('--> writeMain : ${_mainSet.length}');
      // html.window.localStorage[_fileMain] = jsonEncode(_mainSet);
    } else {
      final File fl = await fileMain;
      await fl.writeAsString(jsonEncode(_mainSet));
    }
  } catch (e) {
    log('--> writeMain error : $e');
  }
}

JSON? getMain(String mainId) {
  log('--> getMain : $mainId');
  if (_mainSet.containsKey(mainId)) return _mainSet[mainId];
  return null;
}

Future<JSON> readMains() async {
  if (kIsWeb) {
    // if (html.window.localStorage[_fileMain] != null) {
    //   _mainSet = jsonDecode(html.window.localStorage[_fileMain]!);
    // }
  } else {
    try {
      final File fl = await fileMain;
      final _content = await fl.readAsString();
      _mainSet = jsonDecode(_content);
    } catch (e) {
      log('--> readMains error : $e');
    }
  }
  log('--> readMains : $_mainSet / ${_mainSet.length}');
  return _mainSet;
}

Future<void> deleteMain(String mainId) async {
  _mainSet.remove(mainId);
  if (kIsWeb) {
    // html.window.localStorage[_fileMain] = jsonEncode(_mainSet);
  } else {
    final File fl = await fileMain;
    await fl.writeAsString(jsonEncode(_mainSet));
  }
  log('--> deleteMain : $_mainSet');
}

clearMains() async {
  _mainSet.clear();
  writeMain();
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  SEARCH
//


// Get the data file
Future<File> get searchResult async {
  if (_fileSearchResultSet != null) return _fileSearchResultSet!;
  _fileSearchResultSet = await _initSearchResult();
  return _fileSearchResultSet!;
}

// Inititalize file
Future<File> _initSearchResult() async {
  final _directory = await getApplicationDocumentsDirectory();
  final _path = _directory.path;
  log('--> _initSearchResult');
  return File('$_path/$_fileMain');
}

Future<void> addAndWriteSearchResult(JSON mainItem) async {
  addSearchLocalResult(mainItem).then((value) =>
      writeSearchLocalResult()
  );
}

// add search list..
addSearchLocalResult(JSON item) async {
  _serchResultSet['search'][item['id']] = item;
  log('--> addSearchLocalResult : ${item['id']} / ${_serchResultSet.length}');
  return item['id'];
}

addSearchLocalResultAll(JSON itemList) async {
  if (_serchResultSet['search'] == null) _serchResultSet['vote'] = {};
  _serchResultSet['search'].addAll(Map<String, dynamic>.from(itemList));
  writeSearchLocalResult();
}

// add search vote list..
addSearchLocalVoteResult(JSON item) async {
  _serchResultSet['vote'][item['id']] = item;
  log('--> addSearchLocalVoteResult : ${item['id']} / ${_serchResultSet.length}');
  return item['id'];
}

addSearchLocalVoteResultAll(JSON itemList) async {
  if (_serchResultSet['vote'] == null) _serchResultSet['vote'] = {};
  _serchResultSet['vote'].addAll(Map<String, dynamic>.from(itemList));
  writeSearchLocalResult();
}

// Future<void> addAndWriteSearchResultAll(JSON searchList) async {
//   addSearchLocalResultAll(searchList).then((value) =>
//       writeSearchLocalResult()
//   );
// }
//
// addSearchLocalResultAll(JSON mainItem) async {
//   log('--> addSearchLocalResultAll : $mainItem');
//   _serchResultSet.addAll(Map<String, dynamic>.from(mainItem));
//   log('--> addSearchLocalResultAll result : $_serchResultSet');
// }

Future<void> writeSearchLocalResult() async {
  try {
    if (kIsWeb) {
      // print('--> writeSearchLocalResult : ${_serchResultSet.length}');
      // html.window.localStorage[_fileSearchResult] = jsonEncode(_serchResultSet);
    } else {
      final File fl = await searchResult;
      await fl.writeAsString(jsonEncode(_serchResultSet));
    }
    AppData.localInfo['searchTime'] = CURRENT_SERVER_TIME_JSON();
    // AppData.localInfo = FROM_SERVER_DATA(AppData.localInfo);
    writeLocalInfo();
  } catch (e) {
    log('--> writeSearchLocalResult error : $e');
  }
}

JSON? getSearchLocalResult(String mainId) {
  log('--> getSearchLocalResult : $mainId');
  if (_serchResultSet['search'] != null && _serchResultSet['search'].containsKey(mainId)) return _serchResultSet[mainId];
  return null;
}

JSON getSearchLocalResultAll() {
  log('--> getSearchResultAll');
  return _serchResultSet['search'] ?? {};
}

JSON? getSearchLocalVoteResult(String mainId) {
  log('--> getSearchLocalVoteResult : $mainId');
  if (_serchResultSet['vote'] != null && _serchResultSet['vote'].containsKey(mainId)) return _serchResultSet[mainId];
  return null;
}

JSON getSearchLocalVoteResultAll() {
  log('--> getSearchLocalVoteResultAll');
  return _serchResultSet['vote'] ?? {};
}

Future<JSON> readSearchLocalResult() async {
  if (kIsWeb) {
    // if (html.window.localStorage[_fileSearchResult] != null) {
    //   _serchResultSet = jsonDecode(html.window.localStorage[_fileSearchResult]!);
    // }
  } else {
    try {
      final File fl = await searchResult;
      final _content = await fl.readAsString();
      _serchResultSet = jsonDecode(_content);
    } catch (e) {
      log('--> readSearchLocalResult error : $e');
    }
  }
  // log('--> readSearchResult : $_serchResultSet / ${_serchResultSet.length}');
  return _serchResultSet;
}

Future<void> deleteSearchLocalResult(String mainId) async {
  _serchResultSet.remove(mainId);
  if (kIsWeb) {
    // html.window.localStorage[_fileSearchResult] = jsonEncode(_serchResultSet);
  } else {
    final File fl = await searchResult;
    await fl.writeAsString(jsonEncode(_serchResultSet));
  }
  log('--> deleteSearchResult : $_serchResultSet');
}

clearSearchResult() async {
  _serchResultSet.clear();
  writeSearchLocalResult();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Local Cached File
//

// Inititalize file
Future<File> _initLocalFile(String fileName) async {
  final _directory = await getApplicationDocumentsDirectory();
  final _path = _directory.path;
  log('--> _initLocalFile : $_path/tmp/$fileName');
  return File('$_path/$fileName');
}

Future<bool> writeLocalFile(String fileName, String data) async {
  try {
    if (kIsWeb) {
      // html.window.localStorage[_fileUser] = jsonEncode(_userSet);
    } else {
      final File fl = await _initLocalFile(fileName);
      await fl.writeAsString(data);
    }
    LOG('--> writeLocalFile : $fileName');
  } catch (e) {
    LOG('--> writeLocalFile error : $e');
  }
  return true;
}

Future<String> readLocalFile(String fileName) async {
  var result = '';
  try {
    if (kIsWeb) {
      // if (html.window.localStorage[_fileUser] != null) {
      //   _userSet = jsonDecode(html.window.localStorage[_fileUser]!);
      // }
    } else {
      final File fl = await _initLocalFile(fileName);
      result = await fl.readAsString();
    }
    LOG('--> readLocalFile : $fileName / ${result.length}');
  } catch (e) {
    LOG('--> readLocalFile error : $e');
  }
  return result;
}
