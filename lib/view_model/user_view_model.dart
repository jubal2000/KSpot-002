import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/story_model.dart';

import '../data/app_data.dart';
import '../models/event_model.dart';
import '../utils/utils.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';
import '../view/profile/profile_tab_screen.dart';

enum ProfileMainTab {
  profile,
  follow,
  like,
}

enum ProfileContentTab {
  event,
  story,
}

class UserViewModel extends ChangeNotifier {
  final repo = UserRepository();

  UserModel? userInfo;
  List<MainMyTab> tabList = [];
  List<GlobalKey> tabKeyList = [];
  BuildContext? buildContext;

  var currentTab = 0;
  var isMyProfile = false;
  var tabListHeight = 0.0;

  initUserModel(UserModel user) {
    userInfo = user;
    isMyProfile = userInfo!.checkOwner(AppData.USER_ID);
    tabKeyList = List.generate(3, (index) => GlobalKey());
    tabList = [
      MainMyTab(ProfileMainTab.profile , 'PROFILE'.tr  , this, key: tabKeyList[0]),
      MainMyTab(ProfileMainTab.follow  , 'FOLLOW'.tr   , this, key: tabKeyList[1]),
      MainMyTab(ProfileMainTab.like    , 'BOOKMARK'.tr , this, key: tabKeyList[2]),
    ];
  }

  initUserModelFromId(String userId) async {
    final info = await repo.getUserInfo(userId);
    if (info != null) {
      initUserModel(info);
    }
  }

  refresh() {
    notifyListeners();
  }

  setContext(context) {
    buildContext = context;
  }

  getEventData(bool addExpired) {
    return repo.getEventFromUserId(userInfo!.id, addExpired);
  }

  getStoryData() {
    return repo.getStoryFromUserId(userInfo!.id);
  }

  setMainTab(index) {
    currentTab = index;
    notifyListeners();
  }
}
