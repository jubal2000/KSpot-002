
import 'package:address_search_field/address_search_field.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpers/helpers.dart';
import 'package:intl/intl.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:kspot_002/repository/event_repository.dart';
import 'package:kspot_002/view/main_event/event_item.dart';
import 'package:kspot_002/widget/main_list_item.dart';
import 'package:kspot_002/widget/title_text_widget.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../repository/place_repository.dart';
import '../utils/utils.dart';
import '../view/app/app_top_menu.dart';
import '../view/main_event/event_detail_screen.dart';
import '../widget/content_item_card.dart';
import '../widget/google_map_widget.dart';
import 'app_view_model.dart';

class EventListType {
  static int get map      => 0;
  static int get list     => 1;
}

class EventViewModel extends ChangeNotifier {
  Map<String, EventModel>? eventData;
  Map<String, Widget> listItemData = {};
  Map<String, Widget> mapItemData = {};
  BuildContext? buildContext;
  List<JSON>    eventShowList = [];
  LatLngBounds? mapBounds;
  GoogleMapWidget? googleWidget;

  final eventRepo = EventRepository();
  final placeRepo = PlaceRepository();
  final dateController = DatePickerController();
  final mapKey = GlobalKey();

  var cameraPos = CameraPosition(target: LatLng(0,0));
  var isDatePickerExtend = false;
  var eventListType = EventListType.map;

  DatePicker? datePicker;

  init(BuildContext context) {
    buildContext = context;
  }

  refreshModel() {
    mapBounds = null;
    googleWidget = null;
    eventShowList.clear();
    mapItemData.clear();
    listItemData.clear();
  }

