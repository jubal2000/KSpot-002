import 'dart:collection';

import 'package:get/get.dart';
import 'package:kspot_002/models/etc_model.dart';
import 'package:kspot_002/services/api_service.dart';
import 'package:kspot_002/services/cache_service.dart';

import '../data/app_data.dart';
import '../models/event_group_model.dart';
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

  Future<List<JSON>> getEventSponsorList(String targetId) async {
    return await api.getSponsorFromTargetId(targetId, type: 'event');
  }

  Future<Map<String, EventModel>> getEventListFromCountry(String groupId, String country, [String countryState = '']) async {
    Map<String, EventModel> result = {};
    try {
      final response = await api.getEventListFromCountry(groupId, country, countryState);
      for (var item in response.entries) {
        item.value['sponsorData'] = await getEventSponsorList(item.key);
        var eventItem = EventModel.fromJson(item.value);
        LOG('--> eventItem.sponsorData [${eventItem.title}] : ${eventItem.sponsorData}');
        result[item.key] = eventItem;
        cache.setEventItem(eventItem);
      }
    } catch (e) {
      LOG('--> getEventListFromCountry error [$groupId] : $e');
    }
    return result;
  }

  Future<EventModel?> getEventFromId(String eventId) async {
    try {
      var cacheItem = cache.getEventItem(eventId);
      if (cacheItem != null) return cacheItem;
      final response = await api.getEventFromId(eventId);
      if (response != null) {
        response['sponsorData'] = await getEventSponsorList(response['id']);
        final eventItem = EventModel.fromJson(FROM_SERVER_DATA(response));
        LOG("--> getEventFromId result: ${eventItem.toJson()}");
        cache.setEventItem(eventItem);
        return eventItem;
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
        cache.setEventItem(eventData);
        return eventData;
      }
    } catch (e) {
      LOG('--> addEventItem error : $e');
    }
    return null;
  }

  Future<bool> setEventStatus(String eventId, int status) async {
    var result =  await api.setEventStatus(eventId, status);
    if (result) {
      var cacheItem = cache.getEventItem(eventId);
      if (cacheItem != null) {
        cacheItem.status = status;
        cache.setEventItem(cacheItem);
      }
    }
    return result;
  }

  Future<bool> setEventShowStatus(String eventId, int status) async {
    var result =  await api.setEventShowStatus(eventId, status);
    if (result) {
      var cacheItem = cache.getEventItem(eventId);
      if (cacheItem != null) {
        cacheItem.showStatus = status;
        cache.setEventItem(cacheItem);
      }
    }
    return result;
  }

  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<Map<String, EventGroupModel>> getEventGroupList() async {
    Map<String, EventGroupModel> result = {};
    try {
      final response = await api.getEventGroupList();
      for (var item in response.entries) {
        var addItem = EventGroupModel.fromJson(FROM_SERVER_DATA(item.value));
        result[item.key] = addItem;
        cache.setEventGroupItem(addItem);
      }
      LOG("--> getEventGroupList result: $result");
      return result;
    } catch (e) {
      LOG("--> getEventGroupList error: $e");
      throw e.toString();
    }
  }

  Future<EventGroupModel?> getEventGroupFromId(String groupId) async {
    try {
      final cacheItem = cache.getEventGroupItem(groupId);
      if (cacheItem != null) return cacheItem;
      final response = await api.getEventGroupFromId(groupId);
      return EventGroupModel.fromJson(FROM_SERVER_DATA(response));
    } catch (e) {
      LOG('--> getPlaceGroupFromId error [$groupId] : $e');
      throw e.toString();
    }
  }

  Future<EventGroupModel?> addEventGroupItem(EventGroupModel addItem) async {
    try {
      final response = await api.addEventGroupItem(addItem.toJson());
      if (response != null) {
        var result = EventGroupModel.fromJson(FROM_SERVER_DATA(response));
        cache.setEventGroupItem(result);
      }
    } catch (e) {
      LOG('--> addEventGroupItem error : $e');
      throw e.toString();
    }
    return null;
  }

  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<String?> uploadImageInfo(JSON imageInfo, [String path = 'event_img']) async {
    return await api.uploadImageData(imageInfo, path);
  }

  checkIsExpired(EventModel event) {
    return api.checkEventExpired(event.toJson());
  }

  EventModel setSponsorCount(EventModel event) {
    var eventDate = '${AppData.currentDate.year}-${AppData.currentDate.month}-${AppData.currentDate.day}';
    event.sponsorCount[eventDate] = 0;
    LOG('--> checkSponsored [${event.title}] : ${event.sponsorData}');
    if (LIST_NOT_EMPTY(event.sponsorData)) {
      for (var item in event.sponsorData!) {
        LOG('--> event.sponsorData check [$eventDate] : ${item.toJson()}');
        if (checkDateRange(item.startTime, item.endTime)) {
          var orgCount = event.sponsorCount[eventDate] ?? 0;
          event.sponsorCount[eventDate] = orgCount + 1;
          LOG('--> checkSponsored add [$eventDate] : ${event.sponsorCount[eventDate]}');
        }
      }
    }
    return event;
  }
}
