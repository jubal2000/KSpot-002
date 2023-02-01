
import 'package:address_search_field/address_search_field.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/repository/event_repository.dart';

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
  Map<String, EventModel>? eventList;
  BuildContext? buildContext;
  List<JSON>    eventShowList = [];
  Future<Map<String, EventModel>>? initData;
  final eventRepo = EventRepository();
  final placeRepo = PlaceRepository();

  // for Edit..
  final _imageGalleryKey  = GlobalKey();
  final JSON imageList = {};
  var isTimePickerExtend = false;
  var eventListType = EventListType.map;

  init(BuildContext context) {
    buildContext = context;
    getEventList();
  }

  getEventList() {
    initData = eventRepo.getEventListFromCountry(AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
  }

  refreshShowList(Map<String, EventModel> data) async {
    eventShowList = [];
    for (var item in data.entries) {
      final showItem = item.value.toJson();
      final placeInfo = await placeRepo.getPlaceFromId(item.value.placeId);
      if (placeInfo != null) {
        showItem['address'] = placeInfo.address.toJson();
        LOG('--> checkDateTimeShow : ${item.value.getTimeDataMap} / ${AppData.currentDate.toString()}');
        if (checkDateTimeShow(item.value.getTimeDataMap, AppData.currentDate)) {
          LOG('--> eventShowList add : ${showItem['id']}');
          eventShowList.add(showItem);
        }
      }
    }
    LOG('--> eventShowList : ${eventShowList.length}');
    return eventShowList;
  }

  addMainData(EventModel mainItem) {
    eventList ??= {};
    eventList![mainItem.id] = mainItem;
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
              ),
              Align(
                widthFactor: 1.25,
                heightFactor: 2.8,
                child: showTimePicker(),
              ),
              BottomCenterAlign(
                child: Container(
                  width: Get.size.width,
                  height: itemHeight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                    children: eventShowList.map((item) => Container(
                      width: itemWidth,
                      height: itemHeight,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      child: EventSquareItem(
                        item,
                        backgroundColor: Theme.of(context).canvasColor,
                        padding: EdgeInsets.zero,
                        imageHeight: itemHeight * 0.5,
                        titleStyle: CardTitleStyle(buildContext!),
                        descStyle: CardDescStyle(buildContext!),
                        onSelected: (key, status) {

                        },
                      )
                    )).toList(),
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