
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/firebase_options.dart';
import '../utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService extends GetxService {
  Future<FirebaseService> init() async {
    await initFirebase();
    return this;
  }

  FirebaseStorage?  firesStorage;
  FirebaseFirestore? firestore;
  FirebaseFunctions? firefunctions;
  FirebaseMessaging? firemessaging;

  String? token;
  String? recommendCode;
  // BuildContext? buildContext;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'alert_channel_00', // id
    'Alert Notifications', // title
    description: 'This channel is used for alert notifications.', // description
    importance: Importance.max,
  );

  Future<void> initFirebase() async {
    await Firebase.initializeApp();
    // if (defaultTargetPlatform == TargetPlatform.android) {
    //   await Firebase.initializeApp(
    //       options: DefaultFirebaseOptions.currentPlatform
    //   );
    // } else {
    //   await Firebase.initializeApp(
    //       name: 'KSpot_02',
    //       options: DefaultFirebaseOptions.currentPlatform
    //   );
    // }

    firesStorage = FirebaseStorage.instance;
    firestore = FirebaseFirestore.instance;
    LOG('--> firestore ready : $firestore');

    // initDynamicLinks();
    // firefunctions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
    // firemessaging = FirebaseMessaging.instance;
    // token = await firemessaging!.getToken();
    // print('--> firebase init token : ${token}');

    // await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channel);

    // await firemessaging!.requestPermission(
    //       alert: true,
    //       announcement: false,
    //       badge: true,
    //       carPlay: false,
    //       criticalAlert: false,
    //       provisional: false,
    //       sound: true,
    //     );
    // //iOS foreground 알림표시
    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //   alert: true, // Required to display a heads up notification
    //   badge: true,
    //   sound: true,
    // );
    // FirebaseMessaging.onMessage.listen(onMessageListener);
    // FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppListener);
    // subscribeTopic();
  }

  void onMessageListener(RemoteMessage message) {
    LOG('Got a message whilst in the foreground!');
    LOG('Message data: ${message.data}');

    if (message.notification != null) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        final hashCode  = notification.hashCode;
        final title     = notification.title ?? "";
        final body      = notification.body ?? "";
        LOG('notification hashCode : $hashCode');
        LOG('notification title : $title');
        LOG('notification body : $body');

        flutterLocalNotificationsPlugin.show(
          hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              // other properties...
            ),
          )
        );
      }
    }
  }

  void onMessageOpenedAppListener(event) {
  }

  void subscribeTopic() {
    final appData = GetStorage();
    final notice = appData.read('notice') ?? true;
    if (notice) {
      firemessaging!.subscribeToTopic('All');
    } else {
      firemessaging!.unsubscribeFromTopic('All');
    }
  }

  Future<String> getDynamicLinkUrlString(String memberCode) async {
    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   uriPrefix: 'https://link.sketchwallet.io',
    //   link: Uri.parse('https://link.sketchwallet.io/link/?rc=$memberCode'),
    //   androidParameters: AndroidParameters(
    //     packageName: 'com.sketch.wallet',
    //     // minimumVersion: 125,
    //   ),
    //   iosParameters: IosParameters(
    //     bundleId: 'com.sketch-wallet.ios',
    //     appStoreId: '1597866658',
    //     // minimumVersion: '1.0.0',
    //   ),
    // );
    //
    // final shortLink = await parameters.buildShortLink();
    // return shortLink.shortUrl.toString();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://link.sketchwallet.io',
      link: Uri.parse('https://link.sketchwallet.io/link/?rc=$memberCode'),
      androidParameters: AndroidParameters(
        packageName: 'com.sketch.wallet',
        // minimumVersion: 125,
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.sketch-wallet.ios',
        appStoreId: '1597866658',
        // minimumVersion: '1.0.0',
      ),
    );

    final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return dynamicLink.shortUrl.toString();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      print('--> dynamicLinkData.link data : $dynamicLinkData');
      recommendCode = dynamicLinkData.link.queryParameters['rc'] ?? '';
    }).onError((error) {
      print('--> dynamicLinkData.link error : $error');
    });

    // FirebaseDynamicLinks.instance.onLink(
    //     onSuccess: onLinkSuccessListener,
    //     onError: (OnLinkErrorException e) async {
    //       print('onLinkError');
    //       print(e.message);
    //     });

    // start 앱스토어를 통해 설치해서 온경우 수신??
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      recommendCode = deepLink.queryParameters['rc'];
      print(
          "deepLink.queryParameters['rc']: ${deepLink.queryParameters['rc']}");
    }
    // end
  }

  Future<dynamic> onLinkSuccessListener(
      PendingDynamicLinkData? dynamicLink) async {
    final Uri? deepLink = dynamicLink?.link;
    if (deepLink != null) {
      recommendCode = deepLink.queryParameters['rc'];
      print(
          "deepLink.queryParameters['rc']: ${deepLink.queryParameters['rc']}");
    }
  }

  void showReceiveLocalNotificationDialog(
      BuildContext context, int id, String title, String body, String payload) async {
    var showIcon = '';
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Row(
          children: [
            if (showIcon.isNotEmpty)
            Image(image: AssetImage(showIcon), width: 32, height: 32, fit: BoxFit.fitHeight),
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

//----------------------------------------------------------------------------------------
//
//    upload file..
//

  Future? uploadImageData(JSON imageInfo, String path) async {
    if (imageInfo['image'] != null) {
      try {
        final ref = firesStorage!.ref().child('$path/${imageInfo['id']}');
        var uploadTask = ref.putData(imageInfo['image']);
        var snapshot = await uploadTask;
        if (snapshot.state == TaskState.success) {
          var imageUrl = await snapshot.ref.getDownloadURL();
          LOG('--> uploadImageData done : $imageUrl');
          return imageUrl;
        } else {
          return null;
        }
      } catch (e) {
        LOG('--> uploadImageData error : $e');
      }
    }
    return null;
  }
}
