import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/models/story_model.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../models/event_model.dart';
import '../repository/story_repository.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/home/app_top_menu.dart';
import '../view/story/story_item.dart';
import 'app_view_model.dart';

class StoryViewModel extends ChangeNotifier {
  final cache     = Get.find<CacheService>();
  final storyRepo = StoryRepository();

  BuildContext? buildContext;
  List<JSON>    showList = [];
  Stream? storyStream;

  var lastUpdateIndex = -1;

  getStoryList() {
    showList.clear();
    cache.eventData = null; // need make null..
    storyStream = storyRepo.getStoryStreamFromGroup(AppData.currentEventGroup!.id);
  }

  getStoryListNext() {
    storyStream = storyRepo.getStoryStreamFromGroupNext(cache.storyData!.entries.last.value.createTime, AppData.currentEventGroup!.id);
  }

  refreshShowList() {
    for (var item in cache.storyData!.entries) {
      var addItem = cache.eventMapItemData[item.key];
      addItem ??= MainStoryItem(
        item.value.toJson(),
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

  showMainList(layout) {
    if (storyStream == null) {
      getStoryList();
    }
    return StreamBuilder(
      stream: storyRepo.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Unable to get data'.tr);
        } else {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Data does not exist'.tr);
            case ConnectionState.waiting:
              break;
            case ConnectionState.active:
              for (var item in snapshot.data.docs) {
                var data = JSON.from(FROM_SERVER_DATA(item.data() as JSON));
                cache.storyData ??= {};
                cache.storyData![data['id']] = StoryModel.fromJson(data);
              }
              break;
            case ConnectionState.done:
              break;
          }
          refreshShowList();
          return ListView(
            children: cache.storyListItemData.entries.map((e) => e.value).toList(),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}