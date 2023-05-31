import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kspot_002/utils/utils.dart';

sendFcmTestData() {
  return sendFcmData(
    'dMclWMkzTayOBZ0NG5QgIy:APA91bEy9N1FaSsCxQr3z6fhp5BhpisIab6ZvoAh8c1NBdwEs5BHiGqa3LMkWio-FhkbB3fq529lFt2kg2kW1SdQOl6xfTBNFTEQzUMOIaIA4roXaoRqfqiCCeRRe2Ro6TfrQewBbaYi',
    'KSpot', 'Test Push Message', {'id': 'test', 'title': 'title', 'message': 'message'});
}

sendFcmData(String token, String title, String desc, JSON data) async {
  try {
    var bodyData = {
      'notification': <String, dynamic>{
        'body':  desc,
        'title': title,
      },
      'data': data,
      'to': token
    };
    LOG('-------------> sendFcmData bodyData : $bodyData');
    if (token.isEmpty) {
      LOG('--> sendFcmData : Unable to send FCM message, no token exists.');
      return false;
    }

    try {
      //Send  Message
      http.Response response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=BBC7AG0ikKyRoE9BLjkK4FVYp80odw1S8zZqQP6Mu0Yu6iD7IbbDODPc2ZKxNYrw1wcSku6r2oamo8bT2wELlBs',
          },
          body: jsonEncode(bodyData));
      LOG("--> sendFcmData result : ${response.statusCode} | Message Sent Successfully!");
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

