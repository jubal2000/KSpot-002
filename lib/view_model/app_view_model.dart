import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:store_redirect/store_redirect.dart';
import '../data/app_data.dart';
import '../data/themes.dart';
import '../data/utils.dart';
import '../models/start_model.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';

class AppViewModel extends ChangeNotifier {
  final _api = Get.find<ApiService>();

  var isShowDialog = false;
  var isCanStart = false;
  var mainIndex = 0;

  setCanStart(value) {
    isCanStart = value;
    notifyListeners();
  }

  Future<bool> checkAppUpdate(BuildContext context, StartModel? serverVersionData) async {
    if (isShowDialog || serverVersionData == null) return false;
    isShowDialog = true;
    LOG('--> checkAppUpdate : ${serverVersionData.toJSON()}');

    // check version from server..
    final versionLocal  = await StorageManager.readData('appVersion');
    final versionServer = Platform.isAndroid ? serverVersionData.androidVersion : serverVersionData.iosVersion;
    final isForceUpdate = Platform.isAndroid ? serverVersionData.androidUpdate : serverVersionData.iosUpdate;
    // final version = ''; // for Dev..
    LOG('--> version : $isForceUpdate / $versionLocal / $versionServer');
    if (isForceUpdate || checkVersionString(APP_VERSION, versionServer, versionLocal ?? '')) {
      var dlgResult = await showAppUpdateDialog(context,
        'New Version',
        '$APP_VERSION > $versionServer',
        isForceUpdate: isForceUpdate,
      );
      LOG('--> showAppUpdateDialog result : $dlgResult');
      switch (dlgResult) {
        case 1: // move market..
          StoreRedirect.redirect(
              androidAppId: "com.jhfactory.kspot_002.android",
              iOSAppId: "1597866658"
          );
          return !isForceUpdate;
        case 2: // never show again..
          StorageManager.saveData('appVersion', versionServer);
          break;
      }
    }
    return true;
  }

  getNumberFromVersion(String version) {
    var offsetN = [10000, 100, 1];
    var result = 0;
    var arr = version.split('.');
    for (var i=0; i<arr.length; i++) {
      try {
        var value = int.parse(arr[i]);
        result += value * offsetN[i];
        LOG('--> [$i] : $value * ${offsetN[i]}');
      } catch (e) {
        LOG('--> getNumberFromVersion error : $e');
      }
    }
    return result;
  }

  checkVersionString(String source, String target, String local) {
    try {
      var source2 = getNumberFromVersion(source);
      var target2 = getNumberFromVersion(target);
      LOG('--> checkVersionString : $source2 / $target2 - $source / $target / $local');
      return local != target && source2 < target2;
    } catch (e) {
      LOG('--> error : $e');
    }
    return false;
  }

  Future<int> showAppUpdateDialog(BuildContext context, String desc, String? msg, {bool isForceUpdate = false }) async {
    // print('--> showAppUpdateDialog : $desc / $msg');
    msg ??= '';
    msg = msg.replaceAll('\\n' , '\n');
    msg = msg.replaceAll('<br>', '\n');
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
      return AlertDialog(
        title: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text('App update'.tr),
        ),
        insetPadding: EdgeInsets.all(40),
        contentPadding: EdgeInsets.all(20),
        content: Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(
            maxWidth: 800,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Image(image: AssetImage(APP_LOGO_XL), height: 80, fit: BoxFit.fitHeight),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  desc,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              if (msg!.isNotEmpty)...[
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    msg,
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple, height: 1.5),
                  ),
                ),
              ]
            ]
          )
        ),
        actions: <Widget>[
          if (!isForceUpdate)
            TextButton(
              child: Text('다시보지않기', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop(2);
              },
            ),
          TextButton(
            // child: Text(isForceUpdate ? '마켓으로 이동' : '확인'),
            child: Text('마켓으로 이동'),
            onPressed: () {
              isShowDialog = false;
              Navigator.of(context).pop(1);
//              Navigator.of(context).pop(isForceUpdate ? 1 : 0);
            },
          ),
        ],
      );
    });
  }
}
