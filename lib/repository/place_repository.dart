import 'package:get/get.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../models/event_group_model.dart';
import '../utils/utils.dart';

class PlaceRepository {
  final api = Get.find<ApiService>();

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
    try {
      if (AppData.placeData.containsKey(placeId)) return AppData.placeData[placeId];
      final response = await api.getPlaceFromId(placeId);
      if (response != null) {
        LOG('--> getPlaceFromId response : $response');
        final placeData = PlaceModel.fromJson(FROM_SERVER_DATA(response));
        AppData.placeData[placeData.id] = placeData;
        return placeData;
      }
    } catch (e) {
      LOG('--> getPlaceFromId error : $e');
    }
    return null;
  }

  Future<PlaceModel?> addPlaceItem(PlaceModel addItem) async {
    try {
      final response = await api.addPlaceItem(addItem.toJson());
      if (response != null) {
        final placeData = PlaceModel.fromJson(FROM_SERVER_DATA(response));
        AppData.placeData[placeData.id] = placeData;
        return placeData;
      }
    } catch (e) {
      LOG('--> addPlaceItem error : $e');
    }
    return null;
  }
}
