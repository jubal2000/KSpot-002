
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/utils.dart';
import 'firebase_service.dart';


//----------------------------------------------------------------------------------------
//
//    start info..
//

enum USER_INFO_OPTION {
  history,
  goods,
  follow,
  store,
}

const FREE_LOADING_STORY_MAX = 3;
const FREE_LOADING_QNA_MAX = 10;
const SEARCH_ITEM_MAX = 20;


// ignore: non_constant_identifier_names
FROM_SERVER_DATA(data) {
  return SET_SERVER_TIME_ALL(data);
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME_ALL(data) {
  if (data is Map) {
    for (var item in data.entries) {
      data[item.key] = SET_SERVER_TIME_ALL_ITEM(item.value);
    }
  } else if (data is List) {
    data = SET_SERVER_TIME_ALL_ITEM(data);
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME_ALL_ITEM(data) {
  if (data is Timestamp) {
    data = SET_SERVER_TIME(data);
  } else if (data is Map) {
    data = SET_SERVER_TIME_ALL(data);
  } else if (data is List) {
    for (var i=0; i<data.length; i++) {
      data[i] = SET_SERVER_TIME_ALL_ITEM(data[i]);
    }
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME(timestamp) {
  if (timestamp is Timestamp) {
    return '${timestamp.seconds}';
    // return {
    //   '_seconds': timestamp.seconds,
    //   '_nanoseconds': timestamp.nanoseconds,
    // };
  } else {
    return timestamp;
  }
}

// ignore: non_constant_identifier_names
TO_SERVER_DATA(data) {
  return SET_TO_SERVER_TIME_ALL(data);
}

// ignore: non_constant_identifier_names
SET_TO_SERVER_TIME_ALL(data) {
  if (data is Map) {
    if (data['_seconds'] != null) {
      return Timestamp(data['_seconds'], data['_nanoseconds']);
    }
    for (var item in data.entries) {
      data[item.key] = SET_TO_SERVER_TIME_ALL_ITEM(item.value);
    }
  } else if (data is List) {
    data = SET_TO_SERVER_TIME_ALL_ITEM(data);
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_TO_SERVER_TIME_ALL_ITEM(data) {
  if (data is Map) {
    data = SET_TO_SERVER_TIME_ALL(data);
  } else if (data is List) {
    for (var i=0; i<data.length; i++) {
      data[i] = SET_TO_SERVER_TIME_ALL_ITEM(data[i]);
    }
  }
  return data;
}

class ApiService extends GetxService {
  Future<ApiService> init() async {
    initFirebase();
    return this;
  }

  FirebaseService?   firebase;
  FirebaseFirestore? firestore;

  initFirebase() {
    firebase      = Get.find<FirebaseService>();
    firestore     = firebase!.firestore;
  }

  final StartInfoCollection = 'info_start';

  Future<JSON?> getAppStartInfo(String infoId) async {
    LOG('--> getStartInfo [$infoId] : $firestore');
    try {
      var collectionRef = firestore!.collection(StartInfoCollection);
      var querySnapshot = await collectionRef.doc(infoId).get();
      if (querySnapshot.data() != null) {
        LOG('--> getAppStartInfo result : ${FROM_SERVER_DATA(querySnapshot.data())}');
        return FROM_SERVER_DATA(querySnapshot.data());
      }
    } catch (e) {
      LOG('--> getStartInfo Error : $e');
    }
    return null;
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  Future<JSON> getInfoData() async {
    // if (AppData.infoData.isNotEmpty) return AppData.infoData;
    // try {
    //   HttpsCallable callable = firefunctions.httpsCallable('getInfoData');
    //   final resp = await callable.call(<String, dynamic>{});
    //   AppData.infoData = resp.data;
    //   LOG('--> AppData.infoData Ready');
    // } catch (e) {
    //   LOG('--> getInfoData error : $e');
    // }
    // if (AppData.localInfo['infoVersion'] != AppData.startInfo['infoVersion']) {
    JSON result = {};
    if (true) { // for Dev..
      final infoDB = [
        'info_notice',
        'info_faq',
        'info_refund',
        'info_contentType',
        'info_promotion',
        'info_option',
        'info_declare',
        'info_currency',
        'info_customField',
        'data_eventGroup',
      ];
      final outName = [
        'notice',
        'faq',
        'refund',
        'contentType',
        'promotion',
        'option',
        'declare',
        'currency',
        'customField',
        'eventGroup',
      ];
      for (var i = 0; i < infoDB.length; i++) {
        result[outName[i]] = {};
        var ref = firestore!.collection(infoDB[i]);
        var querySnapshot = await ref.get();
        var infoData = {};
        for (var doc in querySnapshot.docs) {
          infoData[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
        }
        result[outName[i]] = infoData;
        // resultData[outName[i]] = JSON_INDEX_SORT_ASCE(infoData);
        LOG('--> infoData add [${outName[i]}]');
      }

      // var docsData = snapshot.docs.map(doc => doc.data());
      // AppData.infoData = result;
      // AppData.INFO_CURRENCY = JSON_INDEX_SORT_ASCE(AppData.INFO_CURRENCY);
      // // LOG('--> get infoData from SERVER : ${AppData.INFO_EVENT_OPTION}');
      // if (AppData.currentCurrency.isEmpty && JSON_NOT_EMPTY(AppData.INFO_CURRENCY)) AppData.currentCurrency = AppData.INFO_CURRENCY.entries.first.key;
      //
      // AppData.localInfo['infoVersion'] = AppData.startInfo!.infoVersion;
      // AppData.localInfo['currency'] = AppData.currentCurrency;
      // writeLocalInfo(); // 앱 로컬저장 정보.. AppData.localInfo
      // writeStartInfo(); // 앱 시작 정보..    AppData.infoData
    // } else {
      // AppData.infoData = {};
      // // AppData.infoData.addAll(AppData.infoLocalData);
      // LOG('--> get infoData from LOCAL : ${AppData.infoData}');
    }
    // getBlockList(user);
    return result;
  }
  
  Future<JSON> getStartInfoData() async {
    LOG('------> getStartInfoData');
    // if (AppData.infoData.isNotEmpty) return AppData.infoData;
    // try {
    //   HttpsCallable callable = firefunctions.httpsCallable('getInfoData');
    //   final resp = await callable.call(<String, dynamic>{});
    //   AppData.infoData = resp.data;
    //   LOG('--> AppData.infoData Ready');
    // } catch (e) {
    //   LOG('--> getInfoData error : $e');
    // }
    final infoDB  = ['info_categoryType','info_category'];
    final outName = ['categoryType','category'];
    JSON result = {};
    for (var i=0; i<infoDB.length; i++) {
      result[outName[i]] = {};
      var ref = firestore!.collection(infoDB[i]);
      var querySnapshot = await ref.get();
      for (var doc in querySnapshot.docs) {
        result[outName[i]][doc.data()['id']] = FROM_SERVER_DATA(doc.data());
        // LOG('--> resultData [${outName[i]}]: ${doc.data()}');
      }
    }
    // var docsData = snapshot.docs.map(doc => doc.data());
    LOG('----> getInfoDataList result : ${result['categoryType']}');
    // AppData.startInfoData = result;
    return result;
  }
  
  
  //----------------------------------------------------------------------------------------
  //
  //    user..
  //
  
  final UserCollection = 'data_user';
  
  Future<JSON?> getStartUserInfo(String loginId) async {
    LOG('--> getStartUserInfo : $loginId');
    try {
      var snapshot = await firestore!.collection(UserCollection)
          .where('status', isGreaterThan: 0)
          .where('loginId', isEqualTo: loginId)
          .limit(1)
          .get();
  
      if (snapshot.docs.isNotEmpty) {
        return FROM_SERVER_DATA(snapshot.docs.first.data());
      //   AppData.userInfo = snapshot.docs.first.data();
      //   var userId = AppData.userInfo['id'];
      //   // var options = [USER_INFO_OPTION.history, USER_INFO_OPTION.goods, USER_INFO_OPTION.follow];
      //   List<USER_INFO_OPTION> options = [USER_INFO_OPTION.follow];
      //   AppData.userInfo = await getUserInfoEx(AppData.userInfo, userId, options);
      //   LOG('--> getStartUserInfo result : $userId / ${AppData.userInfo}');
      //   return {'result': 0};
      // } else {
      //   LOG('--> getStartUserInfo no user');
      //   return {'result': 1, 'error' : 'no_user_data'};
      }
    } catch (e) {
      LOG('--> getStartUserInfo Error : $e');
    }
    return null;
  }

  Future<JSON?> getUserInfoFromId(String userId) async {
    LOG('--> getUserInfoFromId : $userId');
    try {
      // if (AppData.userInfoList.containsKey(userId)) {
      //   var cacheTime = TME(AppData.userInfoList[userId]['cacheTime']);
      //   var remainTime = cacheTime.difference(DateTime.now()).inHours;
      //   // LOG('--> getUserInfoFromIdFire cached result : $userId / $remainTime');
      //   if (remainTime < 24) {
      //     return AppData.userInfoList[userId];
      //   }
      // }
      var snapshot = await firestore!.collection(UserCollection)
          .doc(userId)
          .get();

      if (snapshot.data() != null) {
        // var result = FROM_SERVER_DATA(snapshot.data() as JSON);
        // writeUser(result);
        // // LOG('--> getUserInfoFromIdFire result : $userId / ${AppData.userInfoList.length}');
        return FROM_SERVER_DATA(snapshot.data());
      }
    } catch (e) {
      LOG('--> getUserInfoFromId Error : $e');
    }
    return null;
  }

  Future<JSON> getUserInfoEx(JSON user, List<USER_INFO_OPTION> optionList) async {
    JSON ownerInfo = {};
    final userId = user['id'];
    // log('--> getUserInfoEx : ' + userId);
    if (optionList.contains(USER_INFO_OPTION.history)) {
      ownerInfo['storyData'] = await getStoryFromUserId(userId);
    }
    if (optionList.contains(USER_INFO_OPTION.goods)) {
      ownerInfo['eventData'] = await getEventFromId(userId);
    }
    if (optionList.contains(USER_INFO_OPTION.follow)) {
      ownerInfo['followData'] = await getFollowList(userId);
    }
    return ownerInfo;
  }
  
  Future<JSON?> createNewUser(JSON newUser, [int status = 1]) async {
    try {
      var ref = firestore!.collection(UserCollection);
      var key = ref.doc().id;
      LOG('--> createNewUser $key : $newUser');
      if (newUser['id'] == null || newUser['id'].isEmpty) {
        newUser['id'] = key;
      }
      newUser['status'] = status;
      newUser['createTime'] = CURRENT_SERVER_TIME();

      await ref.doc(key).set(newUser);
      return FROM_SERVER_DATA(newUser);
    } catch (e) {
      LOG('--> createNewUser error : ${e.toString()}');
    }
    return null;
  }
  
  Future<bool> setUserInfo(JSON userInfo) async {
    try {
      var ref = firestore!.collection(UserCollection);
      userInfo['updateTime'] = CURRENT_SERVER_TIME();
      await ref.doc(userInfo['id']).set(userInfo);
      return true;
    } catch (e) {
      LOG('--> setUserInfo error : ${e.toString()}');
    }
    return false;
  }
  
  Future<bool> setUserInfoJSON(String userId, JSON items) async {
    LOG('--> setUserInfoJSON : $userId / $items');
    if (userId.isEmpty) return false;
    var ref = firestore!.collection(UserCollection);
    return ref.doc(userId).update(Map<String, dynamic>.from(items)).then((result) {
      return true;
    }).onError((e, stackTrace) {
      LOG('--> setUserInfoJSON error : $userId / $e');
      return false;
    });
  }
  
  Future<bool> setUserInfoItem(JSON userInfo, String key) async {
    LOG('--> setUserInfoItem : ${userInfo['id']} - $key / ${userInfo[key]}');
    var ref = firestore!.collection(UserCollection);
    return ref.doc(userInfo['id']).update(
      {
        key : userInfo[key],
        'updateTime': CURRENT_SERVER_TIME()
      }
    ).then((result) {
      return true;
    }).onError((e, stackTrace) {
      LOG('--> setUserInfo error : ${userInfo['id']} / $e');
      return false;
    });
  }
  
  Future<JSON?> setUserFollowCount(JSON user, String targetId, [int count = 1]) async {
    final userId = user['id'];
    LOG('--> setUserFollowCount : $userId -> $targetId / $count');
    var userInfo = await getUserInfoFromId(targetId);
    if (userInfo != null) {
      var followerCount  = INT(userInfo['follower']) + count;
      var followingCount = INT(user['follow']) + count;
      if (followerCount  < 0) followerCount  = 0;
      if (followingCount < 0) followingCount = 0;
      await setUserInfoJSON(targetId, {
        'follower' : followerCount
      });
      await setUserInfoJSON(userId, {
        'follow' : followingCount
      });
      user['follow'] = followingCount;
      LOG('--> setUserFollowCount result : $followingCount');
      return user;
    }
    return null;
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    EVENT GROUP Functions
  //
  
  
  final EventGroupCollection  = 'data_eventGroup';

  Future<JSON> getEventGroupList() async {
    // log('--> getPlaceGroupList');
    JSON result = {};
    var ref = firestore!.collection(EventGroupCollection);
    var snapshot = await ref.where('status', isEqualTo: 1)
        .get();
  
    for (var doc in snapshot.docs)  {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    LOG('--> getEventGroupList result : $result');
    return result;
  }
  
  Future<JSON> getEventGroupFromId(String groupId) async {
    // log('--> getEventGroupFromId');
    JSON result = {};
    try {
      var ref = firestore!.collection(EventGroupCollection);
      var snapshot = await ref.doc(groupId).get();
      result = FROM_SERVER_DATA(snapshot.data());
    } catch (e) {
      LOG('--> getPlaceGroupFromId error [$groupId] : $e');
    }
    return result;
  }
  
  Future<JSON?> addEventGroupItem(JSON addItem) async {
    try {
      var ref = firestore!.collection(EventGroupCollection);
      var key = addItem['id'];
      if (key == null || key.isEmpty) {
        key = ref.doc().id;
        addItem['id'] = key;
        addItem['createTime'] = CURRENT_SERVER_TIME();
      }
      addItem['updateTime'] = CURRENT_SERVER_TIME();
      await ref.doc(key).set(Map<String, dynamic>.from(addItem));
      return FROM_SERVER_DATA(addItem);
    } catch (e) {
      LOG('--> addPlaceGroupItem error : $e');
    }
    return null;
  }
  
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    PLACE Functions
  //

  final PlaceCollection = 'data_place';
  
  Future<JSON> getPlaceList(String groupId) async {
    LOG('--> getPlaceList : $groupId');
    JSON result = {};
    var ref = firestore!.collection(PlaceCollection);
    var snapshot = await ref.where('status', isEqualTo: 1)
        .where('groupId', isEqualTo: groupId)
        .get();
  
    for (var doc in snapshot.docs) {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    LOG('--> getPlaceList result : ${result.length}');
    return result;
  }
  
  Future<JSON> getPlaceListWithCountry(String groupId, String country, [String countryState = '']) async {
    LOG('--> getPlaceListWithCountry : $groupId / $country / $countryState');
    JSON result = {};
    var ref = firestore!.collection(PlaceCollection);
    var query = ref.where('status', isEqualTo: 1)
        .where('groupId', isEqualTo: groupId);

    if (country.isNotEmpty) {
      query = query.where('country', isEqualTo: country);
      if (countryState.isNotEmpty) {
        query = query.where('countryState', isEqualTo: countryState);
      }
    }
    var snapshot = await query.get();
    for (var doc in snapshot.docs) {
      var item = doc.data();
      result[item['id']] = FROM_SERVER_DATA(item);
    }
    LOG('--> getPlaceListWithCountry result : ${result.length}');
    return result;
  }

  Future<JSON> getPlaceListFromUserId(String userId) async {
    LOG('--> getPlaceListFromUserId : $userId');
    JSON result = {};
    var ref = firestore!.collection(PlaceCollection);
    var snapshot = await ref.where('status', isGreaterThan: 0)
        .where('userId', isEqualTo: userId)
        .get();
  
    for (var doc in snapshot.docs) {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    LOG('--> getPlaceListFromUserId result : ${result.length}');
    return result;
  }
  
  Future<JSON?> getPlaceFromId(String placeId) async {
    LOG('--> getPlaceFromId : $placeId');
    var ref = firestore!.collection(PlaceCollection);
    var snapshot = await ref.where('status', isGreaterThan: 0)
        .where('id', isEqualTo: placeId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      JSON result = FROM_SERVER_DATA(snapshot.docs.first.data());
      return result;
    }
    return null;
  }
  
  Future<JSON> getPlaceLinkDataAll(List<dynamic>? linkList) async {
    LOG('--> getPlaceLinkDataAll : $linkList');
    JSON result = {};
    if (linkList != null && linkList.isNotEmpty) {
      for (var item in linkList) {
        var place = await getPlaceFromId(item.toString());
        if (place != null && place.isNotEmpty) {
          result[place['id']] = place;
        }
      }
    }
    return result;
  }
  
  Future<JSON> getPlaceListFromManaged(String userId) async {
    // log('--> getPlaceList : $parentId');
    JSON result = {};
    var ref = firestore!.collection(PlaceCollection);
    var snapshot1 = await ref.where('status', isGreaterThan: 0)
        .where('userId', isEqualTo: userId)
        .get();
    var snapshot2 = await ref.where('status', isGreaterThan: 0)
        .where('managerData', arrayContains: userId)
        .get();
    for (var doc in snapshot1.docs)  {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    for (var doc in snapshot2.docs)  {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    LOG('--> getPlaceListFromManaged result : $result');
    // firestoreCacheData['follow'][userId] = FROM_SERVER_DATA(result);
    return result;
  }
  
  Future<JSON?> addPlaceItem(JSON addItem) async {
    var ref = firestore!.collection(PlaceCollection);
    var key = STR(addItem['id']);
    if (key.isEmpty) {
      key = ref.doc().id;
      addItem['id'] = key;
      addItem['createTime'] = CURRENT_SERVER_TIME();
      LOG('------> addPlaceItem NEW : $addItem');
    } else {
      LOG('------> addPlaceItem REPLACE : $addItem');
    }
    addItem['updateTime'] = CURRENT_SERVER_TIME();
    try {
      await ref.doc(key).set(addItem);
      return FROM_SERVER_DATA(addItem);
    } catch (e) {
      LOG('--> addPlaceItem error : $e');
    }
    return null;
  }
  
  Future<bool> setPlaceItemStatus(String placeId, int status) async {
    LOG('------> setPlaceItemStatus : $placeId / $status');
    try {
      var ref = firestore!.collection(PlaceCollection);
      await ref.doc(placeId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      LOG('--> setPlaceItemStatus error : $e');
    }
    return false;
  }
  
  Future<JSON?> setPlaceItemFromId(String placeId, JSON updateItem) async {
    var dataRef = firestore!.collection(PlaceCollection);
    try {
      await dataRef.doc(placeId).update(Map<String, dynamic>.from(updateItem));
      JSON result = FROM_SERVER_DATA(updateItem);
      LOG('--> setPlaceItemFromId result : $result');
      return result;
    } catch (e) {
      LOG('--> setPlaceItem error : $e');
    }
    return null;
  }


  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    EVENT Functions
  //

  final EventCollection = 'data_event';
  
  Future<JSON> getEventListFromCountry(String groupId, String country, [String countryState = '']) async {
    LOG('--> getEventListFromCountry : $groupId / $country / $countryState');
    JSON result = {};
    var ref = firestore!.collection(EventCollection);
    var query = ref.where('status', isEqualTo: 1);
  
    if (groupId.isNotEmpty) {
      query = query.where('groupId', isEqualTo: groupId);
    }
    if (country.isNotEmpty) {
      query = query.where('country', isEqualTo: country);
      if (countryState.isNotEmpty) {
        query = query.where('countryState', isEqualTo: countryState);
      }
    }
  
    var snapshot = await query.get();
    for (var doc in snapshot.docs)  {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
      LOG('--> add event : ${doc.data()['id']}');
    }
    // result = await cleanEventExpire(result);
    LOG('--> getEventListFromCountry result : ${result.length}');
    return result;
  }

  Future<JSON> getEventLinkDataAll(List<dynamic>? linkList) async {
    log('--> getEventLinkDataAll : $linkList');
    JSON result = {};
    if (linkList != null && linkList.isNotEmpty) {
      for (var item in linkList) {
        var event = await getEventFromId(item.toString());
        if (event != null) {
          result[event['id']] = event;
        }
      }
    }
    return result;
  }
  
  Future<JSON> getEventSearch(String searchText) async {
    log('--> getPlaceEventSearch : $searchText');
    var targetField = [[1, 'search'], [1, 'tagData']]; // 0: text, 1: array
    var result = await getSearchItem(EventCollection, searchText, targetField);
    result = await cleanEventExpire(result);
    LOG('--> getPlaceEventSearch result : $result');
    return result;
  }
  
  Future<JSON> getEventListFromId(String placeId) async {
    // log('--> getPlaceEventList : placeId');
    JSON result = {};
    var ref = firestore!.collection(EventCollection);
    var snapshot = await ref.where('status', isGreaterThan: 0)
        .where('placeId', isEqualTo: placeId)
        .get();

    for (var doc in snapshot.docs)  {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    // firestoreCacheData['follow'][userId] = FROM_SERVER_DATA(result);
    result = await cleanEventExpire(result);
    LOG('--> getEventListFromId result [${result.length}] : $result');
    return result;
  }
  
  Future<JSON> getEventListFromGroupId(String groupId) async {
    // LOG('--> getPlaceEventList : placeId');
    JSON result = {};
    var ref = firestore!.collection(EventCollection);
    var snapshot = await ref.where('status', isGreaterThan: 0)
        .where('groupId', isEqualTo: groupId)
        .get();
  
    for (var doc in snapshot.docs)  {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    result = await cleanEventExpire(result);
    LOG('--> getEventListFromGroupId result : ${result.length}');
    return result;
  }
  
  Future<JSON?> getEventFromId(String eventId) async {
    LOG('--> getEventFromId : $eventId');
    try {
      var ref = firestore!.collection(EventCollection);
      var snapshot = await ref.where('status', isGreaterThan: 0)
          .where('id', isEqualTo: eventId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        JSON result = FROM_SERVER_DATA(snapshot.docs.first.data());
        LOG('--> getEventFromId result : $result');
        return result;
      }
    } catch (e) {
      LOG('--> getEventFromId error : $e');
    }
    return null;
  }
  
  Future<JSON?> getEventFromUserId(String userId, [bool addExpiredItem = false]) async {
    // LOG('--> getPlaceEventFromUserId : userId');
    JSON result = {};
    var ref = firestore!.collection(EventCollection);
    var snapshot1 = await ref.where('status', isGreaterThan: 0)
        .where('userId', isEqualTo: userId)
        .get();
  
    for (var doc in snapshot1.docs)  {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    result = await cleanEventExpire(result, addExpiredItem);
    LOG('--> getEventFromUserId result : $result');
    return result;
  }

  Future<JSON> getEventListFromManaged(String userId, [bool addExpiredItem = false]) async {
    // LOG('--> getPlaceEventListFromManaged : userId');
    JSON result = {};
    var ref = firestore!.collection(EventCollection);
    var snapshot = await ref.where('status', isGreaterThan: 0)
        .where('managerList', arrayContains: userId)
        .get();
    for (var doc in snapshot.docs)  {
      result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
    }
    result = await cleanEventExpire(result, addExpiredItem);
    LOG('--> getEventListFromManaged result : $result');
    return result;
  }

  Future<JSON> cleanEventExpire(JSON eventData, [bool addExpiredItem = false]) async {
    JSON result = {};
    try {
      for (var item in eventData.entries) {
        var isExpired = checkIsExpired(item.value);
        if (isExpired) {
          if (await setEventStatus(item.key, 2)) {
            LOG('-----------> cleanEventExpire isExpired ${item.key}');
          }
        }
        if (addExpiredItem || !isExpired) {
          result[item.key] = item.value;
        }
      }
    } catch (e) {
      LOG('--> cleanEventExpire error : $e');
    }
    return result;
  }
  
  checkIsExpired(JSON item) {
    var addCount = 0;
    var today = DateTime.parse(DATE_STR(DateTime.now()));
    if (JSON_NOT_EMPTY(item['timeData'])) {
      for (var time in item['timeData'].entries) {
        // LOG('--> checkIsExpired item dayData [${item['id']}] / ${time.value['dayData']}');
        if (LIST_NOT_EMPTY(time.value['day'])) {
          for (var day in time.value['day']) {
            var days = DateTime.parse(STR(day)).difference(today).inDays;
            // LOG('--> check [${item['id']}] : dayData - ${STR(item['targetDate'])} / $today -> $days');
            if (days >= 0) {
              addCount++;
              break;
            }
          }
        } else if (STR(time.value['endDate']).isNotEmpty) {
          var days = DateTime.parse(STR(time.value['endDate'])).difference(today).inDays;
          // LOG('--> check [${item['id']}] : endDate - ${STR(time.value['endDate'])} / $today -> $days');
          if (days >= 0) {
            addCount++;
          }
        } else if (STR(time.value['startDate']).isNotEmpty) {
          var days = DateTime.parse(STR(time.value['startDate'])).add(Duration(days: 365)).difference(today).inDays;
          // LOG('--> check [${item['id']}] : startDate - ${STR(time.value['endDate'])} / $today -> $days');
          if (days >= 0) {
            addCount++;
          }
        }
        if (addCount > 0) break; // addCount 가 0 이상이면 굳이 다 돌릴 필요없슴.
      }
      // LOG('--> checkIsExpired result [${item['id']}] => ${addCount <= 0} / $addCount / ${item['title']} - ${item['timeData']}');
      return addCount == 0;
    } else {
      return false;
    }
  }
  
  Future<bool> setEventStatus(String eventId, int status) async {
    // LOG('------> setEventItemStatus : $eventId / $status');
    try {
      var ref = firestore!.collection(EventCollection);
      await ref.doc(eventId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      LOG('--> setEventStatus error : $e');
    }
    return false;
  }
  
  Future<JSON?> addEventItem(JSON addItem) async {
    var ref = firestore!.collection(EventCollection);
    try {
      var key = STR(addItem['id']);
      if (key.isEmpty) {
        key = ref.doc().id;
        addItem['id'] = key;
        addItem['createTime'] = CURRENT_SERVER_TIME();
      }
      addItem['updateTime'] = CURRENT_SERVER_TIME();
      LOG('------> addEventItem : $addItem');
      await ref.doc(key).set(addItem);
      return FROM_SERVER_DATA(addItem);
    } catch (e) {
      LOG('--> addEventItem error : $e');
    }
    return null;
  }


  Future<JSON> setEventItemFromId(String placeId, JSON updateItem) async {
    JSON result = {};
    var dataRef = firestore!.collection(EventCollection);
    try {
      await dataRef.doc(placeId).update(Map<String, dynamic>.from(updateItem));
      result = FROM_SERVER_DATA(updateItem);
    } catch (e) {
      LOG('--> setEventItemFromId error : $e');
    }
    LOG('--> setEventItemFromId result : $result');
    return result;
  }


  //----------------------------------------------------------------------------------------
  //
  //    STORY function..
  //

  final StoryCollection = 'data_story';

  Future<JSON> getStoryFromId(String storyId) async {
    JSON result = {};
    var snapshot = await firestore!.collection(StoryCollection).doc(storyId).get();
    if (snapshot.data() != null) {
      result = FROM_SERVER_DATA(snapshot.data());
    }
    LOG('--> getStoryFromId Result : $result');
    return result;
  }

  Future<JSON> getStoryFromTargetId(String parentID) async {
    JSON result = {};

    var snapshot = await firestore!.collection(StoryCollection)
        .where('status', isEqualTo: 1)
        .where('targetId', isEqualTo: parentID)
        .get();

    for (var doc in snapshot.docs) {
      var item = FROM_SERVER_DATA(doc.data());
      result[item['id']] = item;
    }
    result = JSON_CREATE_TIME_SORT_DESC(result);
    LOG('--> getStoryFromParentId Result : ${result.length}');
    return result;
  }

  Future<JSON> getStoryFromUserId(String userId, [int status = 0]) async {
    JSON result = {};

    var ref = firestore!.collection(StoryCollection);
    var snapshot = await ref.where('userId', isEqualTo: userId)
        .where('status', isGreaterThan: 0)
        .get();

    for (var doc in snapshot.docs) {
      var item = FROM_SERVER_DATA(doc.data());
      result[item['id']] = item;
    }
    result = JSON_CREATE_TIME_SORT_DESC(result);
    LOG('--> getStoryFromUserId Result : ${result.length}');
    return result;
  }

  Stream getStoryStreamFromId(String parentID) {
    return firestore!.collection(StoryCollection)
        .where('status', isEqualTo: 1)
        .where('targetId', isEqualTo: parentID)
        .snapshots();
  }

  Stream getStoryStreamFromGroup(String groupId) {
    LOG('------> getStoryStreamFromGroup : $groupId');
    var ref = firestore!.collection(StoryCollection);
    var query = ref
        .where('status', isEqualTo: 1)
        .where('groupId', isEqualTo: groupId);
    return query.orderBy('createTime', descending: true).limit(FREE_LOADING_STORY_MAX).snapshots();
  }

  Stream getStoryStreamFromGroupNext(JSON lastTime, String groupId) {
    LOG('------> getStoryStreamFromGroupNext : $lastTime / $groupId');
    var ref = firestore!.collection(StoryCollection);
    var query = ref
        .where('status', isEqualTo: 1)
        .where('groupId', isEqualTo: groupId);

    if (JSON_NOT_EMPTY(lastTime)) {
      var startTime = Timestamp(lastTime['_seconds'], lastTime['_nanoseconds']);
      LOG('--> startTime : $startTime');
      query = query.where('createTime', isLessThan: startTime);
    }
    return query.orderBy('createTime', descending: true).limit(FREE_LOADING_STORY_MAX).snapshots();
  }

  Future<bool> setStoryItemUserInfo(String targetId, JSON storyInfo) async {
    LOG('--> setStoryItemUserInfo : $targetId / ${storyInfo['userName']} / ${storyInfo['userPic']}');
    try {
      var ref = firestore!.collection(StoryCollection);
      await ref.doc(targetId).update({
        'userName' : storyInfo['userName'],
        'userPic'  : storyInfo['userPic'],
      });
    } catch (e) {
      LOG('--> setStoryItemUserInfo Error : $e');
      return true;
    }
    return false;
  }

  Future<bool> deleteStoryItem(String targetId) async {
    return await setStoryItemStatus(targetId, 0);
  }

  Future<bool> setStoryItemStatus(String targetId, int status) async {
    try {
      var ref = firestore!.collection(StoryCollection);
      await ref.doc(targetId).update({
        'status' : status,
      });
      return true;
    } catch (e) {
      LOG('--> setStoryItemStatus Error : $e');
    }
    return false;
  }

  Future<bool> setStoryItemData(String targetId, JSON data) async {
    try {
      var ref = firestore!.collection(StoryCollection);
      await ref.doc(targetId).update(data);
      return true;
    } catch (e) {
      LOG('--> setStoryItemData Error : $e');
    }
    return false;
  }

  Future<JSON?> addStoryItem(JSON addItem) async {
    LOG('------> addStoryItem : $addItem');
    var ref = firestore!.collection(StoryCollection);
    try {
      var key = STR(addItem['id']).toString();
      if (key.isEmpty) {
        key = ref.doc().id;
        addItem['createTime'] = CURRENT_SERVER_TIME();
      }
      addItem['id'] = key;
      addItem['updateTime'] = CURRENT_SERVER_TIME();

      await ref.doc(key).set(addItem);
      JSON result = FROM_SERVER_DATA(addItem);
      return result;
    } catch (e) {
      LOG('--> addStoryItem Error : $e');
    }
    return null;
  }


  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    FOLLOW Functions
  //
  
  final FollowCollection = 'data_follow';
  
  Future<JSON> getFollowList(String userId, [int status = 0]) async {
    JSON result = {};
    var ref = firestore!.collection(FollowCollection);
    try {
      var snapshot1 = await ref.where('status', isGreaterThan: status)
          .where('userId', isEqualTo: userId)
          .get();
      var snapshot2 = await ref.where('status', isGreaterThan: status)
          .where('targetId', isEqualTo: userId)
          .get();
  
      for (var doc in snapshot1.docs)  {
        result[doc.data()['id']] = doc.data();
        result[doc.data()['id']]['type'] = 0;
      }
      for (var doc in snapshot2.docs)  {
        result[doc.data()['id']] = doc.data();
        result[doc.data()['id']]['type'] = 1;
      }
      LOG('--> getFollowList result : $result');
    } catch (e) {
      LOG('--> getFollowList error : $e');
    }
    return result;
  }
  
  Future<JSON> addFollowTarget(JSON user, JSON targetInfo) async {
    var ref = firestore!.collection(FollowCollection);
    var key = ref.doc().id;
    var addItem = {
      'id'        : key,
      'status'    : 1,
      'targetId'  : targetInfo['userId'  ] ?? targetInfo['id'],
      'targetName': targetInfo['userName'] ?? targetInfo['nickName'],
      'targetPic' : targetInfo['userPic' ] ?? targetInfo['pic'],
      'userId'    : user['id'],
      'userName'  : user['nickName'],
      'userPic'   : user['pic'],
      'createTime': CURRENT_SERVER_TIME(),
    };
    return ref.doc(key).set(addItem).then((result2) {
      setUserFollowCount(user, addItem['targetId'], 1); // no await
      user['followData'] ??= {};
      user['followData'][addItem['id']] = FROM_SERVER_DATA(addItem);
      return user;
    }).onError((e, stackTrace) {
      LOG('--> addFollowTarget error : $e');
      return {};
    });
  }
  
  Future<String> setFollowStatus(JSON user, String targetId, int status) async {
    var ref = firestore!.collection(FollowCollection);
    var snapshot = await ref.where('status', isEqualTo: 1)
        .where('targetId', isEqualTo: targetId)
        .limit(1)
        .get();
  
    if (snapshot.docs.isNotEmpty)  {
      var followId = snapshot.docs.first.data()['id'].toString();
      return ref.doc(followId).update({
        'status' : status,
        'updateTime': CURRENT_SERVER_TIME(),
      }).then((result2) {
        if (status < 1) {
          setUserFollowCount(user, targetId, -1);
          if (JSON_NOT_EMPTY(user['followData'])) {
            user['followData'].remove(followId);
            LOG('-----> followData removed : $followId');
          }
        }
        return followId;
      }).onError((e, stackTrace) {
        LOG('--> setFollowStatus error : $e');
        return '';
      });
    }
    return '';
  }
  
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    LIKE & BOOK MARK Functions
  //
  
  final ShareCollection = 'data_share';
  final LikeCollection = 'data_like';

  Future<bool> getLikeFromTargetId(JSON user, String targetType, String targetId) async {
    final userId = STR(user['id']);
    // LOG('--> getLikeFromTargetId [$targetType] : $targetId / $userId / ${AppData.USER_PLACE}');
    switch(targetType) {
      case 'placeGroup':
        return LIST_NOT_EMPTY(user['like_eventGroup']) && user['like_eventGroup'].contains(targetId);
      case 'event':
        return LIST_NOT_EMPTY(user['like_event']) && user['like_event'].contains(targetId);
      case 'story':
        return LIST_NOT_EMPTY(user['like_story']) && user['like_story'].contains(targetId);
      case 'user':
        return LIST_NOT_EMPTY(user['like_user']) && user['like_user'].contains(targetId);
      // default:
      //   if (userId.isNotEmpty) {
      //     var dataRef = firestore!.collection(LikeCollection);
      //     var snapshot = await dataRef.where('status', isEqualTo: 1)
      //         .where('targetType', isEqualTo: targetType)
      //         .where('targetId', isEqualTo: targetId)
      //         .where('userId', isEqualTo: userId)
      //         .get();
      //     if (snapshot.docs.isNotEmpty) {
      //       switch(targetType) {
      //         case 'placeGroup':
      //           user['like_eventGroup'] ??= [];
      //           if (!user['like_eventGroup'].contains(targetId)) user['like_eventGroup'].add(targetId);
      //           break;
      //         case 'event':
      //           user['like_event'] ??= [];
      //           if (!user['like_event'].contains(targetId)) user['like_event'].add(targetId);
      //           break;
      //         case 'story':
      //           user['like_story'] ??= [];
      //           if (!user['like_story'].contains(targetId)) user['like_story'].add(targetId);
      //           break;
      //       }
      //       return true;
      //     }
      //   }
    }
    return false;
  }
  
  Future<JSON?> addLikeCount(JSON user, String type, String targetId, int status,
      {String targetTitle = '', String targetPic = ''}) async {
    var ref = firestore!.collection(LikeCollection);
    var likeId = '';
    LOG('--> addLikeCount : $type / $targetId / $targetPic / $status');
    try {
      // get original info..
      var snapshot = await ref
          .where('targetType', isEqualTo: type)
          .where('targetId', isEqualTo: targetId)
          .where('userId', isEqualTo: STR(user['id']))
          .limit(1)
          .get();
  
      if (snapshot.docs.isNotEmpty) {
        likeId = snapshot.docs.first.data()['id'];
      }
    } catch (e) {
      LOG('--> addLikeCount Error : $e');
    }
  
    JSON addData = {};
    addData["id"]         = likeId;
    addData["status"]     = status;
    addData["userId"]     = STR(user['id']);
    addData["userName"]   = STR(user['nickName']);
    addData["userPic"]    = STR(user['pic']);
    addData["targetType"] = type;
    addData["targetId"]   = targetId;
    addData["targetTitle"] = targetTitle;
    addData["targetPic"]  = targetPic;
    addData["updateTime"] = CURRENT_SERVER_TIME();
  
    if (likeId.isEmpty) {
      addData["id"] = ref.doc().id; // create new id..
      addData["createTime"] = CURRENT_SERVER_TIME();
      LOG('--> addLikeCount : ${addData['id']}');
    }
    LOG('--> addLikeCount : $type / $targetId => $status');
    await ref.doc(addData['id']).set(addData);
    return await setCountData('likes', type, targetId, status == 1);
  }
  
  Future<JSON?> setCountData(String type, String targetType, String targetId, bool status) async {
    LOG('--> setCountData : $type, $targetType, $targetId, $status');
    var targetDB = '';
    var countNow = 0;
    switch (targetType) {
      case 'eventGroup':
        targetDB = EventGroupCollection;
        break;
      case 'event':
        targetDB = EventCollection;
        break;
      case 'story':
        targetDB = StoryCollection;
        break;
      case 'user':
        targetDB = UserCollection;
        break;
      default:
        return null;
    }
    // var isEdited = false;
    // AppData.userInfo[infoField] ??= [];
    // if (status) {
    //   if (!AppData.userInfo[infoField].contains(targetId)) {
    //     AppData.userInfo[infoField].add(targetId);
    //     isEdited = true;
    //   }
    // } else {
    //   if (AppData.userInfo[infoField].contains(targetId)) {
    //     AppData.userInfo[infoField].remove(targetId);
    //     isEdited = true;
    //   }
    // }
    // if (isEdited) {
    //   var userResult = await setUserInfoItem(AppData.userInfo, infoField);
    //   LOG('--> setUserInfoItem $infoField result : $userResult');
    // }
    // set target like count..
    var targetRef = firestore!.collection(targetDB);
    var snapshot = await targetRef.doc(targetId).get();
    if (snapshot.data() != null) {
      var data = FROM_SERVER_DATA(snapshot.data());
      countNow = INT(data[type]) + (status ? 1 : -1);
      if (countNow < 0) countNow = 0;
      if (countNow > 99999999) countNow = 99999999;
      await targetRef.doc(targetId).update({type: countNow});
      data[type] = countNow;
      return data;
    }
  }
  
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    SEARCH Functions
  //
  
  final SearchCollection = 'data_search';
  
  Future<JSON> getSearchHistory(String userId) async {
    JSON result = {};
    var snapshot = await firestore!.collection(SearchCollection)
        .where('userId', isEqualTo:userId)
        .get();
    for (var item in snapshot.docs) {
      var addItem = FROM_SERVER_DATA(item.data());
      result[addItem['desc']] = FROM_SERVER_DATA(addItem);
    }
    LOG('------> getSearchHistory result : $result');
    return result;
  }
  
  // // for free loading.. app start..
  // Future<JSON> getSearchVoteResult(String userId) async {
  //   JSON result = {};
  //   if (AppData.USER_INTEREST.isNotEmpty) {
  //     for (var searchText in AppData.USER_INTEREST) {
  //       searchText = searchText.toLowerCase();
  //       var historyField = [[1, 'search'], [1, 'tagData']]; // 0: text, 1: array
  //       AppData.searchVoteResultData.addAll(await getSearchItem(HistoryCollection, searchText, historyField));
  //
  //       // goods search ---------------------------------------------
  //       var goodsField = [[1, 'search'], [1, 'tagData']]; // 0: text, 1: array
  //       AppData.searchVoteResultData.addAll(await getSearchItem(GoodsCollection, searchText, goodsField));
  //
  //       // user search ---------------------------------------------
  //       var userField = [[1, 'interest']]; // 0: text, 1: array
  //       AppData.searchVoteResultData.addAll(await getSearchItem(UserCollection, searchText, userField));
  //     }
  //     addSearchLocalVoteResultAll(AppData.searchVoteResultData);
  //   }
  //   // show min count is 10..
  //   if (AppData.searchVoteResultData.length < 10) {
  //     // TODO: 갯수를 채우기 위해 임의의 데이터를 넣어준다..
  //   }
  //   print('------> getSearchVoteResult : ${AppData.searchVoteResultData.length}');
  //   return AppData.searchVoteResultData;
  // }
  
  // for search text..
  Future<JSON> getSearchResult(JSON user, String searchText) async {
    LOG('----> getSearchResult : $searchText');
    JSON result = {};
    var storyField = [[1,'search'],[1,'tagData']]; // 0: text, 1: array
    result.addAll(await getSearchItem(StoryCollection, searchText, storyField));

    // user search ---------------------------------------------
    var userField = [[0,'name'],[0,'nickName']]; // 0: text, 1: array
    result.addAll(await getSearchItem(UserCollection, searchText, userField));

    // print('--> AppData.searchResultData : ${AppData.searchResultData}');
    if (result.isNotEmpty) {
      await addSearchHistoryItem(user, searchText);
    }
    return result;
  }
  
  addSearchHistoryItem(JSON user, String searchText) async {
    var ref = firestore!.collection(SearchCollection);
    try {
      var key = ref.doc().id;
      var addItem = {
        'id': key,
        'status': 1,
        'desc': searchText,
        'userId': STR(user['id']),
        'createTime': CURRENT_SERVER_TIME(),
      };
      await ref.doc(key).set(addItem);
      // AppData.searchHistoryData[key] = FROM_SERVER_DATA(addItem);
      // AppData.searchHistoryList.insert(0, searchText);
      final result = FROM_SERVER_DATA(addItem);
      return result;
    } catch (e) {
      LOG('--> addSearchHistoryItem error : $e');
    }
    return null;
  }
  
  Future getSearchItem(String collection, String searchText, List<dynamic> options) async {
    var result = {};
    try {
      var ref = firestore!.collection(collection);
      SnapShot snapshot;
      for (var field in options) {
        // print('--> getSearchItem : $field => ${field[0]} / ${field[1]}');
        switch (field[0]) {
          case 1:
            snapshot = await ref.where('status', isEqualTo: 1)
                .where(field[1].toString(), arrayContains: searchText)
                .orderBy('updateTime', descending: true)
                .limit(SEARCH_ITEM_MAX)
                .get();
            break;
          default:
            snapshot = await ref.where('status', isEqualTo: 1)
                // .where(field[1].toString(), isGreaterThanOrEqualTo: searchText)
                // .where(field[1].toString(), isLessThan: searchText + 'z')
                .where(field[1].toString(), isEqualTo: searchText)
                .orderBy('updateTime', descending: true)
                .limit(SEARCH_ITEM_MAX)
                .get();
        }
        for (var doc in snapshot.docs) {
          var data = FROM_SERVER_DATA(doc.data());
          // except my data..
          // if ((collection == "data_history" && data['ownerId'] != AppData.USER_ID) ||
          //     (collection == "data_goods" && data['userId'] != AppData.USER_ID) ||
          //     (collection == "data_user" && data['id'] != AppData.USER_ID)) {
            var addItem = {};
            addItem['collection'] = collection;
            addItem['type' ] = field[0];
            addItem['field'] = field[1];
            addItem['data' ] = data;
            result[data['id']] = addItem;
            // AppData.searchResultData[data['id']] = addItem;
            // print('--> add search [${item['id']}/${field[1]}] : $item');
          // }
        }
      }
      LOG('--> getSearchItem result : $result');
    } catch (e) {
      LOG('--> getSearchItem error : $e');
    }
    return result;
  }
  
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    PROMOTION Functions
  //
  
  final PromotionCollection   = 'data_promotion';

  Future<JSON> getPromotionFromTargetId(String type, String targetId, [String userId = '', bool isAdmin = false]) async {
    LOG('------> getPromotionList : $type / $targetId / $userId');
    JSON result = {};
    try {
      if (targetId.isNotEmpty) {
        var snapshot = await firestore!.collection(PromotionCollection)
            .where('status', isEqualTo:1)
            .where('type', isEqualTo:type)
            .where('targetId', isEqualTo:targetId)
            .get();
        for (var item in snapshot.docs) {
          result[item.data()['id']] = FROM_SERVER_DATA(item.data());
        }
      } else if (userId.isNotEmpty && !isAdmin) {
        var snapshot = await firestore!.collection(PromotionCollection)
            .where('status', isEqualTo:1)
            .where('type', isEqualTo:type)
            .where('userId', isEqualTo:userId)
            .get();
        for (var item in snapshot.docs) {
          result[item.data()['id']] = FROM_SERVER_DATA(item.data());
        }
      } else if (isAdmin) {
        var snapshot = await firestore!.collection(PromotionCollection)
            .where('status', isEqualTo:1)
            .where('type', isEqualTo:type)
            .get();
        for (var item in snapshot.docs) {
          result[item.data()['id']] = FROM_SERVER_DATA(item.data());
        }
      }
      LOG('--> getPromotionList result : $result');
    } catch (e) {
      LOG('--> getPromotionList error : $e');
    }
    return result;
  }

  Future<JSON> getPromotionList() async {
    // LOG('------> getCouponData : ${AppData.USER_ID}');
    JSON result = {};
    // get cart data..
    var snapshot = await firestore!.collection(PromotionCollection)
        .where('status', isEqualTo:1)
        .get();
    for (var item in snapshot.docs) {
      result[item.data()['id']] = FROM_SERVER_DATA(item.data());
    }
    return result;
  }

  Future<JSON> getPromotionFromUserId(String userId) async {
    // LOG('------> getCouponData : ${AppData.USER_ID}');
    JSON result = {};
    // get cart data..
    var snapshot = await firestore!.collection(PromotionCollection)
        .where('status', isEqualTo:1)
        .where('userId', isEqualTo:userId)
        .get();
    for (var item in snapshot.docs) {
      result[item.data()['id']] = FROM_SERVER_DATA(item.data());
    }
    return result;
  }
  
  Future<JSON?> addPromotionItem(JSON user, JSON addItem) async {
    LOG('------> addPromotionItem : $addItem');
    var ref = firestore!.collection(PromotionCollection);
    try {
      var key  = ref.doc().id;
      addItem['id'] = key;
      addItem['status'] = 1;
      addItem['userId'] = STR(user['id']);
      addItem['createTime'] = CURRENT_SERVER_TIME();
      await ref.doc(key).set(addItem);
      return FROM_SERVER_DATA(addItem);
    } catch (e) {
      LOG('--> addPromotionItem error : $e');
    }
    return null;
  }
  
  Future<JSON?> sendCancelPromotion(String promotionId, String userId) async {
    LOG('------> sendCancelPromotion : $promotionId / $userId');
    JSON result = {};
    var ref = firestore!.collection(PromotionCollection);
    try {
      var snapshot = await ref.doc(promotionId).get();
      if (snapshot.data() != null) {
        var orgItem = snapshot.data() as JSON;
        if (STR(orgItem['depositStatus']) == 'waiting') {
          orgItem['depositStatus'] = 'canceled';
          orgItem['cancelTime'   ] = CURRENT_SERVER_TIME();
        } else if (STR(orgItem['depositStatus']) == 'activate') {
          orgItem['cancelStatus'     ] = 'request';
          orgItem['cancelRequestTime'] = CURRENT_SERVER_TIME();
        } else {
          return result;
        }
        orgItem['cancelUserId'] = userId;
        await ref.doc(promotionId).set(orgItem);
        result = FROM_SERVER_DATA(orgItem);
      }
      LOG('--> sendCancelPromotion result : $result');
      return result;
    } catch (e) {
      LOG('--> addPromotionItem error : $e');
    }
    return null;
  }
  
  Future<JSON?> sendPaymentPromotion(JSON user, String promotionId, {String promotionType = 'promotion_listTop'}) async {
    LOG('------> sendPaymentPromotion : $promotionId');
    JSON result = {};
    var collection = firestore!.collection(PromotionCollection);
    var snapshot = await collection.doc(promotionId).get();
    if (snapshot.data() != null) {
      var orgItem = snapshot.data() as JSON;
      LOG('--> depositStatus : ${STR(orgItem['depositStatus'])} / ${STR(orgItem['cancelStatus'])}');
      if (STR(orgItem['depositStatus']) == 'waiting' && STR(orgItem['cancelStatus']).isEmpty) {
        orgItem['depositStatus'] = 'activate';
        orgItem['confirmTime'  ] = CURRENT_SERVER_TIME();
        var tResult = await setTargetPromotion(user, orgItem, promotionType);
        if (tResult != null) {
          await collection.doc(promotionId).set(Map<String, dynamic>.from(orgItem));
          result = FROM_SERVER_DATA(orgItem);
          LOG('--> sendPaymentPromotion result : $result');
          return result;
        }
      } else {
        LOG('--> sendPaymentPromotion error : $promotionId');
      }
    }
    return null;
  }
  
  Future<JSON?> sendStopPromotion(String promotionId, {String promotionType = 'promotion_listTop'}) async {
    LOG('------> sendStopPromotion : $promotionId');
    JSON result = {};
    var collection = firestore!.collection(PromotionCollection);
    var snapshot = await collection.doc(promotionId).get();
    if (snapshot.data() != null) {
      var orgItem = snapshot.data() as JSON;
      LOG('--> depositStatus : ${STR(orgItem['depositStatus'])} / ${STR(orgItem['cancelStatus'])}');
      if (STR(orgItem['depositStatus']) == 'activate') {
        orgItem['depositStatus' ] = 'canceled';
        orgItem['cancelStatus'  ] = 'canceled';
        orgItem['cancelTime'    ] = CURRENT_SERVER_TIME();
        var tResult = await resetTargetPromotion(orgItem, promotionType);
        if (tResult != null) {
          await collection.doc(promotionId).set(Map<String, dynamic>.from(orgItem));
          result = FROM_SERVER_DATA(orgItem);
          LOG('------> sendStopPromotion result : $result');
          return result;
        }
      } else {
        LOG('--> sendStopPromotion error : $promotionId');
      }
    }
    return null;
  }

  Future<JSON?> setTargetPromotion(JSON user, JSON orgItem, String promotionType) async
  {
    var targetId    = STR(orgItem['targetId']);
    var targetType  = STR(orgItem['type']);
    if (targetId.isEmpty || targetType.isEmpty) {
      LOG('--> target error : $targetId / $targetType');
      return {'error': 'target error'};
    }
    var promotionInfo = {
      'status'    : '1',
      'id'        : STR(orgItem['id']),
      'orgId'     : STR(orgItem['promotionId']),
      'startDate' : STR(orgItem['startDate']),
      'endDate'   : STR(orgItem['endDate']),
      'createId'  : STR(user['id']),
      'createTime': CURRENT_SERVER_TIME(),
    };
    var updateInfo = {promotionType: promotionInfo};
    if (targetType == 'place') {
      var result = await setPlaceItemFromId(targetId, updateInfo);
      return result;
    } else if (targetType == 'event') {
      var result = await setEventItemFromId(targetId, updateInfo);
      return result;
    }
    return null;
  }

  Future<JSON?> resetTargetPromotion(JSON orgItem, String promotionType) async
  {
    var targetId    = STR(orgItem['targetId']);
    var targetType  = STR(orgItem['type']);
    if (targetId.isEmpty || targetType.isEmpty) {
      LOG('--> target error : $targetId / $targetType');
      return null;
    }
    var promotionInfo = {
      'status' : '0',
    };
    var updateInfo = {promotionType: promotionInfo};
    if (targetType == 'place') {
      var result = await setPlaceItemFromId(targetId, updateInfo);
      return result;
    } else if (targetType == 'event') {
      var result = await setEventItemFromId(targetId, updateInfo);
      return result;
    }
    return null;
  }

  Future setPromotionStatus(String promotionId, int status) async {
    LOG('------> setPromotionStatus : $promotionId / $status');
    JSON result = {};
    var collection = firestore!.collection(PromotionCollection);
    await collection.doc(promotionId).update({
      'status' : status,
      'deleteTime' : CURRENT_SERVER_TIME()
    });
  }
  

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    BLOCK Functions
  //
  
  final BlockCollection = 'data_block';
  
  Future<JSON> getBlockList(JSON user, String type) async {
    LOG('------> getBlockList : $type');
    JSON result = {};
    try {
      var snapshot = await firestore!.collection(BlockCollection)
          .where('status', isEqualTo: 1)
          .where('type', isEqualTo: type)
          .where('userId', isEqualTo: STR(user['id']))
          .get();
      for (var item in snapshot.docs) {
        var addItem = FROM_SERVER_DATA(item.data());
        result[addItem['targetId']] = addItem;
      }
      // AppData.isBlockDataReady = true;
      LOG('--> getBlockList result :$result');
    } catch (e) {
      LOG('--> getBlockList error : $e');
    }
    return result;
  }
  
  Future<bool> addBlockItem(JSON user, String type, String targetId) async {
    LOG('--> addBlockItem : $targetId');
    try {
      var dataRef = firestore!.collection(BlockCollection);
      var key = dataRef.doc().id;
      var addItem = {
        'id': key,
        'status': 1,
        'type': type,
        'userId': STR(user['id']),
        'targetId': targetId,
        'createTime': CURRENT_SERVER_TIME()
      };
      await dataRef.doc(key).set(addItem);
      // AppData.blockList[targetId] = FROM_SERVER_DATA(addItem);
      return true;
    } catch (e) {
      LOG('--> addBlockItem error : $e');
    }
    return false;
  }
  
  Future<bool> setBlockItemStatus(JSON user, String targetId, int status) async {
    LOG('------> setBlockItemStatus : $targetId / $status');
    var ref = firestore!.collection(BlockCollection)
        .where('targetId', isEqualTo: targetId)
        .where('userId' , isEqualTo: STR(user['id']));
    var snapshot = await ref.limit(1).get();
  
    if (snapshot.docs.isEmpty) {
      LOG('--> setBlockItemStatus : No matching documents.');
    } else {
      try {
        var item = snapshot.docs.first;
        var ref2 = firestore!.collection(BlockCollection);
        await ref2.doc(item['id']).update({
          'status': status,
          'updateTime': CURRENT_SERVER_TIME()
        });
        // AppData.blockList.remove(targetId);
        return true;
      } catch (e) {
        LOG('--> setBlockItemStatus error : $e');
      }
    }
    return false;
  }
  
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //    REPORT Functions
  //
  
  final ReportCollection = 'data_report';
  
  Future<JSON> getReportList(JSON user, JSON reportData) async {
    JSON result = {};
    try {
      var snapshot = await firestore!.collection(ReportCollection)
          .where('status', isEqualTo: 1)
          .where('userId', isEqualTo: STR(user['id']))
          .get();

      for (var item in snapshot.docs) {
        var addItem = FROM_SERVER_DATA(item.data());
        var type = STR(addItem['type']);
        if (!reportData.containsKey(type)) {
          reportData[type] = {};
        }
        var targetID = STR(addItem['targetId']);
        if (targetID.isNotEmpty) {
          reportData[type][targetID] = addItem;
        }
      }
      for (var type in reportData.keys) {
        reportData[type] = JSON_CREATE_TIME_SORT_DESC(reportData[type]);
      }
      LOG('------> getReportList result : ${reportData.length}');
    } catch (e) {
      LOG('--> getReportList error : $e');
    }
    return reportData;
  }
  
  Future<JSON> addReportItem(JSON user, JSON reportData, String type, String targetId, String desc) async {
    LOG('--> addReportItem : $type / $targetId / $desc');
    if (type.isEmpty || desc.isEmpty || targetId.isEmpty) return reportData;
    try {
      JSON addItem = {
        'userId'    : STR(user['id']),
        'targetId'  : targetId,
        'type'      : type, // user, history, goods, place, owner
        'desc'      : desc,
        'replayType': 'ready', // 처리 type..
        'replayName': '', // 처리자..
        'replayDesc': '', // 처리내역..
        'replayTime': '', // 처리시간..
      };
      return await addReportItemEx(addItem, reportData);
    } catch (e) {
      LOG('--> addDeclarationItem error : $e');
    }
    return reportData;
  }
  
  Future<JSON> addReportItemEx(JSON itemInfo, JSON reportData) async {
    if (itemInfo.isEmpty) return reportData;
    try {
      var dataRef = firestore!.collection(ReportCollection);
      var key = dataRef.doc().id;
      JSON addItem = {};
      addItem.addAll(itemInfo);
      addItem['id'         ] = key;
      addItem['status'     ] = 1;
      addItem['createTime' ] = CURRENT_SERVER_TIME();
      LOG('--> addReportItem : $addItem');
      await dataRef.doc(key).set(addItem);
      var type = STR(itemInfo['type']);
      if (!reportData.containsKey(type)) {
        reportData[type] = {};
      }
      var targetId = STR(itemInfo['targetId']);
      if (targetId.isNotEmpty) {
        reportData[type][targetId] = FROM_SERVER_DATA(addItem);
      }
    } catch (e) {
      LOG('--> addReportItemEx error : $e');
    }
    return reportData;
  }
  
  Future<JSON> setReportDesc(JSON reportData, String targetId, String desc) async {
    LOG('--> setReportDesc : $targetId / $desc');
    if (desc.isEmpty) return reportData;
    try {
      var dataRef = firestore!.collection(ReportCollection);
      await dataRef.doc(targetId).update({
        'desc' : desc
      });
      for (var type in reportData.keys) {
        for (var item in reportData[type].entries) {
          if (item.value['id'] == targetId) {
            reportData[type][item.key]['desc'] = desc;
          }
        }
      }
      // AppData.reportList[key]['desc'] = desc;
    } catch (e) {
      LOG('--> setReportDesc error : $e');
    }
    return reportData;
  }
  
  Future<JSON> setReportItemStatus(JSON reportData, String targetId, int status) async {
    LOG('------> setReportItemStatus : $targetId / $status');
    try {
      var dataRef = firestore!.collection(ReportCollection);
      await dataRef.doc(targetId).update({
        'status': status,
        'updateTime': CURRENT_SERVER_TIME()
      });
      if (status == 0) {
        for (var type in reportData.keys) {
          for (var item in reportData[type].entries) {
            if (item.value['id'] == targetId) {
              reportData[type].remove(item.key);
            }
          }
        }
      }
    } catch (e) {
      LOG('--> setDeclarationItemStatus error : $e');
    }
    return reportData;
  }
  
  //----------------------------------------------------------------------------------------
  //
  //    message info..
  //
  
  final MessageCollection = 'data_message';


  Future<JSON> addMessageItem(JSON addItem, JSON targetUserInfo) async {
    LOG('------> addMessageItem : $addItem / $targetUserInfo');
    var dataRef = firestore!.collection(MessageCollection);
    var key = STR(addItem['id']).toString();
    if (key.isEmpty) {
      key = dataRef.doc().id;
      addItem['id'] = key;
      addItem['createTime'] = CURRENT_SERVER_TIME();
    }
    addItem['updateTime'] = CURRENT_SERVER_TIME();
    LOG('--> addMessageItem key : ${addItem['id']}');
    await dataRef.doc(key).set(Map<String, dynamic>.from(addItem));
    var result = FROM_SERVER_DATA(addItem);

    // send push..
    // var pushToken = STR(targetUserInfo['pushToken']);
    // LOG('------> send push : ${targetUserInfo['optionPush']} / $pushToken');
    // if (pushToken.isNotEmpty && (targetUserInfo['optionPush'] == null || BOL(targetUserInfo['optionPush']['message_on']))) {
    //   sendFcmData(
    //       pushToken,
    //       AppData.USER_NICKNAME,
    //       STR(addItem['desc']),
    //       {
    //         'type': 'message',
    //         'data': result,
    //       }
    //   );
    // }
    return result;
  }
  
  Future<JSON> getMessageData(JSON user, JSON messageData) async {
    var ref = firestore!.collection(MessageCollection);
    var snapshot0 = await ref
        .where('status', isEqualTo: 1)
        .where('senderId', isEqualTo: STR(user['id']))
        .get();
    for (var doc in snapshot0.docs) {
      var item = FROM_SERVER_DATA(doc.data());
      item['type'] = 1;
      messageData[item['id']] = item;
    }
    var snapshot1 = await ref
        .where('status', isEqualTo: 1)
        .where('targetId', isEqualTo: STR(user['id']))
        .get();
    for (var doc in snapshot1.docs) {
      var item = FROM_SERVER_DATA(doc.data());
      item['type'] = 0;
      messageData[item['id']] = item;
    }
    // AppData.isMessageDataReady = true;
    messageData = JSON_CREATE_TIME_SORT_DESC(messageData);
    LOG('--> getMessageData Result : $messageData');
    return messageData;
  }
  
  Future<bool> setMessageStatus(String targetId, int status) async {
    try {
      var dataRef2 = firestore!.collection(MessageCollection);
      await dataRef2.doc(targetId).update({
        'status': status,
        'updateTime': CURRENT_SERVER_TIME()
      });
      return true;
    } catch (e) {
      LOG('--> setMessageStatus error : $e');
    }
    return false;
  }
  
  Future<bool> setMessageInfo(String targetId, JSON updateInfo) async {
    LOG('------> setMessageInfo : $targetId - $updateInfo');
    try {
      var dataRef2 = firestore!.collection(MessageCollection);
      await dataRef2.doc(targetId).update(Map<String, dynamic>.from(updateInfo));
      return true;
    } catch (e) {
      LOG('--> setMessageInfo error : $e');
    }
    return false;
  }
  
  StreamSubscription<QuerySnapshot>? messageStream;
  
  startMessageStream(JSON user, targetId, Function(JSON) onChanged) async {
    JSON result = {};
    var ref = firestore!.collection(MessageCollection)
        .where('status'  , isEqualTo: 1)
        .where('senderId', isEqualTo: targetId)
        .where('targetId', isEqualTo: STR(user['id']))
        .orderBy('updateTime', descending: true);

    messageStream = ref.snapshots().listen((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            var item = FROM_SERVER_DATA(doc.data() as JSON);
            result[item['id']] = item;
          }
          onChanged(result); // TODO: need messageData add.. (messageData[item['id']] = item;)
        }
    );
  }
  
  stopMessageStream() {
    LOG('------> stopMessageStream : ${messageStream != null}');
    if (messageStream != null) {
      messageStream!.cancel();
      messageStream = null;
    }
  }
  

  //----------------------------------------------------------------------------------------
  //
  //    COMMENT function..
  //
  
  final CommentCollection = 'data_comments';
  
  Future<JSON> getCommentFromUserId(JSON user) async {
    JSON result = {};
    try {
      var snapshot = await firestore!.collection(CommentCollection)
          .where('status', isEqualTo: 1)
          .where('userId', isEqualTo: STR(user['id']))
          .get();
      for (var doc in snapshot.docs) {
        var item = FROM_SERVER_DATA(doc.data());
        result[item['id']] = item;
      }
      // AppData.isCommentDataReady = true;
      // AppData.commentData = JSON_CREATE_TIME_SORT_DESC(AppData.commentData);
      // LOG('--> getCommentDataAll Result : ${AppData.commentData['czvzXtu3SEHVt8daWx9f']}');
    } catch (e) {
      LOG('--> getCommentFromUserId error : $e');
    }
    return result;
  }
  
  Future<JSON> getCommentFromTargetId(String targetType, String targetId) async {
    JSON result = {};
    var snapshot = await firestore!.collection(CommentCollection)
        .where('targetType', isEqualTo: targetType)
        .where('targetId', isEqualTo: targetId)
        .get();
    for (var item in snapshot.docs) {
      result[item['id']] = FROM_SERVER_DATA(item);
    }
    LOG('--> getCommentFromTargetId Result : $result');
    return JSON_CREATE_TIME_SORT_DESC(result);
  }
  
  Future<JSON> addCommentItem(JSON addItem, JSON targetUserInfo) async {
    var ref = firestore!.collection(CommentCollection);
    var key = ref.doc().id;
    if (addItem['id'] == null) {
      addItem['id'] = key;
      addItem['createTime'] = CURRENT_SERVER_TIME();
    }
    addItem['updateTime'] = CURRENT_SERVER_TIME();
  
    return ref.doc(addItem['id']).set(addItem).then((result) async {
      if (addItem['targetType'] == 'story') {
        var targetId = addItem['targetId'];
        var storyInfo = await getStoryFromId(targetId);
        if (storyInfo.isNotEmpty) {
          var count = INT(storyInfo['comments']) + 1;
          var newData = {'comments' : count};
          addItem['comments'] = count;
          await setStoryItemData(targetId, newData);
        }
      }
      JSON result = FROM_SERVER_DATA(addItem);
      addCommentCount(addItem['targetId'], addItem['targetType'], 1);
      // // send push..
      // var pushToken = STR(targetUserInfo['pushToken']);
      // LOG('------> send push : ${targetUserInfo['optionPush']} / $pushToken');
      // if (pushToken.isNotEmpty && (targetUserInfo['optionPush'] == null || BOL(targetUserInfo['optionPush']['goods_on']))) {
      //   sendFcmData(
      //     pushToken,
      //     AppData.USER_NICKNAME,
      //     STR(addItem['desc']),
      //     {
      //       'type': STR(addItem['targetType']),
      //       'data': result,
      //     }
      //   );
      // }
      LOG('--> addCommentItem result : ${addItem['id']}');
      return result;
    }).onError((e, stackTrace) {
      return {};
    });
  }
  
  Future<bool> setCommentStatus(String targetId, int status) async {
    try {
      var ref = firestore!.collection(CommentCollection);
      ref.doc(targetId).update({
        'status': status,
        'updateTime': CURRENT_SERVER_TIME()
      });
      return true;
    } catch (e) {
      LOG('--> setCommentStatus error : $e');
    }
    return false;
  }

  Future<int> addCommentCount(String targetId, String type, int count) async {
    LOG('------> addCommentCount : $targetId / $count');
    var collection = type == "event" ? EventCollection : StoryCollection;
    var targetRef = firestore!.collection(collection);
    var snapshot = await targetRef.doc(targetId).get();
    var countNow = 0;
    if (snapshot.data() == null) {
      LOG('--> addCommentCount : No matching documents.');
      return countNow;
    } else {
      var data = FROM_SERVER_DATA(snapshot.data());
      countNow = INT(data['commentCount']) + count;
      await targetRef.doc(targetId).update({"commentCount": countNow});
    }
    // if (type == "history" && AppData.mainHomeData.containsKey(targetId)) {
    //   AppData.mainHomeData[targetId]['comments'] = countNow;
    //   LOG('--> AppData.mainHomeData : ${AppData.mainHomeData}');
    //   addAndWriteMain(AppData.mainHomeData[targetId]);
    // }
    return countNow;
  }
  
  //----------------------------------------------------------------------------------------
  //
  //    QNA function..
  //
  
  final QnACollection = 'data_qna';
  
  Future<JSON> getQnaFromTargetId(String targetType, String targetId) async {
    JSON result = {};
    try {
      var ref = firestore!.collection(QnACollection);
      var snapshot = await ref.where('status', isEqualTo: 1)
          .where('targetType', isEqualTo: targetType)
          .where('targetId', isEqualTo: targetId)
          .get();
  
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs)  {
          result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
        }
      }
      // console.log('--> getCommentsFromGoodsId result : ' + JSON.stringify(resultData));
      // firebase!.firestoreCacheData['${targetType}Comment'][targetId] = resultData;
      LOG('--> getQnaFromTargetId result: $result');
    } catch (e) {
      LOG('--> getQnaFromTargetId error: $e');
    }
    return result;
  }

  Future<JSON?> addQnAItem(JSON addItem, JSON targetUserInfo) async {
    LOG('------> addQnAItem : $addItem');
    try {
    var ref = firestore!.collection(QnACollection);
    var key = STR(addItem['id']).toString();
    if (key.isEmpty) {
      key = ref.doc().id;
      addItem['createTime'] = CURRENT_SERVER_TIME();
    }
    addItem['id'] = key;
    addItem['updateTime'] = CURRENT_SERVER_TIME();
    await ref.doc(key).set(addItem);
      JSON result = FROM_SERVER_DATA(addItem);
      // var pushToken = STR(targetUserInfo['pushToken']);
      // LOG('------> send push : ${targetUserInfo['optionPush']} / $pushToken');
      // if (pushToken.isNotEmpty && (targetUserInfo['optionPush'] == null || BOL(targetUserInfo['optionPush']['goods_on']))) {
      //   sendFcmData(
      //       pushToken,
      //       AppData.USER_NICKNAME,
      //       STR(addItem['desc']),
      //       {
      //         'type': 'qna',
      //         'data': result,
      //       }
      //   );
      // }
      return result;
    } catch (e) {
      LOG('--> getQnaFromTargetId error: $e');
    }
    return null;
  }
  
  Future<bool> setQnAStatus(String targetId, int status) async {
    try {
      var ref = firestore!.collection(QnACollection);
      ref.doc(targetId).update({
        'status': status,
        'updateTime': CURRENT_SERVER_TIME()
      });
      return true;
    } catch (e) {
      LOG('--> setCommentStatus error : $e');
    }
    return false;
  }

  //----------------------------------------------------------------------------------------
  //
  //    SERVICE function..
  //
  
  final ServiceQnACollection  = 'data_serviceQnA';
  
  Stream getServiceQnAData() {
    var ref = firestore!.collection(ServiceQnACollection);
    var query = ref.where('status', isEqualTo: 1);
    return query.orderBy('createTime', descending: true).limit(FREE_LOADING_QNA_MAX).snapshots();
  }
  
  Stream getServiceQnADataNext(JSON lastTime) {
    var ref = firestore!.collection(ServiceQnACollection);
    var query = ref.where('status', isEqualTo: 1);
    if (JSON_NOT_EMPTY(lastTime)) {
      var startTime = Timestamp(lastTime['_seconds'], lastTime['_nanoseconds']);
      LOG('--> getServiceQnADataNext : $startTime');
      query = query.where('createTime', isLessThan: startTime);
    }
    return query.orderBy('createTime', descending: true).limit(FREE_LOADING_QNA_MAX).snapshots();
  }
  
  Future<JSON> addServiceQnAItem(JSON addItem) async {
    var ref = firestore!.collection(ServiceQnACollection);
    var key = STR(addItem['id']).toString();
    if (key.isEmpty) {
      key = ref.doc().id;
      addItem['createTime'] = CURRENT_SERVER_TIME();
    }
    addItem['id'] = key;
    addItem['updateTime'] = CURRENT_SERVER_TIME();
  
    return ref.doc(key).set(addItem).then((result) {
      JSON result = FROM_SERVER_DATA(addItem);
      return result;
    }).onError((e, stackTrace) {
      return {};
    });
  }
  
  Future<bool> setServiceQnAStatus(String targetId, int status) async {
    try {
      var ref = firestore!.collection(ServiceQnACollection);
      ref.doc(targetId).update({
        'status': status,
        'updateTime': CURRENT_SERVER_TIME()
      });
      return true;
    } catch (e) {
      LOG('--> setServiceQnAStatus error : $e');
    }
    return false;
  }
  
  //----------------------------------------------------------------------------------------
  //
  //    RESERVE info..
  //
  
  final ReserveCollection = 'data_reserve';
  
  Future<JSON> getReserveMyFromUserId(JSON user) async {
    String userId = STR(user['id']);
    JSON result = {};
    try {
      var dataRef = firestore!.collection(ReserveCollection);
      var snapshot = await dataRef.where('status', isGreaterThan: 0)
          .where('userId', isEqualTo: userId)
          .get();
  
      if (snapshot.docs.isEmpty) {
        LOG('--> getReserveMyDataFromUserId : No matching documents.');
      } else {
        for (var doc in snapshot.docs) {
          result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
        }
      }
    } catch (e) {
      LOG('--> getReserveMyDataFromUserId error : $e');
    }
    if (result.length > 1) {
      result = JSON_TARGET_DATE_SORT_ASCE(result);
    }
    result = await cleanReserveExpire(result);
    LOG('--> getReserveMyDataFromUserId result : $result');
    return result;
  }
  
  Future<JSON> getReserveFromUserId(String userId) async {
    JSON result = {};
    try {
      var eventData = await getEventListFromManaged(userId);
      var dataRef = firestore!.collection(ReserveCollection);
      for (var event in eventData.entries) {
        var snapshot = await dataRef.where('status', isGreaterThan: 0)
            .where('targetId', isEqualTo: STR(event.value['id']))
            .get();
  
        if (snapshot.docs.isEmpty) {
          LOG('--> getReserveListDataFromUserId [${STR(event.value['id'])}] : No matching documents.');
        } else {
          for (var doc in snapshot.docs) {
            result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
          }
        }
      }
    } catch (e) {
      LOG('--> getReserveListDataFromUserId error : $e');
    }
    if (result.length > 1) {
      result = JSON_TARGET_DATE_SORT_ASCE(result);
    }
    result = await cleanReserveExpire(result);
    LOG('--> getReserveListDataFromUserId result : $result');
    return result;
  }
  
  Future<JSON> getReserveDataFromTime(String eventId, String date) async {
    LOG('--> getReserveDataFromTime : $eventId / $date');
    JSON result = {};
    try {
      var dataRef = firestore!.collection(ReserveCollection);
      var snapshot = await dataRef.where('status', isGreaterThan: 0)
          .where('targetId', isEqualTo: eventId)
          .where('targetDate', isEqualTo: date)
          .get();
  
      if (snapshot.docs.isEmpty) {
        LOG('--> getReserveDataFromTime : No matching documents.');
      } else {
        for (var doc in snapshot.docs) {
          result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
        }
      }
    } catch (e) {
      LOG('--> getReserveDataFromTime error : $e');
    }
    if (result.length > 1) {
      result = JSON_CREATE_TIME_SORT_DESC(result);
    }
    result = await cleanReserveExpire(result);
    LOG('--> getReserveDataFromTime result : $result');
    return result;
  }
  
  Future<JSON> cleanReserveExpire(JSON reserveData) async {
    JSON result = {};
    var today = DateTime.parse(DATE_STR(DateTime.now()));
    for (var item in reserveData.entries) {
      var days = DateTime.parse(STR(item.value['targetDate'])).difference(today).inDays;
      LOG('--> cleanReserveExpire : ${STR(item.value['targetDate'])} / $today -> $days');
      if (days < 0) {
        var rResult = await setReserveItem(item.value, {'status': 0});
        LOG('------> cleanReserveExpire removed : ${rResult ? 'Done' : 'Fail'}');
      } else {
        result[item.key] = item.value;
      }
    }
    return result;
  }
  
  Future<JSON?> addReserveItem(JSON addItem, List<JSON> targetUserList) async {
    var dataRef = firestore!.collection(ReserveCollection);
    try {
      var key = STR(addItem['id']).toString();
      if (key.isEmpty) {
        key = dataRef.doc().id;
        addItem['id'] = key;
        addItem['createTime'] = CURRENT_SERVER_TIME();
      }
      addItem['updateTime'] = CURRENT_SERVER_TIME();
      await dataRef.doc(key).set(Map<String, dynamic>.from(addItem));
      var result = FROM_SERVER_DATA(addItem);
      return result;
    } catch (e) {
      LOG('------> setReserveItem : $e');
    }
    // // send push..
    // for (var item in targetUserList) {
    //   var pushToken = STR(item['pushToken']);
    //   if (pushToken.isNotEmpty && (item['optionPush'] == null || BOL(item['optionPush']['reserve_on']))) {
    //     LOG('------> send push : ${item['optionPush']} / $pushToken');
    //     await sendFcmData(
    //       pushToken,
    //       AppData.USER_NICKNAME,
    //       STR(addItem['desc']),
    //       {
    //         'type': 'reserve',
    //         'data': result,
    //       }
    //     );
    //   }
    // }
    return null;
  }
  
  Future<bool> setReserveItem(JSON reserveItem, JSON updateData, [List<JSON>? targetUserList, String? fcmTitle]) async {
    try {
      var dataRef = firestore!.collection(ReserveCollection);
      var key = STR(reserveItem['id']);
      await dataRef.doc(key).update(Map<String, dynamic>.from(updateData));
      return true;
    } catch (e) {
      LOG('------> setReserveItem error : $e');
    }
    // // send push..
    // if (targetUserList != null && targetUserList.isNotEmpty) {
    //   for (var item in targetUserList) {
    //     var pushToken = STR(item['pushToken']);
    //     if (pushToken.isNotEmpty && (item['optionPush'] == null ||
    //         BOL(item['optionPush']['reserve_on']))) {
    //       LOG('------> send push : ${item['optionPush']} / $pushToken');
    //       await sendFcmData(
    //         pushToken,
    //         'KSpot-${fcmTitle ?? ''}' ,
    //         STR(reserveItem['desc']),
    //         {
    //           'type': 'reserve',
    //           'data': reserveItem,
    //         }
    //       );
    //     }
    //   }
    // }
    return false;
  }

  Future<bool> checkReserveDay(String eventId, String userId, String date) async {
    try {
      var dataRef = firestore!.collection(ReserveCollection);
      var snapshot = await dataRef.where('status', isGreaterThan: 0)
          .where('userId', isEqualTo: userId)
          .where('targetId', isEqualTo: eventId)
          .where('targetDate', isEqualTo: date)
          .limit(1)
          .get();
      LOG('--> checkReserveDay result : ${snapshot.docs.length}');
      if (snapshot.docs.isEmpty) {
        return true;
      }
    } catch (e) {
      LOG('--> checkReserveDay error : $e');
    }
    return false;
  }
  
  //----------------------------------------------------------------------------------------
  //
  //    upload file..
  //
  
  Future? uploadImageData(JSON imageInfo, String path) async {
    if (imageInfo['data'] != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('$path/${imageInfo['id']}');
        // List<int> list = utf8.encode(STR(imageInfo['data']));
        // Uint8List bytes = Uint8List.fromList(list);
        var uploadTask = ref.putData(imageInfo['data']);
        var snapshot = await uploadTask;
        if (snapshot.state == TaskState.success) {
          var imageUrl = await snapshot.ref.getDownloadURL();
          LOG('--> uploadImageData done : $imageUrl');
          return imageUrl;
        } else {
          return null;
        }
      } catch (e) {
        LOG('--> uploadImageData error : $e');
      }
    }
    return null;
  }
  
  Future? uploadVideoData(JSON imageInfo, String path) async {
    if (imageInfo['video'] != null) {
      try {
        var result1 = await uploadVideo(imageInfo['video'], path);
        return result1;
      } catch (e) {
        LOG('--> uploadVideoData error : $e');
      }
    }
    return null;
  }
  
  
  Future? uploadVideo(String sourcePath, String path) async {
    var result = await uploadMP4(XFile(sourcePath), path, Uuid().v1());
    LOG("--> uploadVideo result : $result");
    return result;
  }
  
  Future uploadImageFile(File? photo, String path, String key) async {
    if (photo == null) return;
    try {
      final ref = FirebaseStorage.instance.ref().child('$path/$key');
      var snapshot = await ref.putFile(photo);
      if (snapshot.state == TaskState.success) {
        var imageUrl = await snapshot.ref.getDownloadURL();
        LOG('--> uploadImageFile done : $imageUrl');
        return imageUrl;
      } else {
        return null;
      }
    } catch (e) {
      log('--> uploadImageFile error!! : $e');
      return null;
    }
  }
  
  Future<bool> uploadStringData(String path, String fileName, String desc) async {
    final ref = FirebaseStorage.instance.ref().child('$path/$fileName');
    try {
      Uint8List bytes = Uint8List.fromList(desc.codeUnits);
      await ref.putData(bytes);
    } catch (e) {
      LOG('--> uploadStringData error : $e');
      return false;
    }
    return true;
  }
  
  Future uploadDocFile(File? file, String path, String key) async {
    if (file == null) return;
    try {
      final ref = FirebaseStorage.instance.ref().child('$path/$key');
      var snapshot = await ref.putFile(file);
      if (snapshot.state == TaskState.success) {
        var imageUrl = await snapshot.ref.getDownloadURL();
        LOG('--> uploadFile done : $imageUrl');
        return imageUrl;
      } else {
        return null;
      }
    } catch (e) {
      log('--> uploadFile error!! : $e');
      return null;
    }
  }
  
  Future<String> downloadFile(String path, String fileName) async {
    LOG('--> downloadFile : $path/$fileName');
    try {
      var localFile = await readLocalFile(fileName);
      if (localFile.isEmpty) {
        final ref = FirebaseStorage.instance.ref().child('$path/$fileName');
        var snapshot = await ref.getData();
        if (snapshot!.isNotEmpty) {
          var fileImage = String.fromCharCodes(snapshot);
          writeLocalFile(fileName, fileImage);
          LOG('--> downloadFile from SERVER : $fileName');
          return fileImage;
        } else {
          return '';
        }
      } else {
        LOG('--> downloadFile from LOCAL : $fileName');
        return localFile;
      }
    } catch (e) {
      log('--> downloadFile error!! : $e');
      return '';
    }
  }

  Future<File> _initLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    log('--> _initLocalFile : $path/tmp/$fileName');
    return File('$path/$fileName');
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
}
