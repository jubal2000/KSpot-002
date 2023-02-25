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

  getChatRoomInfo(roomId) async {
    return await api.getChatRoomFromId(roomId);
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

  createChatItem(ChatRoomModel roomInfo, String sendText, [JSON? imageData]) async {
    var addItem = {
      'id':         '',
      'status':     1,
      'roomId':     roomInfo.id,
      'senderId':   STR(AppData.USER_ID),
      'senderName': STR(AppData.USER_NICKNAME),
      'senderPic':  STR(AppData.USER_PIC),
      'desc':       sendText,
      'memberList': roomInfo.memberList,
      'createTime': CURRENT_SERVER_TIME(),
    };
    if (imageData != null) {
      var upCount = 0;
      for (var item in imageData.entries) {
        var result = await api.uploadImageData(item.value as JSON, 'chat_img');
        if (result != null) {
          addItem['picData'] ??= [];
          addItem['picData'].add(result);
          upCount++;
        }
      }
      LOG('--> upload image result : $upCount / ${addItem['picData']}');
      upCount = 0;
      for (var item in imageData.entries) {
        var result = await api.uploadImageData(
            {'id': item.key, 'data': item.value['thumb']}, 'chat_img_p');
        if (result != null) {
          addItem['thumbData'] ??= [];
          addItem['thumbData'].add(result);
          upCount++;
        }
      }
      LOG('--> upload thumb result : $upCount / ${addItem['thumbData']}');
    }
    List<JSON> targetUser = [];
    for (var item in roomInfo.memberData) {
      if (item.id != AppData.USER_ID) {
        targetUser.add(item.toJson());
      }
    }
    LOG('--> createChatItem : ${targetUser.length} / ${addItem.toString()}');
    return await addChatItem(addItem, targetUser);
  }

  addChatItem(JSON addItem, List<JSON> targetUser) async {
    return await api.addChatItem(addItem, targetUser);
  }

  addRoomItem(ChatRoomModel room) async {
    return await api.addRoomItem(room.toJson());
  }

  Future<String?> uploadImageInfo(JSON imageInfo, [String path = 'chat_room_img']) async {
    return await api.uploadImageData(imageInfo, path);
  }

  stopChatStreamData() {
    if (stream != null) {
      stream!.cancel();
    }
    stream = null;
  }
}