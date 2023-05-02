import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/sponsor_model.dart';
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
  final cache = Get.find<CacheService>();
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

  addBlockUser(context, JSON targetItem, [Function(JSON)? onResult]) {
    final cache = Get.find<CacheService>();
    final blockInfo = cache.blockData[targetItem['id']];
    if (blockInfo == null) {
      showAlertYesNoDialog(context, 'To black'.tr,
          'Are you sure you want to block that user?'.tr, '${'Target'.tr} : ${targetItem['nickName']}', 'Cancel'.tr, 'OK'.tr)
          .then((value) {
        if (value == 1) {
          api.addBlockItem('user', targetItem, AppData.USER_ID).then((result) {
            if (result != null) {
              ShowToast('Target has been blocked'.tr);
              cache.blockData[targetItem['id']] = result;
              if (onResult != null) onResult(result);
            }
          });
        }
      });
    } else {
      showAlertYesNoDialog(context, 'Block'.tr, 'Already blocked'.tr,
          'Are you sure you want to cancel the block?'.tr, 'NO'.tr, 'Yes, Cancel block'.tr).then((result) {
        if (result == 1) {
          api.setBlockItemStatus(blockInfo['id'], 0).then((_) {
            ShowToast('Unblocking is complete'.tr);
            cache.blockData.remove(targetItem['id']);
            if (onResult != null) onResult(blockInfo);
          });
        }
      });
    }
  }

  addReportItem(context, String type, JSON targetItem, [Function(JSON)? onResult]) {
    if (!AppData.isMainActive) return;
    AppData.isMainActive = false;
    final cache = Get.find<CacheService>();
    final reportInfo = cache.reportData['report'] != null ? cache.reportData['report'][targetItem['id']] : null;
    if (reportInfo == null) {
      showReportDialog(context, ReportType.report,
          'Report'.tr, type, targetItem, subTitle: 'Please write what you want to report'.tr).then((result) async {
        if (result.isNotEmpty) {
          cache.reportData['report'] ??= {};
          cache.reportData['report'][targetItem['id']] = result;
          ShowToast('Report has been completed'.tr);
          if (BOL(result['blockUser'])) {
            Future.delayed(Duration(seconds: 1)).then((_) {
              api.addBlockItem('user', targetItem, AppData.USER_ID).then((result) {
                if (result != null) {
                  ShowToast('Target has been blocked'.tr);
                  cache.blockData[targetItem['id']] = result;
                  if (onResult != null) onResult(result);
                }
                AppData.isMainActive = true;
              });
            });
          } else {
            AppData.isMainActive = true;
            if (onResult != null) onResult(result);
          }
        }
      });
    } else {
      showAlertYesNoDialog(context, 'Report'.tr, 'Already reported'.tr,
          'Are you sure you want to cancel the report?'.tr, 'NO'.tr, 'Yes, Cancel report'.tr).then((result) {
        if (result == 1) {
          api.setReportItemStatus(reportInfo['id'], 0).then((_) {
            cache.reportData['report'].remove(targetItem['id']);
            AppData.isMainActive = true;
            if (onResult != null) onResult(reportInfo);
          });
        } else {
          AppData.isMainActive = true;
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
        UserModel.create(
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
      var cacheItem = cache.getUserItem(userId);
      if (cacheItem != null) return cacheItem;
      final response = await api.getUserInfoFromId(userId);
      if (response != null) {
        // LOG("--> getUserInfo result: ${response.toString()}");
        final addItem = UserModel.fromJson(FROM_SERVER_DATA(response));
        cache.setUserItem(addItem);
        return addItem;
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

  Future<bool> setUserInfo(UserModel user) async {
    final userInfo = user.toJson();
    LOG('--> setUserInfo : ${user.id} / ${user.toJson()}');
    return api.setUserInfo(userInfo);
  }

  Future<bool> setUserInfoItem(UserModel user, String key) async {
    final userInfo = user.toJson();
    LOG('--> setUserInfoItem : ${user.id} - $key / ${user.toJson()}');
    return api.setUserInfoItem(userInfo, key);
  }

  Future<bool> setMyUserInfo() async {
    return await api.setUserInfo(AppData.userInfo.toJson());
  }

  Future<UserModel?> createNewUser(UserModel user) async {
    final response = await api.createNewUser(user.toJson());
    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }

  getEventFromId(String eventId) async {
    final result = await api.getEventFromId(eventId);
    if (result != null) {
      return EventModel.fromJson(result);
    }
    return null;
  }

  Future<Map<String, EventModel>> getEventFromUserId(String userId, {bool isAuthor = false, DateTime? lastTime}) async {
    Map<String, EventModel> result = {};
    try {
      final response = await api.getEventFromUserId(userId, isAuthor: isAuthor, lastTime: lastTime, limit: PROFILE_CONTENT_MAX);
      if (JSON_NOT_EMPTY(response)) {
        for (var item in response.entries) {
          result[item.key] = EventModel.fromJson(item.value);
        }
      }
    } catch (e) {
      LOG('--> getEventFromUserId error : ${e.toString()}');
    }
    return result;
  }

  getStoryFromId(String storyId) async {
    final result = await api.getStoryFromId(storyId);
    if (result != null) {
      return StoryModel.fromJson(result);
    }
    return null;
  }

  Future<Map<String, StoryModel>> getStoryFromUserId(String userId, {bool isAuthor = false, DateTime? lastTime}) async {
    Map<String, StoryModel> result = {};
    try {
      final response = await api.getStoryFromUserId(userId, isAuthor: isAuthor, lastTime: lastTime, limit: PROFILE_CONTENT_MAX);
      if (JSON_NOT_EMPTY(response)) {
        for (var item in response.entries) {
          result[item.key] = StoryModel.fromJson(item.value);
        }
      }
    } catch (e) {
      LOG('--> getStoryFromUserId error : ${e.toString()}');
    }
    return result;
  }

  Future<Map<String, SponsorModel>> getSponsorFromUserId(String userId, {bool isAuthor = false, DateTime? lastTime}) async {
    Map<String, SponsorModel> result = {};
    try {
      final response = await api.getSponsorFromUserId(userId, isAuthor: isAuthor, lastTime: lastTime, limit: PROFILE_CONTENT_MAX);
      if (JSON_NOT_EMPTY(response)) {
        for (var item in response.entries) {
          result[item.key] = SponsorModel.fromJson(item.value);
        }
      }
    } catch (e) {
      LOG('--> getSponsorFromUserId error : ${e.toString()}');
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

  setReportDesc(String targetId, String desc) async {
    return await api.setReportDesc(AppData.blockUserData, targetId, desc);
  }

  getLikeFromUserId(String userId) {
    return api.getLikeFromUserId(userId);
  }

  getBookmarkData() async {
    return await api.getBookmarkFromUserId(AppData.USER_ID);
  }

  getBookmarkFromUserId(String userId) {
    return api.getBookmarkFromUserId(userId);
  }

  Future<JSON> getLikeFromTargetId(String userId) async {
    return await api.getLikeFromUserId(userId);
  }

  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<String?> uploadImageData(JSON imageInfo, String path) async {
    if (imageInfo['data'] != null) {
      return await api.uploadImageData(imageInfo, path);
    }
    return null;
  }
}
