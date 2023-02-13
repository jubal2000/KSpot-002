import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/models/story_model.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../models/event_model.dart';
import '../models/place_model.dart';
import '../repository/story_repository.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/home/app_top_menu.dart';
import '../view/place/place_list_screen.dart';
import '../view/story/story_item.dart';
import 'app_view_model.dart';

class StoryViewModel extends ChangeNotifier {
  final cache     = Get.find<CacheService>();
  final storyRepo = StoryRepository();

  BuildContext? buildContext;
  Stream? storyStream;

  // var lastUpdateKey = '';
  var lastIndex = -1;

  init(context) {
    buildContext = context;
    getStoryList();
  }

  refreshModel() {
    cache.storyListItemData.clear();
  }

  getStoryList() {
    storyStream = storyRepo.getStoryStreamFromGroup(AppData.currentEventGroup!.id);
  }

  getStoryListNext(item) {
    storyStream = storyRepo.getStoryStreamFromGroupNext(item.createTime, AppData.currentEventGroup!.id);
  }

  refreshShowList() {
    var count = 0;
    for (var item in cache.storyData!.entries) {
      var addItem = cache.storyListItemData[item.key];
      addItem ??= MainStoryItem(
        item.value,
        index: count++,
        onItemVisible: (index, status) {
          if (status) LOG('--> MainStoryItem visible : $index - $status / $lastIndex - ${item.key}');
          if (status && index < cache.storyData!.length) {
            if (index == cache.storyData!.length - FREE_LOADING_STORY_MAX && lastIndex != index) {
              lastIndex = index;
              getStoryListNext(cache.storyData!.entries.last.value);
              notifyListeners();
            }
            // loading next video..
            if (index+1 < cache.storyData!.length) {
              // LOG('------> MainStoryItem loadVideoData : ${index + 1}');
              // if (storyKeyList[index+1].currentState != null) {
              //   var state = storyKeyList[index+1].currentState as MainStoryItemState;
              //   state.loadVideoData();
              // }
            }
          }
        },
        onItemDeleted: (index) {
          // var item = _showData[_currentTab][index];
          // LOG('--> onItemDeleted : $index / ${item['id']}');
          // _storyData.remove(item['id']);
        }
      );
      cache.storyListItemData[item.key] = addItem;
    }
    LOG('------> refreshShowList : ${cache.storyData!.entries.length}');
  }

  showItemList(snapshot) {
    LOG('--> showItemList : ${snapshot.hasError} / ${snapshot.connectionState}');
    if (snapshot.hasError) {
      return Center(
        child: Text('Unable to get data'.tr));
    }
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        break;
      case ConnectionState.active:
        for (var item in snapshot.data.docs) {
          var data = FROM_SERVER_DATA(item.data() as JSON);
          cache.storyData ??= {};
          cache.storyData![data['id']] = StoryModel.fromJson(data);
          LOG('--> cache.storyData add : ${data['id']} / ${cache.storyData!.length}');
        }
        refreshShowList();
        break;
      case ConnectionState.done:
    }
  }

  showMainList(layout, snapshot) {
    showItemList(snapshot);
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: UI_APPBAR_TOOL_HEIGHT),
            ...cache.storyListItemData.entries.map((e) => e.value).toList(),
            SizedBox(height: UI_BOTTOM_HEIGHT + 20),
          ],
        ),
        TopCenterAlign(
          child: SizedBox(
            height: UI_TOP_MENU_HEIGHT * 1.7,
            child: AppTopMenuBar(
              MainMenuID.story,
              isShowDatePick: false,
              onCountryChanged: () {
                refreshModel();
                notifyListeners();
              },
            ),
          )
        ),
      ]
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}