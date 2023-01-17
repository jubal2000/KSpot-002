
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/repository/userRepo.dart';
import 'package:uuid/uuid.dart';
import '../data/app_data.dart';
import '../data/firebase_options.dart';
import '../utils/message.dart';
import '../utils/push_utils.dart';
import '../utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_service.dart';

class FirebaseService extends GetxService {
  Future<FirebaseService> init() async {
    await initService();
    await initMessaging();
    return this;
  }

  FirebaseMessaging? messaging;
  FirebaseFirestore? firestore;
  PendingDynamicLinkData? initialLink;

  String? token;
  String? recommendCode;
  bool initLink = false;
  bool isInit = false;
  bool isLoginDone = false;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'alert_channel_00', // id
    'Alert Notifications', // title
    description: 'This channel is used for alert notifications.', // description
    importance: Importance.max,
  );

  initService() async {
    if (isInit) return;
    isInit = true;

    await Firebase.initializeApp();
    // init firebase..
    // if (defaultTargetPlatform == TargetPlatform.android) {
    //   await Firebase.initializeApp(
    //       options: DefaultFirebaseOptions.currentPlatform
    //   );
    // } else {
    //   await Firebase.initializeApp(
    //       name: 'KSpot_00',
    //       options: DefaultFirebaseOptions.currentPlatform
    //   );
    // }

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        LOG('--> User is currently signed out!');
      } else {
        LOG('--> User is signed in!');
        getLoginUserInfo(user);
      }
      isLoginDone = true;
    });
  }

  initMessaging() async {
    messaging = FirebaseMessaging.instance;
    firestore = FirebaseFirestore.instance;

    // get firebase token..
    token = await messaging!.getToken();
    LOG('--> firebase init token : $token');

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // alert permission..
    await messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // alert option..
    await messaging!.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    // FirebaseMessaging.onMessage.listen(onMessageListener);
    // FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppListener);
    // onBackgroundMessage 동작 안함
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // dynamic link ready..
    initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

    initCacheData();

    if (AppData.isDevMode) {
      FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
          forceRecaptchaFlow: true
      );
    }
    // this.subscribeTopic();
  }

  getLoginUserInfo(user) {
    AppData.loginInfo.loginId   = STR(user.uid);
    AppData.loginInfo.email     = STR(user.email);
    AppData.loginInfo.nickName  = STR(user.displayName);
    AppData.loginInfo.pic       = STR(user.photoURL);
  }

  void showReceiveLocalNotificationDialog(
      BuildContext context, int id, String title, String body, String payload) async {

    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Row(
          children: [
            Text(body),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }


  getToken() async {
    try {
      AppData.userInfo.pushToken = await FirebaseMessaging.instance.getToken() ?? '';
      LOG('---> FCM Token : ${AppData.userInfo.pushToken}');
    } catch (e) {
      LOG('---> FCM Token error : $e');
    }
  }

  initDataLink(BuildContext context) {
    if (initLink) return;
    LOG('--> initDataLink');
    initLink = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPush(context);
      initDeepLink(context);
    });
  }

  initPush(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showPush(message, false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LOG('--> FirebaseMessaging.onMessageOpenedApp.listen : $message');
      Navigator.pushNamed(
        context,
        '/message',
        arguments: MessageArguments(message, true),
      );
    });
  }

  initDeepLink(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialLink != null) {
        deepLinkProcess(context, initialLink);
      }
      // when app running..
      FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
        deepLinkProcess(context, dynamicLinkData);
      }).onError((error) {
        // Handle errors
        LOG('--> dynamicLinkData.link error : $error');
      });
    });
  }

  deepLinkProcess(BuildContext context, dynamicLinkData) {
    LOG('--> dynamicLinkData : $dynamicLinkData');
    // if (dynamicLinkData.link.path.contains('share_content')) {
    //   final Uri uri = dynamicLinkData.link;
    //   LOG('--> share_content link : ${uri.queryParameters.toString()}');
    //   final linkData = uri.queryParameters['data'];
    //   if (linkData != null) {
    //     var linkDataN = linkData.split(',');
    //     var targetId = linkDataN[1];
    //     var desc = '${linkDataN[0]} / $targetId';
    //     if (targetId.isEmpty) return;
    //     switch(linkDataN[0]) {
    //       case 'story':
    //         moveToStoryDetail(targetId);
    //         break;
    //       case 'place':
    //         moveToPlaceDetail(targetId);
    //         break;
    //       case 'event':
    //         moveToEventDetail(targetId);
    //         break;
    //     }
    //     ShowToast(desc);
    //   }
    // } else if (dynamicLinkData.link.path.contains('email_update')) {
    //   if (STR(AppData.userInfo['emailNew']).isEmpty) return;
    //   AppData.userInfo['email'] = STR(AppData.userInfo['emailNew']);
    //   AppData.userInfo['emailNew'] = '';
    //   AppData.userInfo['emailVerified'] = '1';
    //   api.setUserInfo(AppData.userInfo).then((result) {
    //     if (result) {
    //       AppData.userInfo = FROM_SERVER_DATA(AppData.userInfo);
    //       AppData.isEmailVerifyDone = true;
    //       Navigator.of(AppData.topMenuContext!).popUntil((r) => r.isFirst);
    //       Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupScreen(moveTo: 'contact'))).then((result) {
    //         // AppData.mainMenuKey.currentState!.setShowMenu(buildScreens.length - 1);
    //         if (result == 'edited') {
    //           AppData.isUpdateProfile = true;
    //         }
    //       });
    //     } else {
    //       ShowToast('Email verify failed');
    //     }
    //   });
    // }
  }

  sendTestPushMessage(String type) async {
    var _key = Uuid().v1();
    JSON _addItem = {
      "id": _key,
      "status": 1,
      "senderId":   STR(AppData.USER_ID),
      "senderName": STR(AppData.USER_NICKNAME),
      "senderPic":  STR(AppData.USER_PIC),
      "targetId":   '',
      "targetName": '',
      "targetPic":  '',
      "imageData":  [],
      "desc": "Hi! this is $type!!",
      "createTime": CURRENT_SERVER_TIME(),
    };
    _addItem = FROM_SERVER_DATA(_addItem);
    sendFcmData(
        'AppData.testToken',
        AppData.USER_NICKNAME,
        _addItem['desc'],
        {
          'type'  : type,
          'data'  : _addItem,
        }
    );
    ShowToast('send: ${_addItem['desc']}');
  }

  showPush(RemoteMessage message, bool isBackground) {
    RemoteNotification? notification = message.notification;
    if (notification != null && !kIsWeb) {
      print('--> FirebaseMessaging android : ${notification.title} / ${notification.body}');
      var customData = message.data;
      var isShowPush = false;
      var title = notification.title;
      var desc = notification.body;
      if (customData['data'] != null) {
        var itemData = jsonDecode(customData['data'].toString());
        LOG('--> customData : ${STR(customData['type'])} / $itemData');
        String targetId = STR(itemData['id']) ?? Uuid().v1();
        switch (STR(customData['type'])) {
          case 'message':
            isShowPush = AppData.userInfo!.optionPush.isEmpty || BOL(AppData.userInfo!.optionPush['message_on']);
            // AppData.messageData[targetId] = itemData;
            // var state = AppData.messagesListKey.currentState;
            // if (state != null && state.mounted) {
            //   state.refresh(itemData);
            //   isShowPush = false;
            // }
            // LOG('--> messageData add [$targetId] : ${AppData.messageData}');
            break;
          case 'comment':
            isShowPush = AppData.userInfo!.optionPush.isEmpty || BOL(AppData.userInfo!.optionPush['comment_on']);
            break;
        }
      }

      if (isShowPush || isBackground) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          title,
          desc,
          NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
                // largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                // icon: 'push_icon',
              ),
              iOS: DarwinNotificationDetails(
              )
          ),
        );
      }
    }
  }

  onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {
          LOG(
            'FlutterFire Messaging Example: Subscribing to topic "fcm_test".',
          );
          await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
          LOG(
            'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.',
          );
        }
        break;
      case 'unsubscribe':
        {
          LOG(
            'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test".',
          );
          await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
          LOG(
            'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test" successful.',
          );
        }
        break;
      case 'get_apns_token':
        {
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) {
            LOG('FlutterFire Messaging Example: Getting APNs token...');
            String? token = await FirebaseMessaging.instance.getAPNSToken();
            LOG('FlutterFire Messaging Example: Got APNs token: $token');
          } else {
            LOG(
              'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.',
            );
          }
        }
        break;
      default:
        break;
    }
  }

  Future<String> createShareContentDynamicLink(String type, String targetId) async {
    var link = 'https://kspot001.jhfactory.com/share_content/?data=$type,$targetId';
    var androidParameters = '&apn=com.jhfactory.kspot001&amv=1';
    var iosParameters = '&ibi=com.jhfactory.kspot001&isi=1643924418&imv=1';
    var result = 'https://kspot001.page.link/?link=$link$androidParameters$iosParameters';
    return result;
  }

  Future<bool> sendPushMessageFromUser(String userId, String title, String desc, {JSON userData = const {}}) async {
    // send push..
    final userRepo = UserRepo();
    var targetUserInfo = await userRepo.getUserInfo(userId);
    if (targetUserInfo != null) {
      var pushToken = STR(targetUserInfo.pushToken);
      LOG('------> send push : ${targetUserInfo.nickName} => ${targetUserInfo.optionPush} / $pushToken');
      if (pushToken.isNotEmpty && (targetUserInfo.optionPush.isEmpty || BOL(targetUserInfo.optionPush['message_on']))) {
        try {
          return sendFcmData(
              pushToken,
              title,
              desc,
              userData
            // {
            //   'type': 'message', // link
            //   'data': userData.toString(),
            // }
          );
        } catch (e) {
          LOG('--> sendFcmData error : $e');
        }
      }
    }
    return false;
  }

  JSON firestoreCacheData = {};

  initCacheData() {
    firestoreCacheData['goodsData'] = {};
    firestoreCacheData['goodsLink'] = {};
    firestoreCacheData['simpleGoods'] = {};
    firestoreCacheData['historyComment'] = {};
    firestoreCacheData['goodsComment'] = {};
    firestoreCacheData['placeComment'] = {};
    firestoreCacheData['placeEventComment'] = {};
    firestoreCacheData['goodsQnA'] = {};
    firestoreCacheData['follow'] = {};
  }
}

