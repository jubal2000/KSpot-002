import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class MessageRepository {
  final api = Get.find<ApiService>();
  StreamSubscription<QuerySnapshot>? stream;

  getMessageData() {
    return api.getMessageData(AppData.USER_ID);
  }

  startMessageStreamToMe() {
    return api.startMessageStreamToMe(AppData.USER_ID);
  }

  startMessageStreamData(String targetId, Function(JSON) onChanged) {
    if (stream != null) {
      stopMessageStreamData();
    }
    stream = api.startMessageStream(AppData.USER_ID, targetId, onChanged);
  }

  stopMessageStreamData() {
    if (stream != null) {
      stream!.cancel();
    }
    stream = null;
  }

}