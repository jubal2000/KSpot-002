import 'package:get/get.dart';
import 'package:kspot_002/models/etc_model.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../models/event_model.dart';
import '../models/story_model.dart';
import '../utils/utils.dart';
import '../models/user_model.dart';

class EventRepository {
  final api = Get.find<ApiService>();

  Future<Map<String, EventModel>> getEventListFromCountry(String groupId, String country, [String countryState = '']) async {
    Map<String, EventModel> result = {};
    try {
      final response = await api.getEventListFromCountry(groupId, country, countryState);
      for (var item in response.entries) {
        LOG('--> getEventListFromCountry item : ${item.value['id']}');
        result[item.key] = EventModel.fromJson(item.value);
      }
      return result;
    } catch (e) {
      LOG('--> getEventListFromCountry error [$groupId] : $e');
      throw e.toString();
    }
  }

  Future<EventModel?> addEventItem(EventModel addItem) async {
    try {
      final response = await api.addEventItem(addItem.toJson());
      if (response != null) {
        return EventModel.fromJson(response);
      }
    } catch (e) {
      LOG('--> addEventItem error : $e');
      throw e.toString();
    }
    return null;
  }

  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<String?> uploadImageInfo(JSON imageInfo, [String path = 'event_img']) async {
    return await api.uploadImageData(imageInfo, path);
  }
}