Future<String?> uploadMP4(XFile? file, String targetPath, String targetFileName) async {
  return uploadFile(file, 'video/mp4', targetPath, targetFileName);
}

Future<String?> uploadJpeg(XFile? file, String targetPath, String targetFileName) async {
  return uploadFile(file, 'image/jpeg', targetPath, targetFileName);
}

Future<String?> uploadPNG(XFile? file, String targetPath, String targetFileName) async {
  return uploadFile(file, 'image/png', targetPath, targetFileName);
}

Future<String?> uploadFile(XFile? file, String type, String targetPath, String targetFileName) async {
  if (file == null) {
    LOG('--> No file was selected');
    return null;
  }
  LOG('--> uploadFile : ${file.path} / $type / $targetFileName');

  firebase_storage.UploadTask uploadTask;
  firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
      .ref()
      .child(targetPath)
      .child('/$targetFileName');

  final metadata = firebase_storage.SettableMetadata(
      contentType: type,
      customMetadata: {'picked-file-path': file.path});

  if (kIsWeb) {
    uploadTask = ref.putData(await file.readAsBytes(), metadata);
  } else {
    uploadTask = ref.putFile(File(file.path), metadata);
  }
  await Future.value(uploadTask);
  var snapshot = await uploadTask;
  if (snapshot.state == TaskState.success) {
    var resultUrl = await snapshot.ref.getDownloadURL();
    LOG('--> resultUrl : $resultUrl');
    return resultUrl;
  } else {
    return null;
  }
}

