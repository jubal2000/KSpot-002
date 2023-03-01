import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../models/chat_model.dart';
import '../models/event_model.dart';
import '../models/story_model.dart';
import '../services/cache_service.dart';
import '../services/local_service.dart';
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

  addBlockUser(context, UserModel targetUser, [Function(JSON)? onResult]) {
    final cache = Get.find<CacheService>();
    final blockInfo = cache.blockData[targetUser.id];
    if (blockInfo == null) {
      showAlertYesNoDialog(context, 'To black'.tr,
          'Are you sure you want to block that user?'.tr, '${'Target'.tr} : ${targetUser.nickName}', 'Cancel'.tr, 'OK'.tr)
          .then((value) {
        if (value == 1) {
          showLoadingDialog(context, 'Processing now...'.tr);
          api.addBlockItem('user', targetUser.toJson(), AppData.USER_ID).then((result) {
            hideLoadingDialog();
            if (result != null) {
              showAlertDialog(context, 'To black'.tr, 'The user has been blocked'.tr, '', 'OK'.tr);
              cache.blockData[targetUser.id] = result;
              if (onResult != null) onResult(result);
            }
          });
        }
      });
    } else {
      showAlertYesNoDialog(context, 'Block'.tr, 'Already blocked'.tr,
          'Are you sure you want to cancel the block?'.tr, 'NO'.tr, 'Yes, Cancel block'.tr).then((result) {
        if (result == 1) {
          api.setBlockItemStatus(blockInfo.id, 0).then((_) {
            cache.blockData.remove(blockInfo.id);
            if (onResult != null) onResult(blockInfo);
          });
        }
      });
    }
  }

  addReportItem(context, String type, ChatRoomModel targetRoom, [Function(JSON)? onResult]) {
    final cache = Get.find<CacheService>();
    final reportInfo = cache.reportData['report'] != null ? cache.reportData['report'][targetRoom.id] : null;
    if (reportInfo == null) {
      showReportDialog(context, ReportType.report,
          'Report'.tr, type, targetRoom.toJson(), subTitle: 'Please write what you want to report'.tr).then((result) async {
        if (result.isNotEmpty) {
          cache.reportData['report'] ??= {};
          cache.reportData['report'][targetRoom.id] = result;
          ShowToast('Report has been completed'.tr);
          if (onResult != null) onResult(result);
          // showAlertDialog(context, 'Report'.tr, 'Report has been completed'.tr, '', 'OK'.tr).then((_) {
          //   if (onResult != null) onResult(result);
          // });
        }
      });
    } else {
      showAlertYesNoDialog(context, 'Report'.tr, 'Already reported'.tr,
          'Are you sure you want to cancel the report?'.tr, 'NO'.tr, 'Yes, Cancel report'.tr).then((result) {
        if (result == 1) {
          api.setReportItemStatus(reportInfo['id'], 0).then((_) {
            cache.reportData['report'].remove(targetRoom.id);
            if (onResult != null) onResult(reportInfo);
          });
        }
      });
    }
  }

  removeReportItem(context, String reportId, String roomId, [Function()? onResult]) {
    final cache = Get.find<CacheService>();
    showAlertYesNoDialog(context, 'Report'.tr,
        'Are you sure you want to cancel the report?'.tr, '', 'NO'.tr, 'Yes, Cancel report'.tr).then((result) {
      if (result == 1) {
        LOG('--> removeReportItem result : $reportId / $roomId');
        api.setReportItemStatus(reportId, 0).then((_) {
          cache.reportData['report'].remove(roomId);
          ShowToast('Report has been canceled'.tr);
          if (onResult != null) onResult();
          // showAlertDialog(context, 'Report'.tr, 'Report has been canceled'.tr, '', 'OK'.tr).then((_) {
          //   if (onResult != null) onResult;
          // });
        });
      }
    });
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
