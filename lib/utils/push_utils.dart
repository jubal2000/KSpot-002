import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kspot_002/services/firebase_service.dart';
import 'package:kspot_002/utils/utils.dart';

import '../data/app_data.dart';

sendMultiFcmMessage(JSON data) async {
  LOG('--> sendMultiFcmMessage : ${data.toString()}');
  if (data.isEmpty) {
    LOG('--> sendMultiFcmMessage error : Unable to send FCM message, no token exists.');
    return null;
  }
  try {
    http.Response response = await http.post(Uri.parse('http://kspot002.cafe24app.com/multi_fcm_send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data));
    LOG("--> sendMultiFcmMessage result : ${response.statusCode} | ${response.body}");
    return response;
  } catch (e) {
    LOG('--> sendMultiFcmMessage error : $e');
  }
  return null;
}

sendFcmMessage(String token, String title, String body, {JSON? data}) async {
  if (token.isEmpty) {
    LOG('--> sendFcmData error : Unable to send FCM message, no token exists.');
    return false;
  }
  final fire = Get.find<FirebaseService>();
  try {
    await refreshAccessToken();
    LOG('--> accessToken : ${fire.accessTokenTime} / ${DateTime.now()}');
    var bodyData = {
      "message": {
        "token" : token,
        "notification": {
          "title": title,
          "body": body
        },
        "data": data,
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

refreshAccessToken() async {
  final fire = Get.find<FirebaseService>();
  if (fire.accessToken == null || fire.accessTokenTime == null || fire.accessTokenTime!.isBefore(DateTime.now())) {
    var accessResult = await http.get(Uri.parse('http://kspot002.cafe24app.com/access_token'));
    LOG('--> accessToken : ${accessResult.body}');
    var accessJson = jsonDecode(accessResult.body);
    fire.accessToken = STR(accessJson['response']['access_token']);
    fire.accessTokenTime = DateTime.fromMillisecondsSinceEpoch(INT(accessJson['response']['expiry_date']));
  }
}

sendFcmTestData() {
  return sendFcmMessage(
    // firebase.token!,
      'c1eEei1fvUzZqS27nJsqon:APA91bGO3zX3N0uhkTdVaq7tdjJgtYhOuyBCZi0r1E0zlNHndLr_WF8w1BJKzqYbfNjiCTB4B-dHjS4iyTngC4B06SxPI7b2IRb5loOSqZ62iJ5YYkz6yy8dRCEObl0zDUz3OlVV9IMN',
      'KSpot', 'Test Push Message', data: {'id': 'test', 'name': 'KSpot name', 'desc': 'KSpot test desc'});
}

sendMultiFcmTestData() {
  var bodyData = {
    "notification": {
      "title": "FCM Title",
      "body": "Multi Message"
    },
    "android": {
      "notification": {
        "imageUrl": "http://webhard.win4net.com/file_server/sw_release/100.Mobile/push/logo_01_00.png"
      }
    },
    "data": {
      "type": "invite",
      "targetId": "user001"
    },
    "tokens": [
      "c1eEei1fvUzZqS27nJsqon:APA91bGO3zX3N0uhkTdVaq7tdjJgtYhOuyBCZi0r1E0zlNHndLr_WF8w1BJKzqYbfNjiCTB4B-dHjS4iyTngC4B06SxPI7b2IRb5loOSqZ62iJ5YYkz6yy8dRCEObl0zDUz3OlVV9IMN",
      "fIyUblYuT9qTP9CR-wzQwC:APA91bG4PFZ46rv1H7NygOJYPfr506uQI_OoDxzDlXYXt33Ao137CJjGyMlk5dsoEJ8x8wKcC2c9RR1AZf65msRwMTEI-dQnyHWiAYMPFIcirLXbHNnku05VVIkowZkpPdSQ7ponakJy"
    ]
  };
  return sendMultiFcmMessage(
      bodyData
  );
}

