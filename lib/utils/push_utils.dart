import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kspot_002/services/firebase_service.dart';
import 'package:kspot_002/utils/utils.dart';

import '../data/app_data.dart';

sendFcmTestData() {
  final firebase = Get.find<FirebaseService>();
  return sendFcmMessage(
    // firebase.token!,
    'c1eEei1fvUzZqS27nJsqon:APA91bGO3zX3N0uhkTdVaq7tdjJgtYhOuyBCZi0r1E0zlNHndLr_WF8w1BJKzqYbfNjiCTB4B-dHjS4iyTngC4B06SxPI7b2IRb5loOSqZ62iJ5YYkz6yy8dRCEObl0zDUz3OlVV9IMN',
    'KSpot', 'Test Push Message', data: {'id': 'test', 'name': 'KSpot name', 'desc': 'KSpot test desc'});
}

sendFcmMessage(String token, String title, String body, {JSON? data}) async {
  if (token.isEmpty) {
    LOG('--> sendFcmData error : Unable to send FCM message, no token exists.');
    return false;
  }
  final fire = Get.find<FirebaseService>();
  if (fire.accessToken == null || fire.accessTokenTime == null || fire.accessTokenTime!.isBefore(DateTime.now())) {
    var accessResult = await http.get(Uri.parse('http://kspot002.cafe24app.com/fcm_token'));
    var accessJson = jsonDecode(accessResult.body);
    for (var item in accessJson['response'].entries) {
      LOG('--> json key [${item.key}] : ${item.value}');
    }
    fire.accessToken = STR(accessJson['response']['access_token']);
    fire.accessTokenTime = DateTime.fromMillisecondsSinceEpoch(INT(accessJson['response']['expiry_date']));
    LOG('--> accessToken refresh : ${accessJson.toString()}');
  }
  LOG('--> accessToken : ${fire.accessTokenTime} / ${DateTime.now()}');

  try {
    var bodyData = {
      "message": {
        "token" : token,
        "notification": {
          "title": title,
          "body": body
        },
        "data": data,
        // "android": {
        //   "notification": {
        //     "click_action": "TOP_STORY_ACTIVITY",
        //   }
        // },
        // "apns": {
        //   "payload": {
        //     "aps": {
        //       "category" : "NEW_MESSAGE_CATEGORY"
        //     }
        //   }
        // }
      }
    };
    LOG('-------------> sendFcmData bodyData : $bodyData');
    http.Response response = await http.post(Uri.parse('https://fcm.googleapis.com/v1/projects/kspot-002/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${fire.accessToken}',
      },
      body: jsonEncode(bodyData));
    LOG("--> sendFcmData result : ${response.statusCode} | ${response.body}");
    return INT(response.statusCode) == 200;
  } catch (e) {
    LOG('--> sendFcmData error : $e');
  }
  return false;
}

