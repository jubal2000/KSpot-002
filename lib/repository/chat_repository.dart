import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/app_data.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class ChatRepository {
  final api = Get.find<ApiService>();
  StreamSubscription<QuerySnapshot>? stream;

  getChatData() async {
    Map<String, ChatModel> result = {};
    final data = await api.getMessageData(AppData.USER_ID);
    for (var item in data.entries) {
      result[item.key] = ChatModel.fromJson(item.value);
    }
    return result;
  }

  startChatStreamToMe() {
    return api.startChatStreamToMe(AppData.USER_ID);
  }

  startChatStreamData(String targetId, Function(JSON) onChanged) {
    if (stream != null) {
      stopChatStreamData();
    }
    stream = api.startMessageStream(AppData.USER_ID, targetId, onChanged);
  }

  stopChatStreamData() {
    if (stream != null) {
      stream!.cancel();
    }
    stream = null;
  }

}