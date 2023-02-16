import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/message_model.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class MessageRepository {
  final api = Get.find<ApiService>();
  StreamSubscription<QuerySnapshot>? stream;

  getMessageData() async {
    Map<String, MessageModel> result = {};
    final data = await api.getMessageData(AppData.USER_ID);
    for (var item in data.entries) {
      result[item.key] = MessageModel.fromJson(item.value);
    }
    return result;
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