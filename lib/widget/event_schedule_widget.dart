import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/widget/schedule_widget.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../utils/utils.dart';
import 'custom_field_widget.dart';
import 'event_time_edit_widget.dart';

class EventScheduleList extends StatefulWidget {
  EventScheduleList(this.eventList, {Key? key,
    this.showAddButton = false,
    this.currentDate,
    this.onAction,
    this.onInitialSelected,
    this.onSelected}) : super(key: key);

  Map<String, EventModel> eventList;

  bool showAddButton;
  DateTime? currentDate;
  Function(int)? onAction;
  Function(CalendarView, DateTime?, JSON?)? onInitialSelected;
  Function(CalendarView, DateTime?, JSON?)? onSelected;

  @override
  _EventScheduleListState createState() => _EventScheduleListState();
}

class _EventScheduleListState extends State<EventScheduleList> {
  JSON timeData = {};

  refreshData() {
    for (var item in widget.eventList.entries) {
      // LOG('--> eventList timeData : ${item.value.timeData.toString()}');
      if (JSON_NOT_EMPTY(item.value.getTimeDataMap)) {
        for (var time in item.value.getTimeDataMap.entries) {
          LOG('--> eventList timeData : ${time.key} / ${time.value}');
          JSON addItem = time.value;
          addItem['title'  ] = STR(item.value.titleKr);
          addItem['titleEx'] = STR(item.value.title);
          addItem['desc'   ] = STR(item.value.desc);
          addItem['eventId'] = item.key;
          addItem['placeId'] = item.value.placeId;
          addItem['groupId'] = item.value.groupId;
          addItem['color'  ] = item.value.themeColor ?? 'FFFFFFFF';
          timeData[item.key] = addItem;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshData();
    return ScheduleWidget(
        timeData,
        currentDate: widget.currentDate,
        onAction: widget.onAction,
        showAddButton: widget.showAddButton,
        onInitialSelected: widget.onInitialSelected,
        onSelected: widget.onSelected);
  }
}

class ShowTimeList extends StatefulWidget {
  ShowTimeList(this.timeList, {Key? key, this.currentDate, this.showAddButton = false, this.onAction, this.onInitialSelected, this.onSelected}) : super(key: key);

  JSON timeList;
  bool showAddButton;
  DateTime? currentDate;
  Function(int)? onAction;
  Function(DateTime?, JSON?)? onInitialSelected;
  Function(DateTime?, JSON?)? onSelected;

  var _viewMode = CalendarView.month;
  JSON _itemShowFlag = {};

  @override
  _ShowTimeListState createState() => _ShowTimeListState();
}

class _ShowTimeListState extends State<ShowTimeList> {
  List<Widget> _itemList = [];

  refreshData() {
    widget._itemShowFlag.clear();
    _itemList.clear();

    for (var i = 0; i < 2; i++) {
      for (var item in widget.timeList.entries) {
        if (!widget._itemShowFlag.containsKey(item.key)) {
          var isAdd = i != 0;
          if (i == 0) {
            LOG('--> _selectEventTime [$i] : ${item.key} / ${AppData.selectEventTime}');
            isAdd = AppData.selectEventTime.containsKey(item.key);
          }
          if (isAdd) {
            LOG('--> ShowTimeList add [$i] : ${item.key}');
            widget._itemShowFlag[item.key] = item;
            _itemList.add(GestureDetector(
                onTap: () {
                  if (JSON_NOT_EMPTY(item.value['dayData'])) {
                    var currentDate = DateTime.parse(STR(item.value['dayData'].first));
                    LOG('--> select [$i] : ${item.value['dayData'].first} => $currentDate');
                    AppData.calenderController!.selectedDate = currentDate;
                  }
                },
                child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor.withOpacity(0.35),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                        color: i == 0 ? Theme.of(context).primaryColor : OutLineColor(context),
                        width: i == 0 ? 3.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (STR(item.value['title']).isNotEmpty)...[
                          Text(STR(item.value['title']), style: DescTitleStyle(context)),
                          SizedBox(height: 5),
                        ],
                        if (STR(item.value['startDate']).isNotEmpty || STR(item.value['endDate']).isNotEmpty)...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SubTitleSmall(context, '${'PERIOD'.tr} : '),
                              if (item.value['startDate'] != null)
                                Text(STR(item.value['startDate']), style: DescBodyStyle(context)),
                              Text(' ~ '),
                              Text(STR(item.value['endDate']), style: DescBodyStyle(context)),
                            ],
                          ),
                        ],
                        if (LIST_NOT_EMPTY(item.value['dayData']))...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SubTitleSmall(context, '${'DATE'.tr} : '),
                              Expanded(
                                child: TagTextList(context, List<String>.from(item.value['dayData']), headTitle: '',
                                  showBackground: false, onSelected: (date) {
                                  LOG('--> TagTextList Select : $date');
                                  widget.currentDate = DateTime.parse(date);
                                  AppData.calenderController!.selectedDate = widget.currentDate;
                                }),
                              )
                            ],
                          ),
                        ],
                        if (LIST_NOT_EMPTY(item.value['week']) && STR(item.value['week'].first) != weekText.first)...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SubTitleSmall(context, '${'WEEK'.tr} : '),
                              Row(
                                children: List<Widget>.from(item.value['week'].map((item) =>
                                    Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(STR(item), style: DescBodyExStyle(context))
                                    )).toList()),
                              )
                            ],
                          ),
                        ],
                        if (LIST_NOT_EMPTY(item.value['dayWeek']) &&
                            STR(item.value['dayWeek'].first) != dayWeekText.first)...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SubTitleSmall(context, '${'DAY OF WEEK'.tr} : '),
                              Row(
                                children: List<Widget>.from(item.value['dayWeek'].map((item) =>
                                    Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(STR(item), style: DescBodyExStyle(context))
                                    )).toList()),
                              )
                            ],
                          ),
                        ],
                        if (STR(item.value['startTime']).isNotEmpty || STR(item.value['endTime']).isNotEmpty)...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SubTitleSmall(context, '${'TIME'.tr} : '),
                              if (item.value['startTime'] != null)
                                Text(STR(item.value['startTime']), style: DescBodyExStyle(context)),
                              Text(' ~ ', style: DescBodyExStyle(context)),
                              if (item.value['endTime'] != null)
                                Text(STR(item.value['endTime']), style: DescBodyExStyle(context)),
                            ],
                          ),
                        ],
                        if (JSON_NOT_EMPTY(item.value['customData']))...[
                          showHorizontalDivider(Size(double.infinity * 0.9, 10), color: LineColor(context)),
                          ShowCustomField(context, item.value['customData']),
                          SizedBox(height: 5),
                        ],
                      ],
                    )
                )
            ));
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshData();
    return Container(
        width: double.infinity,
        child: Column(
            children: [
              ScheduleWidget(widget.timeList, currentDate: widget.currentDate, showAddButton: widget.showAddButton, onAction: widget.onAction,
                  onInitialSelected: (view, date, jsonData) {
                    LOG('--> ScheduleWidget onInitialSelected : $view, $date, $jsonData');
                    widget._viewMode = view;
                    AppData.selectEventTime = jsonData ?? {};
                    if (widget.onInitialSelected != null) widget.onInitialSelected!(date, jsonData);
                  },
                  onSelected: (view, date, jsonData) {
                    LOG('--> ScheduleWidget onSelected : $view, $date, $jsonData');
                    // if (widget.currentDate != date || JSON_NOT_EMPTY(jsonData)) {
                    setState(() {
                      widget.currentDate = date;
                      widget._viewMode = view;
                      AppData.selectEventTime = jsonData ?? {};
                      if (widget.onSelected != null) widget.onSelected!(date, jsonData);
                    });
                    // }
                  }
              ),
              SizedBox(height: 10),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _itemList,
                  )
              )
            ]
        )
    );
  }
}
