import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
import '../view/home/home_top_menu.dart';
import '../view/place/place_list_screen.dart';
import '../view/story/story_item.dart';
import 'app_view_model.dart';

enum StoryListType {
  grid,
  single,
  none,
}

class StoryViewModel extends ChangeNotifier {
  final cache     = Get.find<CacheService>();
  final storyRepo = StoryRepository();

  Stream? stream;

  // var lastUpdateKey = '';
  var lastIndex = -1;
  var storyListType = StoryListType.single;

  refreshModel() {
    cache.storyListItemData.clear();
  }

  getStoryList() {
    stream = storyRepo.getStoryStreamFromGroup(AppData.currentEventGroup!.id);
  }

  getStoryListNext(item) {
    stream = storyRepo.getStoryStreamFromGroupNext(item.createTime, AppData.currentEventGroup!.id);
  }

  stopStoryStream() {
    LOG('------> stopStoryStream : ${stream != null}');
    if (stream != null) {
      stream = null;
    }
  }

  showStoryListType() {
    return GestureDetector(
      onTap: () {
        storyListType = storyListType == StoryListType.grid ? StoryListType.single : StoryListType.grid;
        notifyListeners();
      },
      child: Icon(storyListType == StoryListType.grid ? Icons.grid_view_outlined : Icons.photo_outlined),
    );
  }

  Future refreshShowList() async {
    var count = 0;
    // await Future.delayed(Duration(milliseconds: 300));
    // await cache.sortStoryDataCreateTimeDesc();
    List<Widget> showList = [];
    for (var item in cache.storyData.entries) {
      LOG('--> refreshShowList : ${item.value.toJson()}');
      if (JSON_EMPTY(cache.reportData['report']) || !cache.reportData['report'].containsKey(item.key)) {
        var addItem = cache.storyListItemData[item.key];
        addItem ??= MainStoryItem(
          item.value,
          index: count,
          onItemVisible: (index, status) {
            if (status && index < cache.storyData.length) {
              LOG('--> MainStoryItem visible : $index / $lastIndex - ${cache.storyData.length - FREE_LOADING_STORY_MAX}');
              if (index == cache.storyData.length - FREE_LOADING_STORY_MAX && lastIndex != index) {
                lastIndex = index;
                getStoryListNext(cache.storyData.entries.last.value);
                notifyListeners();
              }
              // loading next video..
              if (index+1 < cache.storyData.length) {
                LOG('------> MainStoryItem loadVideoData : ${index + 1}');
                // if (storyKeyList[index+1].currentState != null) {
                //   var state = storyKeyList[index+1].currentState as MainStoryItemState;
                //   state.loadVideoData();
                // }
              }
            }
          },
          onItemDeleted: (key) {
            // var item = _showData[_currentTab][index];
            LOG('--> onItemDeleted : $key');
            // _storyData.remove(item['id']);
            cache.storyData.remove(key);
            notifyListeners();
          },
          onRefresh: (updateItem) {
            cache.storyData[updateItem['id']] = StoryModel.fromJson(updateItem);
            cache.storyListItemData.clear();
            notifyListeners();
          },
        );
        cache.storyListItemData[item.key] = addItem;
        showList.add(addItem);
      }
      count++;
    }
    // LOG('------> refreshShowList : ${showList.length} ${cache.storyData!.entries.length}');
    return sortDataCreateTimeDesc(showList);
  }

  sortDataCreateTimeDesc(showList) {
    for (var a=0; a<showList.length-1; a++) {
      for (var b=a+1; b<showList.length; b++) {
        final aDate = showList[a].itemInfo.createTime;
        final bDate = showList[b].itemInfo.createTime;
        // LOG("----> check : ${aDate.toString()} > ${bDate.toString()}");
        if (aDate != bDate && aDate.isBefore(bDate)) {
          LOG("--> changed : ${aDate.toString()} <-> ${bDate.toString()}");
          final tmp = showList[a];
          showList[a] = showList[b];
          showList[b] = tmp;
        }
      }
    }
    return showList;
  }

  onSnapshotAction(snapshot) async {
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
          try {
            var data = FROM_SERVER_DATA(item.data() as JSON);
            cache.setStoryItem(StoryModel.fromJson(data));
            LOG('--> cache.storyData add : ${data['id']} / ${cache.storyData!.length}');
          } catch (e) {
            LOG('--> onSnapshotAction error : $e');
          }
        }
        // await Future.delayed(Duration(milliseconds: 200));
        // LOG('--> refreshShowList start');
        // refreshShowList();
        return true;
      case ConnectionState.done:
        return true;
    }
    return null;
  }

  showMainList(layout, snapshot) {
    onSnapshotAction(snapshot);
    return Stack(
      children: [
        // ...cache.storyListItemData.entries.map((e) => e.value).toList(),
        FutureBuilder(
          future: refreshShowList(),
          builder: (context, snapshot) {
            LOG('--> snapshot.hasData : ${snapshot.hasData}');
            if (snapshot.hasData) {
              final showList = snapshot.data;
              return ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(height: UI_APPBAR_TOOL_HEIGHT),
                  if (storyListType == StoryListType.single)
                    ...showList,
                  if (storyListType == StoryListType.grid)
                    MasonryGridView.count(
                      shrinkWrap: true,
                      itemCount: showList.length,
                      crossAxisCount: 3,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      itemBuilder: (BuildContext context, int index) {
                        return showList[index];
                      }
                    ),
                  SizedBox(height: UI_BOTTOM_HEIGHT + 20),
                ]
              );
            } else {
              return Center(
                child: showLoadingCircleSquare(50),
              );
            }
          }
        ),
        // ListView(
        //   shrinkWrap: true,
        //   children: [
        //     SizedBox(height: UI_APPBAR_TOOL_HEIGHT),
        //     // ...cache.storyListItemData.entries.map((e) => e.value).toList(),
        //     FutureBuilder(
        //       future: cache.sortStoryDataCreateTimeDesc(),
        //       builder: (context, snapshot) {
        //         LOG('--> snapshot.hasData : ${snapshot.hasData}');
        //         if (snapshot.hasData) {
        //           refreshShowList();
        //           return ListView(
        //             shrinkWrap: true,
        //             physics: NeverScrollableScrollPhysics(),
        //             children: cache.storyListItemData.entries.map((e) => e.value).toList()
        //           );
        //         } else {
        //           return Center(
        //             child: showLoadingCircleSquare(50),
        //           );
        //         }
        //       }
        //     ),
        //     SizedBox(height: UI_BOTTOM_HEIGHT + 20),
        //   ],
        // ),
        TopCenterAlign(
          child: SizedBox(
            height: UI_APPBAR_HEIGHT,
            child: HomeTopMenuBar(
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