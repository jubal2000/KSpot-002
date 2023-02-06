
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
  BuildContext? buildContext;
  List<JSON>    eventShowList = [];
  Future<Map<String, EventModel>>? initData;
  LatLngBounds? mapBounds;

  final eventRepo = EventRepository();
  final placeRepo = PlaceRepository();
  final mapKey = GlobalKey();

  var cameraPos = CameraPosition(target: LatLng(0,0));
  var isTimePickerExtend = false;
  var eventListType = EventListType.map;

  init(BuildContext context) {
    buildContext = context;
    mapBounds = null;
    initData = null;
    eventShowList.clear();
    listItemData.clear();
    getEventList();
  }

  getEventList() {
    initData = eventRepo.getEventListFromCountry(AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
  }

  Future<List<JSON>> setShowList() async {
    List<JSON> result = [];
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
          if (checkDateTimeShow(item.value.getTimeDataMap, AppData.currentDate) && (mapBounds == null || mapBounds!.contains(pos))) {
            LOG('--> eventShowList add : ${showItem['id']}');
            result.add(showItem);
          }
        }
      }
    }
    LOG('--> eventShowList : ${result.length} / ${eventData!.length} / ${AppData.currentDate.toString()}');
    return result;
  }

  showTimePicker() {
    String month     = DateFormat.M(Get.locale.toString()).format(AppData.currentDate);
    String dayOfWeek = DateFormat.E(Get.locale.toString()).format(AppData.currentDate);
    return Row(
      children: [
        if (!isTimePickerExtend)
          GestureDetector(
            onTap: () {
              isTimePickerExtend = true;
              notifyListeners();
            },
            child: Container(
              width: 60.0,
              height: 80.0,
              margin: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE,vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Theme.of(buildContext!).canvasColor.withOpacity(0.55)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DateMonthText(buildContext!, month, color: Theme.of(buildContext!).hintColor),
                  DateDayText  (buildContext!, '${AppData.currentDate.day}', color: Theme.of(buildContext!).indicatorColor),
                  DateWeekText (buildContext!, dayOfWeek, color: Theme.of(buildContext!).hintColor),
                ],
              )
            ),
          ),
        if (isTimePickerExtend)
          Container(
            width: Get.width,
            height: UI_DATE_PICKER_HEIGHT,
            color: Theme.of(buildContext!).canvasColor.withOpacity(0.5),
            child: DatePicker(
              DateTime.now().subtract(Duration(days: 20)),
              width:  60.0,
              height: 60.0,
              initialSelectedDate: AppData.currentDate,
              selectionColor: Theme.of(buildContext!).primaryColor,
              monthTextStyle: TextStyle(color: Theme.of(buildContext!).hintColor, fontSize: UI_FONT_SIZE_SX),
              dateTextStyle: TextStyle(color: Theme.of(buildContext!).indicatorColor, fontSize: UI_FONT_SIZE_LT),
              dayTextStyle: TextStyle(color: Theme.of(buildContext!).hintColor, fontSize: UI_FONT_SIZE_SX),
              locale: Get.locale.toString(),
              onDateChange: (date) {
                // New date selected
                if (AppData.currentDate == date) {
                  isTimePickerExtend = false;
                  notifyListeners();
                } else {
                  AppData.currentDate = date;
                  onMapDayChanged();
                }
              },
            ),
          ),
      ]
    );
  }

  onMapRegionChanged(region) async {
    mapBounds = region;
    List<JSON> tmpList = await setShowList();
    if (tmpList.equals(eventShowList)) {
      // LOG('--> onMapRegionChanged cancel : ${tmpList.length} / ${eventShowList.length}');
      return false;
    }
    eventShowList = tmpList;
    LOG('--> onMapRegionChanged update : ${tmpList.length} / ${eventShowList.length}');
    Future.delayed(const Duration(milliseconds: 200), () async {
      var state = mapKey.currentState as GoogleMapState;
      state.refreshMarker(tmpList, false);
    });
    notifyListeners();
    return true;
  }

  onMapDayChanged() async {
    mapBounds = null;
    List<JSON> tmpList = await setShowList();
    if (tmpList.equals(eventShowList)) {
      // LOG('--> onMapRegionChanged cancel : ${tmpList.length} / ${eventShowList.length}');
      return false;
    }
    eventShowList = tmpList;
    LOG('--> onMapRegionChanged update : ${tmpList.length} / ${eventShowList.length}');
    Future.delayed(const Duration(milliseconds: 200), () async {
      var state = mapKey.currentState as GoogleMapState;
      state.refreshMarker(tmpList);
    });
    notifyListeners();
    return true;
  }

  showEventList(itemWidth, itemHeight) {
    List<Widget> showList = [];
    for (var item in eventShowList) {
      var addItem = listItemData[item['id']];
      addItem ??= Container(
          width: itemWidth,
          height: itemHeight,
          margin: EdgeInsets.symmetric(horizontal: 3),
          child: EventSquareItem(
            item,
            backgroundColor: Theme.of(buildContext!).cardColor,
            padding: EdgeInsets.zero,
            imageHeight: itemHeight * 0.5,
            descMaxLine: 2,
            titleStyle: CardTitleStyle(buildContext!),
            descStyle: CardDescStyle(buildContext!),
            onShowDetail: (key, status) {
              Get.to(() => EventDetailScreen(EventModel.fromJson(item), PlaceModel.fromJson(item['placeInfo'])));
            },
          )
        );
      listItemData[item['id']] = addItem;
      showList.add(addItem);
    }
    return showList;
  }

  showMainList() {
    LOG('--> showMainList : ${eventShowList.length}');
    if (eventListType == EventListType.map) {
      return LayoutBuilder(
        builder: (context, layout) {
          final itemWidth  = layout.maxWidth / 3.5;
          final itemHeight = itemWidth * 1.85;
          return Stack(
            children: [
              GoogleMapWidget(
                eventShowList,
                key: mapKey,
                mapHeight: layout.maxHeight,
                onMarkerSelected: (selectItem) {
                  LOG('--> onMarkerSelected : ${selectItem['title']} / ${selectItem['id']}');
                },
                onCameraMoved: (pos, region) {
                  cameraPos = pos;
                  onMapRegionChanged(region);
                },
              ),
              Align(
                widthFactor: 1.25,
                heightFactor: 3.0,
                child: showTimePicker(),
              ),
              BottomLeftAlign(
                child: Container(
                  height: itemHeight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                    children: showEventList(itemWidth, itemHeight),
                  ),
                )
              )
            ],
          );
        }
      );
    } else {
      return ListView(
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}