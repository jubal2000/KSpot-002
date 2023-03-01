import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:kspot_002/services/cache_service.dart';
import '../repository/chat_repository.dart';
import '../repository/message_repository.dart';
import 'firebase_service.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/routes.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';

class AuthService extends GetxService {
  Future<AuthService> init() async {
    return this;
  }

  final fire      = Get.find<FirebaseService>();
  final cache     = Get.find<CacheService>();
  final userRepo  = UserRepository();
  final msgRepo   = MessageRepository();
  final chatRepo  = ChatRepository();
  Function? onSignIn;
  Function? onSignOut;
  Function(int)? onError;

  var isLoginCheckDone = false;

  initUserSignIn() {
    if (isLoginCheckDone) return;
    fire.fireAuth!.authStateChanges()
        .listen((User? user) async {
      // reset user info..
      AppData.loginInfo = UserModelEx.signOut();
      AppData.userInfo  = UserModelEx.signOut();

      if (user == null) {
        LOG('------> User is currently signed out!');
        Get.offAllNamed(Routes.INTRO);
        if (onSignOut != null) onSignOut!();
      } else {
        LOG('------> User is signed in! : ${AppData.isSignUpMode}');
        setLoginUserInfo(user);

        if (!AppData.isSignUpMode) {
          final result = await userRepo.getStartUserInfo(AppData.loginInfo.loginId);
          if (result != null) {
            AppData.userInfo = result;
            LOG('--> getStartUserInfo done! : ${AppData.userInfo.id}');
            // get user ex data..
            cache.reportData    = await userRepo.getReportData();
            cache.blockData     = await userRepo.getBlockData();
            cache.readRoomIndexData();
            // cache.messageData   = await msgRepo.getMessageData();
            // cache.chatRoomData  = await chatRepo.getChatRoomData();
            LOG('--> cache.chatRoomData : ${cache.reportData.toString()}');
            Get.offAllNamed(Routes.HOME);
          } else {
            LOG('--> getStartUserInfo failed! : ${AppData.loginInfo.loginId} / ${AppData.loginInfo.loginType}');
            if (onError != null) onError!(0);
          }
          if (onSignIn != null) onSignIn!();
        }
      }
      isLoginCheckDone = true;
    });
  }

  signOut() {
    fire.fireAuth!.signOut();
  }

  setLoginUserInfo(user) {
    AppData.loginInfo.loginId   = STR(user.uid);
    AppData.loginInfo.email     = STR(user.email);
    AppData.loginInfo.nickName  = STR(user.displayName);
    AppData.loginInfo.pic       = STR(user.photoURL);
  }
}