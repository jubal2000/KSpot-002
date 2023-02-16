import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../models/event_model.dart';
import '../models/story_model.dart';
import '../utils/utils.dart';
import '../models/user_model.dart';

class UserRepository {
  final api = Get.find<ApiService>();

  //----------------------------------------------------------------------------
  //  user signup & sign in
  //

  Future<UserModel?> startGuestUser() async {
    if (AppData.loginInfo.loginId.isEmpty) {
      final userCred = await FirebaseAuth.instance.signInAnonymously();
      LOG('--> userCredential : $userCred');
      if (userCred.user != null) {
        setGuestUserInfo(userCred.user!);
      } else {
        return null;
      }
    }
    return await createGuestUser();
  }

  setGuestUserInfo(User user) {
    AppData.loginInfo.loginId   = STR(user.uid);
    AppData.loginInfo.nickName  = 'Guest User';
    AppData.loginInfo.pic       = NO_IMAGE;
    AppData.loginInfo.loginType = 'guest';
  }

  setLoginUserInfo(User user, {String type = 'phone'}) {
    AppData.loginInfo.loginId   = STR(user.uid);
    AppData.loginInfo.email     = STR(user.email);
    AppData.loginInfo.nickName  = STR(user.displayName);
    AppData.loginInfo.pic       = STR(user.photoURL);
    AppData.loginInfo.loginType = type;
  }

  createGuestUser([String type = 'guest']) async {
    final orgUser = await getStartUserInfo(AppData.loginInfo.loginId);
    if (orgUser != null) {
      AppData.userInfo = orgUser;
      return orgUser;
    } else {
      final newUser = await createNewUser(
        UserModelEx.create(
            AppData.loginInfo.loginId,
            type,
            nickName: AppData.loginInfo.nickName,
            pic: AppData.loginInfo.pic
        )
      );
      if (newUser != null) {
        AppData.userInfo = newUser;
        return newUser;
      }
    }
    return null;
  }

  Future<UserModel?> getStartUserInfo(String loginId) async {
    try {
      final response = await api.getStartUserInfo(loginId);
      LOG("--> getStartUserInfo result: $response");
      if (response != null) {
        final result = UserModel.fromJson(FROM_SERVER_DATA(response));
        return result;
      }
    } catch (e) {
      LOG("--> getStartUserInfo error: $e");
    }
    return null;
  }

  Future<UserModel?> getUserInfo(String userId) async {
    try {
      if (AppData.userData.containsKey(userId)) return AppData.userData[userId];
      final response = await api.getUserInfoFromId(userId);
      if (response != null) {
        final userData = UserModel.fromJson(FROM_SERVER_DATA(response));
        LOG("--> getUserInfo result: ${userData.toJson()}");
        AppData.userData[userData.id] = userData;
        return userData;
      }
    } catch (e) {
      LOG("--> getUserInfo error: $e");
    }
    return null;
  }

  Future<bool> setUserInfoJSON(String userId, JSON items) async {
    LOG('--> setUserInfoJSON : $userId / $items');
    if (userId.isEmpty) return false;
    return api.setUserInfoJSON(userId, items);
  }

  Future<bool> setUserInfoItem(UserModel user, String key) async {
    final userInfo = user.toJson();
    LOG('--> setUserInfoItem : ${user.id} - $key / ${userInfo[key]}');
    return api.setUserInfoItem(userInfo, key);
  }

  Future<UserModel?> createNewUser(UserModel user) async {
    final response = await api.createNewUser(user.toJson());
    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }

  Future<Map<String, EventModel>> getEventFromUserId(String userId, [bool addExpired = false]) async {
    Map<String, EventModel> result = {};
    final response = await api.getEventFromUserId(userId, addExpired);
    if (response != null && response.isNotEmpty) {
      for (var item in response.entries) {
        result[item.key] = EventModel.fromJson(item.value);
      }
    }
    return result;
  }

  Future<Map<String, StoryModel>> getStoryFromUserId(String userId) async {
    Map<String, StoryModel> result = {};
    try {
    final response = await api.getStoryFromUserId(userId);
    if (JSON_NOT_EMPTY(response)) {
      for (var item in response.entries) {
        LOG('--> response item : ${item.value.toString()}');
        result[item.key] = StoryModel.fromJson(item.value);
      }
    }
    LOG('--> StoryModel result : ${result.length}');
    } catch (e) {
      LOG('--> StoryModel error : ${e.toString()}');
    }
    return result;
  }

  Future<JSON?> addFollowTarget(JSON targetInfo) async {
    return await api.addFollowTarget(AppData.userInfo.toJson(), targetInfo);
  }


  Future<JSON> getReportData() async {
    return await api.getReportData(AppData.USER_ID);
  }

  Future<JSON> getBlockData() async {
    return await api.getBlockData(AppData.USER_ID);
  }

  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<String?> uploadImageData(JSON imageInfo, String path) async {
    if (imageInfo['data'] != null) {
      return await api.uploadImageData(imageInfo, path);
    }
    return null;
  }
}
