import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/dialogs.dart';
import 'package:kspot_002/models/upload_model.dart';

import '../data/app_data.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';

class ChatRepository {
  final api   = Get.find<ApiService>();
  final cache = Get.find<CacheService>();
  StreamSubscription<QuerySnapshot>? stream;
  List<String> chatRoomIndexList = [];

  getChatRoomData() async {
    Map<String, ChatRoomModel> result = {};
    final openData = await api.getChatOpenRoomData(AppData.USER_ID,
        AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
    for (var item in openData.entries) {
      result[item.key] = ChatRoomModel.fromJson(item.value);
    }
    final closeData = await api.getChatCloseRoomData(AppData.USER_ID);
    for (var item in closeData.entries) {
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

  startChatStreamData(String roomId, DateTime? startTime, Function(JSON) onChanged) {
    if (stream != null) {
      stopChatStreamData();
    }
    stream = api.startChatStreamData(roomId, startTime, onChanged);
  }

  createChatItem(ChatRoomModel roomInfo, String sendText, [Map<String, UploadFileModel>? fileData]) async {
    var addItem = {
      'id':         '',
      'status':     1,
      'action':     0,
      'roomId':     roomInfo.id,
      'senderId':   STR(AppData.USER_ID),
      'senderName': STR(AppData.USER_NICKNAME),
      'senderPic':  STR(AppData.USER_PIC),
      'desc':       sendText,
      'createTime': CURRENT_SERVER_TIME(),
    };
    if (fileData != null && fileData.isNotEmpty) {
      var upCount = 0;
      for (var item in fileData.entries) {
        LOG('--> fileData item : ${item.value.toJson()}');
        if (item.value.data != null) {
          var result = await api.uploadData(item.value.data, item.key, 'chat_img');
          if (result != null && item.value.thumbData != null) {
            var thumbResult = await api.uploadData(item.value.thumbData, item.key, 'chat_img_thumb');
            if (thumbResult != null) {
              addItem['thumbList'] ??= [];
              addItem['thumbList'].add(thumbResult);
            }
            item.value.url = result;
            item.value.thumb = thumbResult;
            upCount++;
          }
        } else {
          var result = await api.uploadFile(File.fromUri(Uri.parse(item.value.path!)), 'chat_file', item.key);
          if (result != null) {
            item.value.url = result;
            upCount++;
          }
        }
        var upItem = item.value.toJson();
        addItem['fileData'] ??= [];
        addItem['fileData'].add(upItem);
      }
      LOG('--> upload image result : $upCount');
    }
    LOG('--> createChatItem : ${addItem.toString()}');
    return await addChatItem(addItem);
  }

  addChatItem(JSON addItem) async {
    return await api.addChatItem(addItem);
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

  enterChatRoom(String roomId, bool isEnterShow) async {
    final result = await api.enterChatRoom(roomId, AppData.userInfo.toJson());
    if (result != null && JSON_EMPTY(result['error'])) {
      JSON addItem = {
        'id': '',
        'status': 1,
        'action': isEnterShow ? 1 : -1,
        'desc': '${AppData.USER_NICKNAME} enter',
        'roomId': roomId,
        'senderId': AppData.USER_ID,
        'senderName': AppData.USER_NICKNAME,
        'senderPic': AppData.USER_PIC,
      };
      api.addChatItem(addItem);
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
    return result;
  }

  exitChatRoom(String roomId, bool isExitShow) async {
    final result = await api.exitChatRoom(roomId, AppData.USER_ID);
    if (result != null && JSON_EMPTY(result['error'])) {
      JSON addItem = {
        'id': '',
        'status': 1,
        'action': isExitShow ? 2 : -2,
        'desc': '${AppData.USER_NICKNAME} leave',
        'roomId': roomId,
        'senderId': AppData.USER_ID,
        'senderName': AppData.USER_NICKNAME,
        'senderPic': AppData.USER_PIC,
      };
      api.addChatItem(addItem);
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
    return result;
  }
}