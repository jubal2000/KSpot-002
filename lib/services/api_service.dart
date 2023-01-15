import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';
import '../data/utils.dart';
import '../models/start_model.dart';
import 'firebase_service.dart';
import 'local_service.dart';

class ApiService extends GetxService {
  Future<ApiService> init() async {
    initService();
    return this;
  }

  var firebase = Get.find<FirebaseService>();

  void initService() {

  }

  Future<dynamic> getAppStartInfo() async {
    try {
      var collectionRef = firebase.firestore!.collection('info_start');
      var querySnapshot = await collectionRef.doc('info0000').get();
      if (querySnapshot.data() != null) {
        AppData.startData = StartModel.fromJson(FROM_SERVER_DATA(querySnapshot.data()));
        LOG('--> getAppStartInfo result : ${AppData.startData!.toJSON()}');
        return querySnapshot.data();
      } else {
        return {'error' : 'no data'};
      }
    } catch (e) {
      LOG('--> getStartInfo Error : $e');
      return {'error' : e.toString()};
    }
  }

  Future<dynamic> getAppDataAll() async {
    final serverDataVer = AppData.startData!.infoVersion;
    AppData.localDataVer ??= await StorageManager.readData('infoVersion');
    final mapData = await StorageManager.readData('appData');
    if (mapData != null) {
      AppData.localAppData ??= List<String>.from(mapData);
    }
    LOG('--> getAppDataAll : $serverDataVer / ${AppData.localDataVer} - ${AppData.localAppData}');
    if (AppData.localAppData == null || AppData.localDataVer != serverDataVer) {
      await getServerAppDataAll();
      StorageManager.saveData('infoVersion', serverDataVer);
    } else {
      LOG('--> AppData.localAppData : ${AppData.localAppData!.length}');
      // AppData.mapData       = JSON.from(json.decode(AppData.localMapData![0]));
      // AppData.mapLinkData   = JSON.from(json.decode(AppData.localMapData![1]));
      // AppData.mapInsideData = JSON.from(json.decode(AppData.localMapData![2]));
      // AppData.linkData      = JSON.from(json.decode(AppData.localMapData![3]));
      // AppData.mementoData   = JSON.from(json.decode(AppData.localMapData![4]));
    }
    return {'result': 'done'};
  }

  getServerAppDataAll() async {
    List<String> localDataList = [];
    // localDataList.add(json.encode(AppData.mapData));
    // localDataList.add(json.encode(AppData.mapLinkData));
    // localDataList.add(json.encode(AppData.mapInsideData));
    // localDataList.add(json.encode(AppData.linkData));
    // localDataList.add(json.encode(AppData.mementoData));
    StorageManager.saveData('appData', localDataList);
    LOG('--> getServerAppDataAll [${INT(AppData.startData!.infoVersion)}] : $localDataList');
  }

  Future<dynamic> getStartUserInfo(String loginId) async {
    try {
      var collectionRef = firebase.firestore!.collection('data_user');
      var querySnapshot = await collectionRef
          .where('loginId', isEqualTo: loginId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (e) {
      LOG('--> getStartUserInfo Error : $e');
      throw e.toString();
    }
    return null;
  }

  Future<dynamic> getUserInfo(String userId) async {
    try {
      var collectionRef = firebase.firestore!.collection('data_user');
      var querySnapshot = await collectionRef
          .where('id', isEqualTo: userId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (e) {
      LOG('--> getUserInfo Error : $e');
      throw e.toString();
    }
    return null;
  }

  //----------------------------------------------------------------------------------------
  //
  //    upload file..
  //

  Future? uploadImageData(JSON imageInfo, String path) async {
    if (imageInfo['image'] != null) {
      try {
        final ref = firebase.firesStorage!.ref().child('$path/${imageInfo['id']}');
        var uploadTask = ref.putData(imageInfo['image']);
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
}

