import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:kspot_002/view_model/user_view_model.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';
import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/themes.dart';
import '../models/etc_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utils/utils.dart';
import '../models/start_model.dart';
import '../repository/user_repository.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';
import '../view/event/event_edit_screen.dart';
import '../widget/event_group_dialog.dart';

class MainMenuID {
  static int get hide     => 0;
  static int get back     => 1;
  static int get event    => 2;
  static int get story    => 3;
  static int get my       => 4;
  static int get max      => 5;
}

const COUNTRY_LOG_MAX = 5;

class AppViewModel extends ChangeNotifier {
  var isShowDialog = false;
  var isCanStart = false;
  BuildContext? buildContext;

  // app bar..
  var appbarMenuMode = MainMenuID.event;
  var menuIndex = 0;

  init(BuildContext context) {
    buildContext = context;
  }

  setCanStart(value) {
    isCanStart = value;
    notifyListeners();
  }

  setMainIndex(index) {
    menuIndex = index;
    appbarMenuMode = index == 0 ? MainMenuID.event : MainMenuID.story;
    LOG('--> setMainIndex : $index');
    notifyListeners();
  }

  showGroupSelect() {
    EventGroupSelectDialog(buildContext!,
        AppData.currentEventGroup!.id,
        AppData.currentEventGroup!.contentType).then((_) {
          AppData.eventViewModel.refreshModel();
          notifyListeners();
    });
  }

  Future<bool> checkAppUpdate(VersionData serverVersionData) async {
    if (isShowDialog) return false;
    isShowDialog = true;
    LOG('--> checkAppUpdate : ${serverVersionData.toJson()}');

    // check version from server..
    final versionLocal  = await StorageManager.readData('appVersion');
    final versionServer = serverVersionData.version;
    final isForceUpdate = serverVersionData.type == 1;
    // final version = ''; // for Dev..
    LOG('--> version : $isForceUpdate / $versionLocal / $versionServer');
    if (checkVersionString(APP_VERSION, versionServer, versionLocal ?? '')) {
      var dlgResult = await showAppUpdateDialog(buildContext!,
        'New Version',
        '$APP_VERSION > $versionServer',
        isForceUpdate: isForceUpdate,
      );
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

  showCountrySelect(context, [Function? onChanged]) {
    final List<JSON> logList = AppData.countrySelectList.map((e) => e.toJson()).toList();
    showCountryLogSelectDialog(context, 'COUNTRY SELECT'.tr, logList).then((_) {
        for (var item in AppData.countrySelectList) {
          if (item.country == AppData.currentCountry && item.countryState == AppData.currentState) {
            AppData.countrySelectList.remove(item);
            break;
          }
        }
        AppData.countrySelectList.insert(0, CountryData(
            country:      AppData.currentCountry,
            countryState: AppData.currentState,
            countryFlag:  AppData.currentCountryFlag,
            createTime  : CURRENT_SERVER_TIME().toString(),
        ));
        if (AppData.countrySelectList.length > COUNTRY_LOG_MAX) {
          AppData.countrySelectList.removeLast();
        }
        LOG('--> AppData.countrySelectList : ${AppData.countrySelectList.length}');
        writeCountryLog();
        notifyListeners();
        if (onChanged != null) onChanged();
      }
    );
  }

  showAddMenu(iconColor, iconSize) {
    if (appbarMenuMode == MainMenuID.event || appbarMenuMode == MainMenuID.story || appbarMenuMode == MainMenuID.my) {
      return DropdownButtonHideUnderline(
        child: DropdownButton2(
          customButton: Center(
            child: Icon(Icons.add, color: iconColor),
          ),
          items: [
            if (appbarMenuMode == MainMenuID.event)
              ...DropdownItems.eventAddItem.map(
                    (item) =>
                    DropdownMenuItem<DropdownItem>(
                      value: item,
                      child: DropdownItems.buildItem(buildContext!, item),
                    ),
              ),
            if (appbarMenuMode == MainMenuID.story)
              ...DropdownItems.storyAddItem.map(
                    (item) =>
                    DropdownMenuItem<DropdownItem>(
                      value: item,
                      child: DropdownItems.buildItem(buildContext!, item),
                    ),
              ),
            if (appbarMenuMode == MainMenuID.my)
              ...DropdownItems.homeAddItems.map(
                    (item) =>
                    DropdownMenuItem<DropdownItem>(
                      value: item,
                      child: DropdownItems.buildItem(buildContext!, item),
                    ),
              ),
          ],
          onChanged: (value) {
            // if (!isCreatorMode()) {
            //   showAlertYesNoDialog(context, 'CREATOR MODE', 'You need creator mode ON', 'Move to setting screen?', 'No', 'Yes').then((result) {
            //     if (result == 1) {
            //       Navigator.of(AppData.topMenuContext!).popUntil((r) => r.isFirst);
            //       Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupScreen(moveTo: 'creator')));
            //     }
            //   });
            //   return;
            // }
            var selected = value as DropdownItem;
            LOG("--> selected.index : ${selected.type}");
            switch (selected.type) {
              case DropdownItemType.event:
                Get.to(() => EventEditScreen())!.then((_) {
                  notifyListeners();
                });
                break;
              case DropdownItemType.story:
                break;
            }
          },
          itemHeight: 45,
          dropdownWidth: 190,
          buttonHeight: iconSize,
          buttonWidth: iconSize,
          offset: const Offset(0, 5),
        ),
      );
    } else {
      return Container();
    }
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
        actionsPadding: EdgeInsets.only(right: 20, bottom: 0),
        actionsAlignment: MainAxisAlignment.center,
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

  @override
  void dispose() {
    super.dispose();
  }
}
