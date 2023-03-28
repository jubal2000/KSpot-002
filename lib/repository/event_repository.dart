import 'dart:collection';

import 'package:get/get.dart';
import 'package:kspot_002/models/etc_model.dart';
import 'package:kspot_002/services/api_service.dart';
import 'package:kspot_002/services/cache_service.dart';

import '../data/app_data.dart';
import '../models/event_model.dart';
import '../models/story_model.dart';
import '../utils/utils.dart';
import '../models/user_model.dart';

class EventRepository {
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();

  // ignore: non_constant_identifier_names
  Map<String, EventModel> INDEX_SORT_ASC(Map<String, EventModel> data) {
    // LOG("--> JSON_INDEX_SORT_ASCE : $data");
    if (JSON_EMPTY(data)) return Map<String, EventModel>.from({});
    if (data.length < 2) return data;
    return Map<String, EventModel>.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
      // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
      return data[a]!.sortIndex > data[b]!.sortIndex ? 1 : -1;
    }));
  }

  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<Map<String, EventModel>> getEventListFromCountry(String groupId, String country, [String countryState = '']) async {
    Map<String, EventModel> result = {};
    try {
      final response = await api.getEventListFromCountry(groupId, country, countryState);
      for (var item in response.entries) {
        LOG('--> getEventListFromCountry item : ${item.value}');
        result[item.key] = EventModel.fromJson(item.value);
      }
    } catch (e) {
      LOG('--> getEventListFromCountry error [$groupId] : $e');
    }
    return result;
  }

  Future<EventModel?> getEventFromId(String eventId) async {
    try {
      if (JSON_NOT_EMPTY(cache.eventData!) && cache.eventData!.containsKey(eventId)) return cache.eventData![eventId];
      final response = await api.getEventFromId(eventId);
      if (response != null) {
        final eventData = EventModel.fromJson(FROM_SERVER_DATA(response));
        LOG("--> getEventFromId result: ${eventData.toJson()}");
        AppData.eventData[eventData.id] = eventData;
        return eventData;
      }
    } catch (e) {
      LOG('--> getEventFromId error [$eventId] : $e');
    }
    return null;
  }

  Future<EventModel?> addEventItem(EventModel addItem) async {
    try {
      final response = await api.addEventItem(addItem.toJson());
      if (response != null) {
        final eventData = EventModel.fromJson(FROM_SERVER_DATA(response));
        LOG("--> addEventItem result: ${eventData.toJson()}");
        AppData.eventData[eventData.id] = eventData;
        return eventData;
      }
    } catch (e) {
      LOG('--> addEventItem error : $e');
    }
    return null;
  }

  Future<bool> setEventStatus(String eventId, int status) async {
    return await api.setEventStatus(eventId, status);
  }

  Future<bool> setEventShowStatus(String eventId, int status) async {
    return await api.setEventShowStatus(eventId, status);
  }

  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<String?> uploadImageInfo(JSON imageInfo, [String path = 'event_img']) async {
    return await api.uploadImageData(imageInfo, path);
  }

  checkIsExpired(EventModel eventModel) {
    return api.checkEventExpired(eventModel.toJson());
  }
}
