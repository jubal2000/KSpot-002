import 'package:get/get.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:kspot_002/services/api_service.dart';

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
      throw e.toString();
    }
  }

  Future<Map<String, PlaceModel>> getPlaceListFromGroupId(String groupId) async {
    Map<String, PlaceModel> result = {};
    try {
      final response = await api.getPlaceList(groupId);
      for (var item in response.entries) {
        result[item.key] = PlaceModel.fromJson(item.value);
        LOG('--> getPlaceListFromGroupId item : ${result[item.key]!.toJson()}');
      }
      return result;
    } catch (e) {
      LOG('--> getPlaceListFromGroupId error [$groupId] : $e');
      throw e.toString();
    }
  }

  Future<PlaceModel?> addPlaceItem(PlaceModel addItem) async {
    try {
      final response = await api.addPlaceItem(addItem.toJson());
      if (response != null) {
        return PlaceModel.fromJson(response);
      }
    } catch (e) {
      LOG('--> addPlaceItem error : $e');
      throw e.toString();
    }
    return null;
  }
}
