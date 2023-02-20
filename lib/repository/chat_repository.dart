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

  getChatRoomData() async {
    Map<String, ChatRoomModel> result = {};
    final data = await api.getChatRoomData(AppData.USER_ID);
    for (var item in data.entries) {
      result[item.key] = ChatRoomModel.fromJson(item.value);
    }
    return result;
  }

  getChatRoomInfo() async {
    return await api.getChatRoomFromId(AppData.USER_ID);
  }

  getChatRoomStreamData() {
    return api.getChatRoomStreamData(AppData.USER_ID);
  }

  getChatStreamData() {
    return api.getChatStreamData(AppData.USER_ID);
  }

  startChatStreamData(String roomId, Function(JSON) onChanged) {
    if (stream != null) {
      stopChatStreamData();
    }
    stream = api.startChatStreamData(roomId, onChanged);
  }

  addChatItem(JSON addItem, List<JSON> targetList) async {
    return await api.addChatItem(addItem, targetList);
  }

  stopChatStreamData() {
    if (stream != null) {
      stream!.cancel();
    }
    stream = null;
  }

}