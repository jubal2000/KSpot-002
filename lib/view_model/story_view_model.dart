import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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
  List<JSON>    showList = [];
  Stream? storyStream;

  var lastUpdateIndex = -1;

  refreshModel() {
    cache.storyListItemData.clear();
    showList.clear();
  }

  getStoryList() {
    storyStream = storyRepo.getStoryStreamFromGroup(AppData.currentEventGroup!.id);
  }

  getStoryListNext() {
    storyStream = storyRepo.getStoryStreamFromGroupNext(cache.storyData!.entries.last.value.createTime, AppData.currentEventGroup!.id);
  }

  refreshShowList() {
    for (var item in cache.storyData!.entries) {
      var addItem = cache.eventMapItemData[item.key];
      addItem ??= MainStoryItem(
        item.value,
        index: showList.length,
        onItemVisible: (index, status) {
          LOG('--> MainStoryItem visible : $index - $status');
          if (status && index < cache.storyData!.length) {
            if (index > cache.storyData!.length - FREE_LOADING_STORY_MAX && lastUpdateIndex != index) {
                lastUpdateIndex = index;
                getStoryListNext();
            }
            // loading next video..
            if (index+1 < cache.storyData!.length) {
              LOG('------> MainStoryItem loadVideoData : ${index + 1}');
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
      showList.add(item.value.toJson());
    }
  }

  showItemList(snapshot) {
    LOG('--> showItemList : ${snapshot.hasError} / ${snapshot.connectionState}');
    if (snapshot.hasError) {
      return Center(
        child: Text('Unable to get data'.tr));
    }

    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Center(
            child: Text('Data does not exist'.tr));
      case ConnectionState.waiting:
        return Center(
            child: Text('Waiting...'.tr));
      case ConnectionState.active:
      case ConnectionState.done:
        for (var item in snapshot.data.docs) {
          var data = JSON.from(FROM_SERVER_DATA(item.data() as JSON));
          cache.storyData ??= {};
          cache.storyData![data['id']] = StoryModel.fromJson(data);
        }
        refreshShowList();
        return ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: UI_APPBAR_TOOL_HEIGHT),
            ...cache.storyListItemData.entries.map((e) => e.value).toList(),
            SizedBox(height: UI_BOTTOM_HEIGHT + 20),
          ],
        );
    }
    return Center(
      child: showLoadingCircleSquare(50),
    );
  }

  showMainList(layout, snapshot) {
    return Stack(
      children: [
        showItemList(snapshot),
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