import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:store_redirect/store_redirect.dart';
import '../../data/app_data.dart';
import '../../data/utils.dart';
import '../../services/api_service.dart';
import '../../services/local_service.dart';

class IntroController extends GetxController {
  final api   = Get.find<ApiService>();
  final local = Get.find<LocalService>();

  var isShowDialog = false;
  var isCanStart = false;

  @override
  void onInit() async {
    super.onInit();
  }

  Future<bool> checkAppUpdate(BuildContext context, JSON serverVersionData) async {
    if (isShowDialog) return false;
    isShowDialog = true;
    LOG('--> checkAppUpdate : $serverVersionData');

    // check version from server..
    final versionLocal = await StorageManager.readData('appVersion');
    final versionData  = serverVersionData['appVersion'];
    if (versionData != null) {
      final versionInfo = Platform.isAndroid ? versionData['android'] : versionData['ios'];
      final isForceUpdate = versionInfo['update'].toLowerCase() == 'y';
      // final version = ''; // for Dev..
      LOG('--> version : $isForceUpdate / $versionLocal / ${versionInfo['version']}');
      if (isForceUpdate || checkVersionString(APP_VERSION, STR(versionInfo['version']), versionLocal ?? '')) {
        var dlgResult = await showAppUpdateDialog(context,
          STR(versionInfo['message']),
          '$APP_VERSION > ${STR(versionInfo['version'])}',
          isForceUpdate: isForceUpdate,
        );
        LOG('--> showAppUpdateDialog result : $dlgResult');
        switch (dlgResult) {
          case 1: // move market..
            StoreRedirect.redirect(
                androidAppId: "com.jhfactory.tld_info_00",
                iOSAppId: "1597866658"
            );
            return !isForceUpdate;
          case 2: // never show again..
            StorageManager.saveData('appVersion', STR(versionInfo['version']));
            break;
        }
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
              Image(image: AssetImage('assets/icons/app_icon_01.png'), height: 80, fit: BoxFit.fitHeight),
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
