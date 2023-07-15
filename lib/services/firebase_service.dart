
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
import 'package:kspot_002/data/dialogs.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:uuid/uuid.dart';
import '../data/app_data.dart';
import '../data/firebase_options.dart';
import '../data/routes.dart';
import '../models/user_model.dart';
import '../utils/message.dart';
import '../utils/push_utils.dart';
import '../utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_service.dart';
import 'cache_service.dart';

class FirebaseService extends GetxService {
  Future<FirebaseService> init() async {
    await initService();
    return this;
  }

  FirebaseFirestore? firestore;
  FirebaseAuth? fireAuth;
  FirebaseMessaging? messaging;
  PendingDynamicLinkData? initialLink;

  String? token;
  String? recommendCode;
  bool initLink = false;
  bool isInit = false;

  String? accessToken;
  DateTime? accessTokenTime;

  final userRepo = UserRepository();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool isFlutterLocalNotificationsInitialized = false;

  late AndroidNotificationChannel channel;

  AndroidNotificationChannel FCM_TopicChannel = AndroidNotificationChannel(
    'alert_channel_00', // id
    'Alert Notifications', // title
    description: 'This channel is used for alert notifications.', // description
    importance: Importance.max,
  );

  initService() async {
    if (isInit) return;
    isInit = true;

    final result = await Firebase.initializeApp();
    LOG('--> initService: ${result.toString()}');

    firestore = FirebaseFirestore.instance;
    fireAuth = FirebaseAuth.instance;
    messaging = FirebaseMessaging.instance;

    // get firebase token..
    token = await messaging!.getToken();
    LOG('--> firebase init token : $token');

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

    await setupFlutterNotifications();
    initPush();

    // dynamic link ready..
    initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialLink != null) {
        deepLinkProcess(Get.context!, initialLink);
      }
      // when app running..
      FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
        deepLinkProcess(Get.context!, dynamicLinkData);
      }).onError((error) {
        // Handle errors
        LOG('--> dynamicLinkData.link error : $error');
      });
    });

    if (AppData.isDevMode) {
      FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
          forceRecaptchaFlow: true
      );
    }
    // if (!initLink) {
    //   LOG('--> initDataLink');
    //   initLink = true;
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     initPush();
    //     initDeepLink();
    //   });
    // }
    // this.subscribeTopic();
  }

  void showReceiveLocalNotificationDialog(String title, String body) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) =>
          CupertinoAlertDialog(
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

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await setupFlutterNotifications();
    showFlutterNotification(message);
    LOG('--> Handling a background message ${message.messageId}');
  }

  initPush() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LOG('--> FirebaseMessaging.onMessage : ${message.toMap().toString()}');
      showPush(message, false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LOG('--> FirebaseMessaging.onMessageOpenedApp.listen : ${message.toString()}');
      RemoteNotification?  notification = message.notification;
      // AndroidNotification? android = message.notification?.android;
      if (notification != null) {
        var customData = message.data;
        if (customData != null) {
          LOG('--> customData : ${customData.toString()}');
          var action = STR(customData['action']);
          switch (action) {
            case 'inviteRoom':
              var targetId = STR(customData['id']);
              LOG('--> touch push [invite] : $targetId');
              break;
          }
        }
      }

      // if (notification != null && android != null) {
      //   flutterLocalNotificationsPlugin.show(
      //     notification.hashCode,
      //     notification.title,
      //     notification.body,
      //     NotificationDetails(
      //       android: AndroidNotificationDetails(
      //         FCM_TopicChannel.id,
      //         FCM_TopicChannel.name,
      //         icon: android.smallIcon,
      //         // other properties...
      //       ),
      //     )
      //   );
      // }
      // Navigator.pushNamed(
      //   Get.context!,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(FCM_TopicChannel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    }
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

  showPush(RemoteMessage message, bool isBackground) {
    final cache = Get.find<CacheService>();
    RemoteNotification? notification = message.notification;
    if (notification != null && !kIsWeb) {
      var isShowPush = true;
      var title = STR(notification.title);
      var desc  = STR(notification.body);
      var customData = message.data;
      if (customData != null) {
        final action = STR(customData['action']);
        final targetId = STR(customData['id']);
        LOG('--> showPush customData : ${customData.toString()}');
        switch (action) {
          case 'invite_room':
            LOG('--> showPush [invite_room] : $targetId => $isShowPush');
            break;
          case 'chat_message':
            final targetId = STR(customData['id']);
            isShowPush = cache.getChatRoomAlarmOn(targetId);
            LOG('--> showPush [chat_message] : $targetId => $isShowPush');
            break;
          case 'comment':
          // isShowPush = AppData.userInfo!.optionPush.isEmpty || BOL(AppData.userInfo!.optionPush['comment_on']);
            break;
        }
      }

      if (Platform.isAndroid && isShowPush) {
        // showReceiveLocalNotificationDialog(title, desc);
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          title,
          desc,
          NotificationDetails(
              android: AndroidNotificationDetails(
                FCM_TopicChannel.id,
                FCM_TopicChannel.name,
                channelDescription: FCM_TopicChannel.description,
                icon: '@mipmap/ic_launcher',
                ongoing: true,
                largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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
}

Future<String> createShareContentDynamicLink(String type, String targetId) async {
  var link = 'https://kspot001.jhfactory.com/share_content/?data=$type,$targetId';
  var androidParameters = '&apn=com.jhfactory.kspot001&amv=1';
  var iosParameters = '&ibi=com.jhfactory.kspot001&isi=1643924418&imv=1';
  var result = 'https://kspot001.page.link/?link=$link$androidParameters$iosParameters';
  return result;
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


