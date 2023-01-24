import 'package:get/get.dart';
import 'package:kspot_002/services/api_service.dart';

import '../models/event_group_model.dart';
import '../utils/utils.dart';
import '../models/user_model.dart';

class EventGroupRepository {
  final api = Get.find<ApiService>();

  Future<Map<String, EventGroupModel>> getEventGroupList() async {
    Map<String, EventGroupModel> result = {};
    try {
      final response = await api.getEventGroupList();
      for (var item in response.entries) {
        result[item.key] = EventGroupModel.fromJson(FROM_SERVER_DATA(item.value));
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
        return EventGroupModel.fromJson(FROM_SERVER_DATA(response));
      }
    } catch (e) {
      LOG('--> addEventGroupItem error : $e');
      throw e.toString();
    }
    return null;
  }
}
