import 'package:get/get.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../models/event_group_model.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';

class PlaceRepository {
  final api = Get.find<ApiService>();
  final cache = Get.find<CacheService>();

  Future<Map<String, PlaceModel>> getPlaceListWithCountry(String groupId, String country, [String countryState = '']) async {
    Map<String, PlaceModel> result = {};
    try {
      final response = await api.getPlaceListWithCountry(groupId, country, countryState);
      for (var item in response.entries) {
        LOG('--> getPlaceListWithCountry item : ${item.value}');
        result[item.key] = PlaceModel.fromJson(item.value);
      }
      return result;
    } catch (e) {
      LOG('--> getPlaceListWithCountry error [$groupId] : $e');
    }
    return result;
  }

  Future<Map<String, PlaceModel>> getPlaceListFromGroupId(String groupId) async {
    Map<String, PlaceModel> result = {};
    try {
      final response = await api.getPlaceList(groupId);
      for (var item in response.entries) {
        result[item.key] = PlaceModel.fromJson(item.value);
        LOG('--> getPlaceListFromGroupId item : ${result[item.key]!.toJson()}');
      }
    } catch (e) {
      LOG('--> getPlaceListFromGroupId error [$groupId] : $e');
    }
    return result;
  }

  Future<PlaceModel?> getPlaceFromId(String placeId) async {
    // LOG('--> getPlaceFromId : $placeId');
    try {
      var cacheItem = cache.getPlaceItem(placeId);
      // LOG('--> getPlaceFromId cacheItem : ${cacheItem != null ? cacheItem.toJson() : 'null'}');
      if (cacheItem != null) return cacheItem;
      final response = await api.getPlaceFromId(placeId);
      // LOG('--> getPlaceFromId response : ${response.toString()}');
      if (response != null) {
        final addItem = PlaceModel.fromJson(response);
        cache.setPlaceItem(addItem);
        // LOG('--> getPlaceFromId result : ${addItem.toJson()}');
        return addItem;
      } else {
        // TODO: place 가 삭제됬거나 없을경우 처리..
      }
    } catch (e) {
      LOG('--> getPlaceFromId error [$placeId] : $e');
    }
    return null;
  }

  Future<PlaceModel?> addPlaceItem(PlaceModel addItem) async {
    try {
      final response = await api.addPlaceItem(addItem.toJson());
      if (response != null) {
        final addItem = PlaceModel.fromJson(FROM_SERVER_DATA(response));
        cache.setPlaceItem(addItem);
        return addItem;
      }
    } catch (e) {
      LOG('--> addPlaceItem error : $e');
    }
    return null;
  }
}
