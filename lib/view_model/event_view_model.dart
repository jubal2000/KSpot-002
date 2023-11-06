
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:kspot_002/repository/event_repository.dart';
import 'package:kspot_002/view/place/place_detail_screen.dart';
import 'package:kspot_002/widget/event_item.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../repository/place_repository.dart';
import '../repository/user_repository.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/home/home_top_menu.dart';
import '../view/event/event_detail_screen.dart';
import '../widget/content_item_card.dart';
import '../widget/date_picker_timeline/date_picker_widget.dart';
import '../widget/google_map_widget.dart';
import 'app_view_model.dart';

class EventListType {
  static int get map      => 0;
  static int get list     => 1;
}

enum EventListTopicType {
  hotPlace,
  newPlace,
  localPlace,
  max,
}

class EventViewModel extends ChangeNotifier {
  List<EventModel> showList = [];
  LatLngBounds? mapBounds;
  GoogleMapWidget? googleWidget;

  final cache     = Get.find<CacheService>();
  final eventRepo = EventRepository();
  final placeRepo = PlaceRepository();
  final userRepo  = UserRepository();
  final dateController = DatePickerController();
  final mapKey    = GlobalKey();

  var cameraPos = CameraPosition(target: LatLng(0,0));
  var eventListType = EventListType.map;
  DateTime? currentDateTime;

  var isDateOpen      = false.obs;
  var isFirstShow     = true;
  var isMapUpdate     = true;
  var isManagerMode   = false; // 유저의 이벤트목록 일 경우 메니저이면, 기간이 지난 이벤트들도 표시..
  var isRefreshMap    = false;

  DatePicker? datePicker;

  initView() {
    isMapUpdate = true;
    mapBounds = null;
    // googleWidget = null;
    cache.eventMapItemData.clear();
    cache.eventListItemData.clear();
    showList.clear();
  }

  refreshView() {
    notifyListeners();
  }

