import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/dialogs.dart';
import 'package:kspot_002/models/upload_model.dart';

import '../data/app_data.dart';
import '../models/chat_model.dart';
import '../models/etc_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';

class ChatActionType {
  static int get hide   => -1;
  static int get normal => 0;
  static int get enter  => 1;
  static int get exit   => 2;
  static int get admin  => 3;
  static int get kick   => 4;
  static int get title  => 5;
  static int get notice => 6;
  static int get delete => -7;
}

class ChatRepository {
  final api   = Get.find<ApiService>();
  final cache = Get.find<CacheService>();
  StreamSubscription<QuerySnapshot>? stream;
  List<String> chatRoomIndexList = [];

  getChatRoomData() async {
    Map<String, ChatRoomModel> result = {};
    try {
      final openData = await api.getChatOpenRoomData(AppData.USER_ID,
          AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
      for (var item in openData.entries) {
        result[item.key] = ChatRoomModel.fromJson(item.value);
      }
      final closeData = await api.getChatCloseRoomData(AppData.USER_ID);
      for (var item in closeData.entries) {
        result[item.key] = ChatRoomModel.fromJson(item.value);
      }
      LOG('--> getChatRoomData done : ${result.length}');
    } catch (e) {
      LOG('--> getChatRoomData error : $e');
    }
    return result;
  }

  getChatRoomInfo(roomId) async {
    return await api.getChatRoomFromId(roomId);
  }

  getChatInviteStreamData() {
    return api.getChatInviteStreamData(AppData.USER_ID);
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

  createChatItem(ChatRoomModel roomInfo, String id, String sendText, bool isFirstMessage,
    [int status = 1, int action = 0, Map<String, UploadFileModel>? fileData]) async {
    var addItem = {
      'id':         id,
      'status':     status,
      'action':     action,
      'roomId':     roomInfo.id,
      'senderId':   STR(AppData.USER_ID),
      'senderName': STR(AppData.USER_NICKNAME),
      'senderPic':  STR(AppData.USER_PIC),
      'desc':       sendText,
      'createTime': CURRENT_SERVER_TIME(),
    };
    if (fileData != null && fileData.isNotEmpty) {
      for (var item in fileData.entries) {
        // LOG('--> fileData item : ${item.value.toJson()}');
        if (item.value.data != null) {
          var result = await api.uploadData(item.value.data, item.key, 'chat_img');
          if (result != null && item.value.thumbData != null) {
            var thumbResult = await api.uploadData(item.value.thumbData, item.key, 'chat_img_thumb');
            if (thumbResult != null) {
              item.value.url = result;
              item.value.thumb = thumbResult;
            }
          }
        } else {
          var result = await api.uploadFile(File.fromUri(Uri.parse(item.value.path!)), 'chat_file', item.key);
          if (result != null) {
            item.value.url = result;
          }
        }
        var upItem = item.value.toJson();
        addItem['fileData'] ??= [];
        addItem['fileData'].add(upItem);
      }
    }
    LOG('--> createChatItem : $isFirstMessage / ${addItem.toString()}');
    var result = await addChatItem(addItem, isFirstMessage);
    return result;
  }

  addChatItem(JSON addItem, [var isFirstMessage = false]) async {
    return await api.addChatItem(addItem, isFirstMessage);
  }

  setChatItemState(String roomId, String chatId, int status) async {
    var result = await api.setChatInfo(chatId, {'status': status});
    if (result) {
      addChatActionItem(roomId, ChatActionType.delete, 'deleted chat item', chatId: chatId);
    }
  }

  addChatRoomItem(ChatRoomModel room) async {
    return await api.addChatRoomItem(room.toJson());
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

  addChatActionItem(String roomId, int action, String desc, {String? chatId, String? userId, String? userName, String? userPic, String? roomPic}) {
    JSON addItem = {
      'id': '',
      'status'    : 1,
      'action'    : action,
      'desc'      : desc,
      'roomId'    : roomId,
      'roomPic'   : roomPic ?? '',
      'chatId'    : chatId ?? '',
      'senderId'  : userId ?? AppData.USER_ID,
      'senderName': userName ?? AppData.USER_NICKNAME,
      'senderPic' : userPic ?? AppData.USER_PIC,
    };
    api.addChatItem(addItem);
  }

  setChatRoomAdmin(String roomId, String targetId, String targetName) async {
    var result = await api.setChatRoomAdmin(roomId, targetId, AppData.USER_ID);
    if (result != null) {
      addChatActionItem(roomId, ChatActionType.admin, '$targetName change admin',
        userId: targetId, userName: targetName, userPic: '');
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
    return result;
  }

  setChatRoomTitle(String roomId, String title, [JSON? imageInfo]) async {
    String? imageURL;
    if (JSON_NOT_EMPTY(imageInfo)) {
      var result = await uploadImageInfo(imageInfo!);
      if (result != null) {
        imageURL = result;
      }
    }
    var result = await api.setChatRoomTitle(roomId, title, AppData.USER_ID, imageURL);
    if (result != null) {
      addChatActionItem(roomId, ChatActionType.title, title, roomPic: imageURL);
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
    return result;
  }

  setChatRoomNotice(String roomId, NoticeModel notice, [bool isFirst = false]) async {
    var result = await api.setChatRoomNotice(roomId, notice.toJson(), AppData.USER_ID, isFirst);
    if (result != null) {
      addChatActionItem(roomId, ChatActionType.notice, notice.desc);
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
    return result;
  }

  setChatRoomKickUser(String roomId, String targetId, String targetName, [int status = 0]) async {
    var result = await api.setChatRoomKickUser(roomId, targetId, targetName, status, AppData.USER_ID);
    if (result != null) {
      if (status == 0) {
        addChatActionItem(
            roomId, ChatActionType.kick, '$targetName has kicked', userId: targetId, userName: targetName, userPic: '');
      }
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
    return result;
  }

  enterChatRoom(String roomId, bool isEnterShow) async {
    final result = await api.enterChatRoom(roomId, AppData.userInfo.toJson());
    if (result != null && JSON_EMPTY(result['error'])) {
      addChatActionItem(roomId, isEnterShow ? ChatActionType.enter : -1, '${AppData.USER_NICKNAME} enter');
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
    return result;
  }

  exitChatRoom(String roomId, bool isExitShow) async {
    final result = await api.exitChatRoom(roomId, AppData.USER_ID);
    if (result != null && JSON_EMPTY(result['error'])) {
      addChatActionItem(roomId, isExitShow ? ChatActionType.exit : -2, '${AppData.USER_NICKNAME} leave');
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
    return result;
  }
}