  Future getEventList() async {
    mapBounds = null;
    eventShowList.clear();
    mapItemData.clear();
    listItemData.clear();
    AppData.eventViewModel.eventData = null;
    var result = await eventRepo.getEventListFromCountry(AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
    LOG('--> getEventList result : ${result.length}');
    AppData.eventViewModel.eventData = result;
    return result;
  }

  showGoogleWidget(layout) {
    LOG('--> showGoogleWidget : ${googleWidget == null ? 'none' : 'ready'} / ${eventShowList.length}');
    final isRefresh = googleWidget == null;
    googleWidget ??= GoogleMapWidget(
      eventShowList,
      key: mapKey,
      mapHeight: layout.maxHeight - UI_MENU_HEIGHT,
      onMarkerSelected: (selectItem) {
        LOG('--> onMarkerSelected : ${selectItem['title']} / ${selectItem['id']}');
      },
      onCameraMoved: (pos, region) {
        cameraPos = pos;
        onMapRegionChanged(region);
      },
    );
    googleWidget!.showLocation = eventShowList;
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
    refreshModel();
    if (eventData != null && eventData!.isNotEmpty) {
      for (var item in eventData!.entries) {
        final showItem = item.value.toJson();
        var placeInfo = showItem['placeInfo'];
        placeInfo ??= await placeRepo.getPlaceFromId(item.value.placeId);
        if (placeInfo != null) {
          showItem['placeInfo'] = placeInfo.toJson();
          showItem['address'  ] = placeInfo.address.toJson();
          final pos = LatLng(DBL(showItem['address']['lat']), DBL(showItem['address']['lng']));
          if (mapBounds !=  null) LOG('--> eventShowList add : ${mapBounds!.toJson()} / $pos');
          if (eventListType == EventListType.map) {
            final timeData = item.value.getDateTimeData(AppData.currentDate);
            if (timeData != null && (mapBounds == null || mapBounds!.contains(pos))) {
              showItem['timeRange'] = '${timeData.startTime} ~ ${timeData.endTime}';
              LOG('--> eventShowList add : ${showItem['id']} / ${showItem['timeRange']}');
              result.add(showItem);
            }
          } else {
            LOG('--> eventShowList add : ${showItem['id']}');
            result.add(showItem);
          }
        }
      }
    }
    LOG('--> eventShowList : ${result.length} / ${eventData!.length} / ${AppData.currentDate.toString()}');
    return result;
  }

  initDatePicker() {
    datePicker ??= DatePicker(
      DateTime.now().subtract(Duration(days: 20)),
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
          isDatePickerExtend = false;
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
          width: isDatePickerExtend ? Get.width : 0,
          height: UI_DATE_PICKER_HEIGHT,
          color: Theme.of(buildContext!).canvasColor.withOpacity(0.5),
          child: datePicker,
        ),
      ]
    );
  }

  onMapRegionChanged(region) async {
    mapBounds = region;
    // List<JSON> tmpList = await setShowList();
    // if (tmpList.equals(eventShowList)) {
    //   // LOG('--> onMapRegionChanged cancel : ${tmpList.length} / ${eventShowList.length}');
    //   return false;
    // }
    // eventShowList = tmpList;
    LOG('--> onMapRegionChanged update : ${eventShowList.length}');
    Future.delayed(const Duration(milliseconds: 200), () async {
      var state = mapKey.currentState as GoogleMapState;
      state.refreshMarker(eventShowList, false);
    });
    notifyListeners();
    return true;
  }

  onMapDayChanged() async {
    mapBounds = null;
    // List<JSON> tmpList = await setShowList();
    // if (tmpList.equals(eventShowList)) {
    //   // LOG('--> onMapRegionChanged cancel : ${tmpList.length} / ${eventShowList.length}');
    //   return false;
    // }
    // eventShowList = tmpList;
    LOG('--> onMapRegionChanged update : ${eventShowList.length}');
    Future.delayed(const Duration(milliseconds: 200), () async {
      var state = mapKey.currentState as GoogleMapState;
      state.refreshMarker(eventShowList);
    });
    notifyListeners();
    return true;
  }

  showEventMap(itemWidth, itemHeight) {
    List<Widget> showList = [];
    for (var item in eventShowList) {
      var addItem = mapItemData[item['id']];
      addItem ??= Container(
          width:  itemWidth,
          height: itemHeight,
          margin: EdgeInsets.symmetric(horizontal: 3),
          child: EventSquareItem(
            item,
            backgroundColor: Theme.of(buildContext!).cardColor,
            faceOutlineColor: Theme.of(buildContext!).bottomAppBarColor,
            padding: EdgeInsets.zero,
            imageHeight: itemWidth,
            titleMaxLine: 2,
            descMaxLine: 0,
            titleStyle: CardTitleStyle(buildContext!),
            descStyle: CardDescStyle(buildContext!),
            onShowDetail: (key, status) {
              Get.to(() => EventDetailScreen(EventModel.fromJson(item), PlaceModel.fromJson(item['placeInfo'])));
            },
          )
        );
      mapItemData[item['id']] = addItem;
      showList.add(addItem);
    }
    return showList;
  }

  showEventList(itemHeight) {
    List<Widget> showList = [];
    for (var item in eventShowList) {
      var addItem = listItemData[item['id']];
      addItem ??= EventCardItem(
            EventModel.fromJson(item),
            itemHeight: itemHeight,
            isShowTheme: false,
            // showType: GoodsItemCardType.normal,
            // sellType: GoodsItemCardSellType.event,
            // backgroundColor: Theme.of(buildContext!).cardColor,
            // faceOutlineColor: Theme.of(buildContext!).bottomAppBarColor,
            // padding: EdgeInsets.zero,
            // imageHeight: itemHeight,
            // titleMaxLine: 1,
            // descMaxLine: 2,
            // titleStyle: CardTitleStyle(buildContext!),
            // descStyle: CardDescStyle(buildContext!),
            // onShowDetail: (key, status) {
            //   Get.to(() => EventDetailScreen(EventModel.fromJson(item), PlaceModel.fromJson(item['placeInfo'])));
            // },
      );
      listItemData[item['id']] = addItem;
      showList.add(addItem);
    }
    return showList;
  }

  showMainList() {
    LOG('--> showMainList : ${eventShowList.length} / ${googleWidget == null ? 'none' : 'ready'}');
    return LayoutBuilder(
      builder: (context, layout) {
        final itemWidth  = layout.maxWidth / 4.0;
        final itemHeight = itemWidth * 2.0;
        return Stack(
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
                        eventShowList = snapshot.data as List<JSON>;
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
                        eventShowList = snapshot.data as List<JSON>;
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
                height: UI_TOP_MENU_HEIGHT * 1.7,
                child: AppTopMenuBar(MainMenuID.event,
                  isShowDatePick: !isDatePickerExtend && eventListType == EventListType.map, height: UI_TOP_MENU_HEIGHT,
                  onCountryChanged: () {
                    LOG('--> onCountryChanged : ${AppData.currentState}');
                    refreshModel();
                    notifyListeners();
                  },
                  onDateChange: () {
                    isDatePickerExtend = true;
                    notifyListeners();
                    dateController.animateToSelection(duration: Duration(milliseconds: 10));
                  }
                ),
              )
            ),
          ],
        );
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}