  setSelectDate(bool state) async {
    LOG('--> setSelectDate : $isDateOpen / $state - $currentDateTime / ${AppData.currentDate}');
    if (isDateOpen.value != state) {
      isDateOpen.value = state;
      if (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(Duration(milliseconds: 200)).then((_) {
            LOG('---> setSelectDate currentDate : ${AppData.currentDate}');
            dateController.setDateAndAnimate(
                AppData.currentDate, duration: Duration(milliseconds: 100));
          });
        });
      }
    } else if (currentDateTime != AppData.currentDate) {
      currentDateTime = AppData.currentDate;
      showList = await setShowList();
      refreshView();
    }
    return true;
  }

  Future getEventData() {
    LOG('--> getEventData : ${AppData.currentEventGroup!.id} / ${AppData.currentCountry} / ${AppData.currentState}');
    mapBounds = null;
    isMapUpdate = true;
    showList.clear();
    cache.eventData.clear();
    return eventRepo.getEventListFromCountry(AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
  }

  Future getBookmarkData(String userId) async {
    if (userId.isNotEmpty) {
      cache.bookmarkData = await userRepo.getBookmarkFromUserId(userId);
      LOG('--> bookmarkData result : ${cache.bookmarkData.length}');
    }
    return cache.bookmarkData;
  }

  showGoogleWidget({var height = 300.0}) {
    LOG('--> showGoogleWidget : ${googleWidget == null ? 'none' : 'ready'} / ${showList.length}');
    googleWidget ??= GoogleMapWidget(
      showList.map((e) => e.toJson()).toList(),
      key: mapKey,
      mapHeight: height - UI_MENU_HEIGHT + 6,
      onMarkerSelected: (selectItem) {
        LOG('--> onMarkerSelected : ${selectItem['title']} / ${selectItem['id']}');
          Get.to(() => PlaceDetailScreen(PlaceModel.fromJson(selectItem), null))!.then((eventInfo) {
        });
      },
      onCameraMoved: (pos, region) {
        cameraPos = pos;
        onMapRegionChanged(region);
      },
    );
    return googleWidget;
  }

  showEventListType() {
    return GestureDetector(
      onTap: () {
        eventListType = eventListType == EventListType.map ? EventListType.list : EventListType.map;
        notifyListeners();
      },
      child: Icon(eventListType == EventListType.map ? Icons.view_list_sharp : Icons.map_outlined),
    );
  }

  Future<List<EventModel>> setShowList() async {
    List<EventModel> result = [];
    if (JSON_NOT_EMPTY(cache.eventData)) {
      for (var item in cache.eventData.entries) {
        final isExpired = eventRepo.checkIsExpired(item.value, AppData.currentDate);
        if (isManagerMode || (!isExpired && item.value.status == 1)) {
          var placeInfo = item.value.placeInfo;
          placeInfo ??= await placeRepo.getPlaceFromId(item.value.placeId);
          if (placeInfo != null) {
            // LOG('--> setShowList placeInfo [${placeInfo.id}] : ${placeInfo.title}');
            item.value.placeInfo = placeInfo;
            final pos = LatLng(DBL(placeInfo.address.lat), DBL(placeInfo.address.lng));
            // if (mapBounds !=  null) LOG('--> eventShowList add : ${mapBounds!.toJson()} / $pos');
            if (eventListType == EventListType.map) {
              final timeData = item.value.getDateTimeData(AppData.currentDate, item.value.title);
              if (timeData != null && (mapBounds == null || mapBounds!.contains(pos))) {
                item.value.timeRange = '${timeData.startTime} ~ ${timeData.endTime}';
                // LOG('--> eventShowList add : ${item.value.title} / ${item.value.timeRange}');
                result.add(item.value);
              } else {
                // LOG('--> eventShowList del : ${item.value.title} / $timeData');
              }
            } else {
              result.add(item.value);
            }
          } else {
            LOG('----------> no place info');
          }
        }
      }
    }
    LOG('--> eventShowList : ${result.length} / ${cache.eventData.length} / ${currentDateTime.toString()}');
    return result;
  }

  initDatePicker() {
    LOG('----> initDatePicker : $datePicker / ${AppData.currentDate}');
    datePicker ??= DatePicker(
      DateTime.now().subtract(Duration(days: 30)),
      width:  60.0,
      height: 60.0,
      controller: dateController,
      initialSelectedDate: AppData.currentDate,
      selectionColor: Theme.of(Get.context!).primaryColor,
      monthTextStyle: TextStyle(color: Theme.of(Get.context!).hintColor, fontSize: UI_FONT_SIZE_SX),
      dateTextStyle: TextStyle(color: Theme.of(Get.context!).indicatorColor, fontSize: UI_FONT_SIZE_LT),
      dayTextStyle: TextStyle(color: Theme.of(Get.context!).hintColor, fontSize: UI_FONT_SIZE_SX),
      locale: Get.locale.toString(),
      onDateChange: (date) {
        LOG('--> onDateChange : $date');
        AppData.currentDate = date;
        onMapDayChanged();
      },
    );
    return datePicker;
  }

  showDatePicker() {
    return Obx(() => Align(
      widthFactor: 1.25,
      heightFactor: 3.0,
      child: Row(
        children: [
          if (isDateOpen.value)
            Container(
              width: Get.width,
              height: UI_DATE_PICKER_HEIGHT.h,
              color: Theme.of(Get.context!).canvasColor.withOpacity(0.5),
              child: initDatePicker(),
            ),
        ]
      ),
    ));
  }

  onMapRegionChanged(region) async {
    mapBounds = region;
    var tmpList = await setShowList();
    if (compareShowList(tmpList)) {
      return false;
    }
    showList = tmpList;
    refreshView();
    return true;
  }

  onMapDayChanged() {
    mapBounds = null;
    isMapUpdate = true;
    setSelectDate(isDateOpen.value);
    return true;
  }

  compareShowList(List<EventModel> checkList) {
    if (checkList.length != showList.length) return false;
    var checkCount = 0;
    for (var eItem in showList) {
      for (var cItem in checkList) {
        if (eItem.id == cItem.id) checkCount++;
      }
    }
    return showList.length > checkList.length ? checkCount == showList.length : checkCount == checkList.length;
  }

  showEventMap() {
    var itemHeight = 220.0;
    List<Widget> tmpList = [];
    // recommend count..
    for (var i=0; i<showList.length; i++) {
      var eventOrg = cache.eventData[showList[i].id];
      if (eventOrg != null) {
        // LOG('--> eventOrg.recommendData [${showList[i].title}] : ${eventOrg.recommendData}');
        // if (LIST_NOT_EMPTY(eventOrg.recommendData)) {
        //   for (var item in eventOrg.recommendData!) {
        //     LOG('--> recommendData item : ${item.toJson()}');
        //   }
        // }
        showList[i].recommendData = eventOrg.recommendData;
      }
      showList[i] = eventRepo.setRecommendCount(showList[i], AppData.currentDate);
    }
    // LOG('--> eventShowList result : ${showList.length}');
    showList = EVENT_SORT_HOT(showList);
    for (var eventItem in showList) {
      var addItem = cache.eventMapItemData[eventItem.id];
      // LOG('--> showEventMap : ${item.id} / ${item.title} / ${addItem != null ? 'OK': 'none'}');
      addItem ??= PlaceEventMapCardItem(
        eventItem,
        itemHeight: itemHeight,
        itemWidth:  itemHeight * 0.5,
        margin: EdgeInsets.all(5),
        backgroundColor:  Theme.of(Get.context!).cardColor,
        faceOutlineColor: Theme.of(Get.context!).colorScheme.secondary,
        onShowDetail: (key, status) {
          switch(status) {
            case 1:
              var state = mapKey.currentState as GoogleMapState;
              state.moveToLocation(LATLNG(eventItem.placeInfo!.address.toJson()));
              break;
            default:
              showEventItemDetail(eventItem);
              break;
          }
        },
      );
      cache.eventMapItemData[eventItem.id] = addItem;
      tmpList.add(addItem);
    }
    LOG('----> showEventMap : $isMapUpdate / ${tmpList.length} / ${showList.length}');
    if (isMapUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mapKey.currentState != null) {
            List addList = [];
            List<JSON> markerList = [];
            for (var e in showList) {
              if (e.placeInfo != null) {
                if (!addList.contains(e.placeInfo!.id)) {
                  markerList.add(e.placeInfo!.toJson());
                  addList.add(e.placeInfo!.id);
                  LOG('--> add markerList : ${addList.length} / ${e.placeInfo!.id}');
                }
              }
            }
            var state = mapKey.currentState as GoogleMapState;
            state.refreshMarker(markerList);
            isMapUpdate = false;
          }
        });
      });
    }
    return tmpList;
  }

  showEventList(itemHeight) {
    List<Widget> tmpList = [];
    // recommend count..
    for (var i=0; i<showList.length; i++) {
      var eventOrg = cache.eventData[showList[i].id];
      if (eventOrg != null) {
        showList[i].recommendData = eventOrg.recommendData;
      }
      showList[i] = eventRepo.setRecommendCount(showList[i], AppData.currentDate);
    }
    showList = EVENT_SORT_HOT(showList);
    for (var eventItem in showList) {
      var addItem = cache.eventListItemData[eventItem.id];
      addItem ??= EventCardItem(
        eventItem,
        isShowDesc: true,
        itemHeight: itemHeight,
        onShowDetail: (key, status) {
          showEventItemDetail(eventItem);
        },
      );
      cache.eventListItemData[eventItem.id] = addItem;
      tmpList.add(addItem);
    }
    return tmpList;
  }

  showEventItemDetail(EventModel item) {
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      Get.to(() => EventDetailScreen(item, item.placeInfo))!.then((eventInfo) {
        if (eventInfo != null) {
          isMapUpdate = true;
          showList.clear();
          cache.setEventItem(eventInfo!);
          notifyListeners();
        }
      });
    });
  }

  showMapList() {
    var itemHeight = 220.0;
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          showGoogleWidget(height: Get.height - 15),
          BottomLeftAlign(
            child: Container(
              height: itemHeight,
              margin: EdgeInsets.only(bottom: UI_MENU_BG_HEIGHT - 10),
              child: isFirstShow ?
              FutureBuilder(
                future: setShowList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    showList = snapshot.data!;
                    isFirstShow = false;
                    return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                        children: showEventMap()
                    );
                  } else {
                    return Container();
                  }
                }
              ) : ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                  children: showEventMap()
              ),
            ),
          ),
        ],
      )
    );
  }

  showMainList() {
    var itemHeight = 200.0;
    var itemWidth  = itemHeight * 0.6;
    return Obx(() => Container(
      padding: EdgeInsets.fromLTRB(0, UI_LIST_TOP_HEIGHT, 0, UI_MENU_HEIGHT),
      child: Column(
        children: [
          if (isDateOpen.value)
            SizedBox(height: UI_DATE_PICKER_HEIGHT.h + 5.h),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
              children: [
                if (isDateOpen.value)
                  SizedBox(height: 10.h),
                ...showEventList(itemWidth),
                SizedBox(height: 10.h),
              ]
            ),
          )
        ],
      ),
    ));
  }

  showEventMain() {
    LOG('---> showEventMain');
    return Stack(
      children: [
        if (eventListType == EventListType.map)
            showMapList(),
        if (eventListType == EventListType.list)
            showMainList(),
        showDatePicker(),
      ]
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}