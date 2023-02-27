
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:kspot_002/repository/event_repository.dart';
import 'package:kspot_002/view/event/event_item.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../repository/place_repository.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/home/home_top_menu.dart';
import '../view/event/event_detail_screen.dart';
import '../widget/content_item_card.dart';
import '../widget/google_map_widget.dart';
import 'app_view_model.dart';

class EventListType {
  static int get map      => 0;
  static int get list     => 1;
}

class EventViewModel extends ChangeNotifier {
  BuildContext? buildContext;
  List<JSON>    showList = [];
  LatLngBounds? mapBounds;
  GoogleMapWidget? googleWidget;

  final cache     = Get.find<CacheService>();
  final eventRepo = EventRepository();
  final placeRepo = PlaceRepository();
  final dateController = DatePickerController();
  GlobalKey mapKey = GlobalKey();

  var cameraPos = CameraPosition(target: LatLng(0,0));
  var isDateOpen = false;
  var eventListType = EventListType.map;
  var isMapUpdate = true;
  var isManagerMode = false; // 유저의 이벤트목록 일 경우 메니저이면, 기간이 지난 이벤트들도 표시..

  DatePicker? datePicker;

  init(BuildContext context) {
    buildContext = context;
  }

  refreshModel() {
    isMapUpdate = true;
    mapBounds = null;
    // googleWidget = null;
    cache.eventMapItemData.clear();
    cache.eventListItemData.clear();
    showList.clear();
  }

