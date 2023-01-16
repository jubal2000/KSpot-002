import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kspot_002/utils/utils.dart';


sendFcmData(String targetToken, String title, String desc, JSON data) async {
  try {
    var bodyData = {
      // 'target'  : AppData.testToken, // for Dev..
      'target'  : targetToken,
      'title'   : title,
      'desc'    : desc,
      'data'    : data,
    };
    LOG('-------------> sendFcmData bodyData : $bodyData / $targetToken');
    var result = await http.post(
      // Uri.parse('https://www.langscoffeework.com/oman/push.php?target=$target&title=$title&desc=$desc'),
      Uri.parse('https://www.langscoffeework.com/oman/push.php'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(bodyData),
    );
    LOG('--> sendFcmData result : ${result.statusCode}');
    // ShowToast('${result.statusCode} / ${result.body}', Colors.blueAccent); // for Test..
    return true;
  } catch (e) {
    LOG('--> sendFcmData error : $e');
  }
  return false;
}