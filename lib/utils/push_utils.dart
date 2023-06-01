import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kspot_002/services/firebase_service.dart';
import 'package:kspot_002/utils/utils.dart';

import '../data/app_data.dart';

sendFcmTestData() {
  final firebase = Get.find<FirebaseService>();
  return sendFcmData(
    firebase.token!,
    'KSpot', 'Test Push Message', {'id': 'test', 'title': 'KSpot test', 'message': 'KSpot test message'});
}

sendFcmData(String token, String title, String desc, JSON data) async {
  if (token.isEmpty) {
    LOG('--> sendFcmData error : Unable to send FCM message, no token exists.');
    return false;
  }
  try {
    var bodyData = {
      "message": {
        "token" : token,
        // "topic": "news",
        "notification": {
          "title": "Breaking News",
          "body": "New news story available."
        },
        "data": {
          "story_id": "story_12345"
        },
        "android": {
          "notification": {
            "click_action": "TOP_STORY_ACTIVITY",
            "body": "Check out the Top Story"
          }
        },
        "apns": {
          "payload": {
            "aps": {
              "category" : "NEW_MESSAGE_CATEGORY"
            }
          }
        }
      }
      // 'notification': <String, dynamic>{
      //   'body':  desc,
      //   'title': title,
      // },
      // 'data': data,
      // 'to': token
    };
    LOG('-------------> sendFcmData bodyData : $bodyData');
    try {
      //Send  Message
      http.Response response = await http.post(Uri.parse('https://fcm.googleapis.com/v1/projects/kspot-002/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ya29.a0AWY7CkkQJHsblzyzqjZcE1wh_1l0LamGxIkILSLMwv6z5Ffw_g1JmSlxJSdcNCLNJMiEMd_mVDmA61X9Hs9RBX82pW78R3WQXNea-muYr7ozWdDeMS91fx13fswaXaKZ6nhFctL6kc3jdAem90DF6Xg2dMNbaCgYKAWESARESFQG1tDrpnhdxwwg50aDGpT7bvuvUKQ0163',
        },
        body: jsonEncode(bodyData));
      LOG("--> sendFcmData result : ${response.statusCode} | ${response.body}");
    } catch (e) {
      LOG("--> error push notification : $e");
    }

    // var result = await http.post(
    //   // Uri.parse('https://www.langscoffeework.com/oman/push.php?target=$target&title=$title&desc=$desc'),
    //   Uri.parse('https://www.push.com/oman/push.php'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(bodyData),
    // );
    // LOG('--> sendFcmData result : ${result.statusCode}');
    // // ShowToast('${result.statusCode} / ${result.body}', Colors.blueAccent); // for Test..
    return true;
  } catch (e) {
    LOG('--> sendFcmData error : $e');
  }
  return false;
}

