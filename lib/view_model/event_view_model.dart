
import 'package:address_search_field/address_search_field.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/repository/event_repository.dart';
import 'package:kspot_002/widget/main_list_item.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../repository/place_repository.dart';
import '../utils/utils.dart';
import '../widget/content_item_card.dart';
import '../widget/google_map_widget.dart';

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

  var cameraPos = CameraPosition(target: LatLng(0,0));
  var isTimePickerExtend = false;
  var eventListType = EventListType.map;

  init(BuildContext context) {
    buildContext = context;
    mapBounds = null;
    getEventList();
  }

  getEventList() {
    initData ??= eventRepo.getEventListFromCountry(AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
  }

  Future<List<JSON>> refreshShowList() async {
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
    LOG('--> eventShowList : ${result.length}');
    return result;
  }

  showTimePicker() {
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      child: Container(
        width: isTimePickerExtend ? Get.width : 66,
        height: UI_DATE_PICKER_HEIGHT,
        color: Theme.of(buildContext!).canvasColor.withOpacity(isTimePickerExtend ? 0.5 : 0),
        child: DatePicker(
          // selectDate.subtract(Duration(days: 30)),
          isTimePickerExtend ? DateTime.now() : AppData.currentDate,
          width: 60.0,
          height: 60.0,
          initialSelectedDate: AppData.currentDate,
          selectionColor: Theme.of(buildContext!).primaryColor,
          locale: Get.locale.toString(),
          onDateChange: (date) {
            // New date selected
            if (isTimePickerExtend) {
              isTimePickerExtend = AppData.currentDate != date;
              AppData.currentDate = date;
            } else {
              isTimePickerExtend = true;
            }
            notifyListeners();
          },
        ),
      ),
    );
  }
q
  onMapRegionChanged(region) async {
    mapBounds = region;
    List<JSON> tmpList = await refreshShowList();
    if (tmpList.equals(eventShowList)) {
      LOG('--> onMapRegionChanged cancel : ${tmpList.length} / ${eventShowList.length}');
      return false;
    }
    eventShowList = tmpList;
    LOG('--> onMapRegionChanged update : ${tmpList.length} / ${eventShowList.length}');
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
            backgroundColor: Theme.of(buildContext!).canvasColor,
            padding: EdgeInsets.zero,
            imageHeight: itemHeight * 0.5,
            titleStyle: CardTitleStyle(buildContext!),
            descStyle: CardDescStyle(buildContext!),
            onSelected: (key, status) {

            },
          )
        );
      listItemData[item['id']] = addItem;
      showList.add(addItem);
    }
    return showList;
  }

  showMainList() {
    if (eventListType == EventListType.map) {
      return LayoutBuilder(
        builder: (context, layout) {
          final itemWidth  = layout.maxWidth / 3.5;
          final itemHeight = itemWidth * 2.0;
          return Stack(
            children: [
              GoogleMapWidget(
                eventShowList,
                mapHeight: layout.maxHeight,
                onMarkerSelected: (selectItem) {
                  LOG('--> onMarkerSelected : ${selectItem['title']} / ${selectItem['id']}');
                  // _selectPlace.clear();
                  // _selectPlace[selectItem['id']] = selectItem;
                  // _listController.animateTo(0, curve: Curves.linear, duration: Duration(milliseconds: 200));
                  // refreshData();
                },
                onCameraMoved: (pos, region) {
                  cameraPos = pos;
                  onMapRegionChanged(region);
                },
              ),
              Align(
                widthFactor: 1.25,
                heightFactor: 2.8,
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