  Future getEventList() async {
    mapBounds = null;
    showList.clear();
    // mapItemData.clear();
    // listItemData.clear();
    cache.eventData = null; // need make null..
    var result = await eventRepo.getEventListFromCountry(AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
    LOG('--> getEventList result : ${result.length}');
    cache.eventData = result;
    return result;
  }

  showGoogleWidget(layout) {
    LOG('--> showGoogleWidget : ${googleWidget == null ? 'none' : 'ready'} / ${showList.length}');
    final isRefresh = googleWidget == null;
    googleWidget ??= GoogleMapWidget(
      showList,
      key: mapKey,
      mapHeight: layout.maxHeight - UI_MENU_HEIGHT + 6,
      onMarkerSelected: (selectItem) {
        LOG('--> onMarkerSelected : ${selectItem['title']} / ${selectItem['id']}');
      },
      onCameraMoved: (pos, region) {
        cameraPos = pos;
        onMapRegionChanged(region);
      },
    );
    googleWidget!.isRefresh = isRefresh;
    return googleWidget;
  }

  showEventListType() {
    return GestureDetector(
      onTap: () {
        eventListType = eventListType == EventListType.map ? EventListType.list : EventListType.map;
        notifyListeners();
      },
      child: Icon(eventListType == EventListType.map ? Icons.map_outlined : Icons.view_list_sharp),
    );
  }

  Future<List<JSON>> setShowList() async {
    List<JSON> result = [];
    if (JSON_NOT_EMPTY(cache.eventData)) {
      for (var item in cache.eventData!.entries) {
        final isExpired = eventRepo.checkIsExpired(item.value);
        if (isManagerMode || (!isExpired && item.value.status == 1)) {
          final showItem = item.value.toJson();
          var placeInfo = showItem['placeInfo'];
          placeInfo ??= await placeRepo.getPlaceFromId(item.value.placeId);
          if (placeInfo != null) {
            showItem['placeInfo'] = placeInfo.toJson();
            showItem['address'  ] = placeInfo.address.toJson();
            final pos = LatLng(DBL(showItem['address']['lat']), DBL(showItem['address']['lng']));
            // if (mapBounds !=  null) LOG('--> eventShowList add : ${mapBounds!.toJson()} / $pos');
            if (eventListType == EventListType.map) {
              final timeData = item.value.getDateTimeData(AppData.currentDate, item.value.title);
              if (timeData != null && (mapBounds == null || mapBounds!.contains(pos))) {
                showItem['timeRange'] = '${timeData.startTime} ~ ${timeData.endTime}';
                // LOG('--> eventShowList add : ${showItem['id']} / ${showItem['timeRange']}');
                result.add(showItem);
              }
            } else {
              // LOG('--> eventShowList add : ${showItem['id']}');
              result.add(showItem);
            }
          }
        }
      }
    }
    LOG('--> eventShowList : ${result.length} / ${cache.eventData!.length} / ${AppData.currentDate.toString()}');
    return result;
  }

  initDatePicker() {
    datePicker ??= DatePicker(
      DateTime.now().subtract(Duration(days: 30)),
      width:  60.0,
      height: 60.0,
      controller: dateController,
      initialSelectedDate: AppData.currentDate,
      selectionColor: Theme.of(buildContext!).primaryColor,
      monthTextStyle: TextStyle(color: Theme.of(buildContext!).hintColor, fontSize: UI_FONT_SIZE_SX),
      dateTextStyle: TextStyle(color: Theme.of(buildContext!).indicatorColor, fontSize: UI_FONT_SIZE_LT),
      dayTextStyle: TextStyle(color: Theme.of(buildContext!).hintColor, fontSize: UI_FONT_SIZE_SX),
      locale: Get.locale.toString(),
      onDateChange: (date) {
        // New date selected
        if (AppData.currentDate == date) {
          isDateOpen = false;
          notifyListeners();
        } else {
          AppData.currentDate = date;
          onMapDayChanged();
        }
      },
    );
  }

  showDatePicker() {
    initDatePicker();
    return Row(
      children: [
        Container(
          width: isDateOpen ? Get.width : 0,
          height: UI_DATE_PICKER_HEIGHT,
          color: Theme.of(buildContext!).canvasColor.withOpacity(0.5),
          child: datePicker,
        ),
      ]
    );
  }

  onMapRegionChanged(region) async {
    mapBounds = region;
    List<JSON> tmpList = await setShowList();
    if (compareShowList(tmpList)) {
      LOG('--> onMapRegionChanged cancel');
      return false;
    }
    // LOG('--> onMapRegionChanged update : ${showList.length} / ${tmpList.length}');
    // eventShowList = tmpList;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(const Duration(milliseconds: 200), () async {
    //     var state = mapKey.currentState as GoogleMapState;
    //     state.refreshMarker(eventShowList, false);
      // });
      notifyListeners();
    // });
    return true;
  }

  onMapDayChanged() async {
    mapBounds = null;
    isMapUpdate = true;
    // List<JSON> tmpList = await setShowList();
    // if (compareShowList(tmpList)) {
    //   LOG('--> onMapDayChanged cancel');
    //   return false;
    // }
    // googleWidget = null;
    // eventShowList = tmpList;
    // LOG('--> onMapDayChanged update : ${showList.length}');
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(const Duration(milliseconds: 200), () async {
    //     var state = mapKey.currentState as GoogleMapState;
    //     state.refreshMarker(eventShowList);
    //   });
      notifyListeners();
    // });
    return true;
  }

  compareShowList(List<JSON> checkList) {
    if (checkList.length != showList.length) return false;
    var checkCount = 0;
    for (var eItem in showList) {
      for (var cItem in checkList) {
        if (eItem['id'] == cItem['id']) checkCount++;
      }
    }
    return showList.length > checkList.length ? checkCount == showList.length : checkCount == checkList.length;
  }

  showEventMap(itemWidth, itemHeight) {
    List<Widget> tmpList = [];
    for (var item in showList) {
      var addItem = cache.eventMapItemData[item['id']];
      LOG('--> showEventMap : ${item['id']} / ${item['title']} / ${addItem != null ? 'OK': 'none'}');
      addItem ??= Container(
          width:  itemWidth,
          height: itemHeight,
          margin: EdgeInsets.symmetric(horizontal: 3),
          child: EventSquareItem(
            item,
            backgroundColor: Theme.of(buildContext!).cardColor,
            faceOutlineColor: Theme.of(buildContext!).colorScheme.secondary,
            padding: EdgeInsets.zero,
            imageHeight: itemWidth,
            titleMaxLine: 2,
            descMaxLine: 0,
            titleStyle: CardTitleStyle(buildContext!),
            descStyle: CardDescStyle(buildContext!),
            onShowDetail: (key, status) {
              showEventItemDetail(item);
              // Get.to(() => EventDetailScreen(EventModel.fromJson(item), PlaceModel.fromJson(item['placeInfo'])))!.then((eventInfo) {
              //   if (eventInfo != null) {
              //     isMapUpdate = true;
              //     showList.clear();
              //     cache.setEventItem(eventInfo!);
              //     notifyListeners();
              //   }
              // });
            },
          )
        );
      cache.eventMapItemData[item['id']] = addItem;
      tmpList.add(addItem);
    }
    if (isMapUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 200), () async {
          if (mapKey.currentState != null) {
            var state = mapKey.currentState as GoogleMapState;
            state.refreshMarker(showList);
            isMapUpdate = false;
          }
        });
      });
    }
    return tmpList;
  }

  showEventList(itemHeight) {
    List<Widget> tmpList = [];
    for (var item in showList) {
      var addItem = cache.eventListItemData[item['id']];
      addItem ??= EventCardItem(
        EventModel.fromJson(item),
        itemHeight: itemHeight,
        isShowTheme: false,
        onShowDetail: (key, status) {
          showEventItemDetail(item);
        },
      );
      cache.eventListItemData[item['id']] = addItem;
      tmpList.add(addItem);
    }
    return tmpList;
  }

  showEventItemDetail(item) {
    Get.to(() => EventDetailScreen(EventModel.fromJson(item), PlaceModel.fromJson(item['placeInfo'])))!.then((eventInfo) {
      if (eventInfo != null) {
        isMapUpdate = true;
        showList.clear();
        cache.setEventItem(eventInfo!);
        notifyListeners();
      }
    });
  }

  showMainList(layout) {
    final itemWidth  = layout.maxWidth / 4.0;
    final itemHeight = itemWidth * 2.0;
    return Container(
      color: eventListType == EventListType.map ? Colors.white : null,
      child: Stack(
        children: [
          if (eventListType == EventListType.map)...[
            showGoogleWidget(layout),
            Align(
              widthFactor: 1.25,
              heightFactor: 3.0,
              child: showDatePicker(),
            ),
            BottomLeftAlign(
              child: Container(
                height: itemHeight,
                margin: EdgeInsets.only(bottom: UI_MENU_BG_HEIGHT),
                child: FutureBuilder(
                  future: setShowList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      showList = snapshot.data as List<JSON>;
                      return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                        children: showEventMap(itemWidth, itemHeight),
                      );
                    } else {
                      return Container();
                    }
                  }
                ),
              ),
            ),
          ],
          if (eventListType == EventListType.list)...[
            Container(
              height: layout.maxHeight,
              padding: EdgeInsets.fromLTRB(0, UI_LIST_TOP_HEIGHT, 0, UI_MENU_HEIGHT),
              child: FutureBuilder(
                future: setShowList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    showList = snapshot.data as List<JSON>;
                    return ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                      children: showEventList(itemWidth)
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
          TopCenterAlign(
            child: SizedBox(
              height: UI_APPBAR_HEIGHT,
              child: HomeTopMenuBar(
                MainMenuID.event,
                isShowDatePick: eventListType == EventListType.map,
                isDateOpen: isDateOpen,
                onCountryChanged: () {
                  refreshModel();
                  notifyListeners();
                },
                onDateChange: (state) {
                  isDateOpen = state;
                  notifyListeners();
                  dateController.animateToSelection(duration: Duration(milliseconds: 10));
                }
              ),
            )
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}