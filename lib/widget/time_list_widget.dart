
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/widget/schedule_widget.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';
import 'custom_field_widget.dart';
import 'event_time_edit_widget.dart';

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
  final colorList = [Colors.yellow, Colors.orange, Colors.purple, Colors.blue, Colors.teal, Colors.greenAccent];

  refreshData() {
    widget._itemShowFlag.clear();
    _itemList.clear();

    // for (var i = 0; i < 2; i++) {
    var count = 0;
      for (var item in widget.timeList.entries) {
        if (!widget._itemShowFlag.containsKey(item.key)) {
          // var isAdd = i != 0;
          // if (i == 0) {
          //   LOG('--> _selectEventTime : ${item.key} / ${AppData.selectEventTime}');
          //   isAdd = AppData.selectEventTime.containsKey(item.key);
          // }
          // if (isAdd) {
          var isAdd = AppData.selectEventTime.containsKey(item.key);
            LOG('--> ShowTimeList add : ${item.value}');
            widget._itemShowFlag[item.key] = item;
            JSON customData = {};
            if (LIST_NOT_EMPTY(item.value['customData'])) {
              for (var item in item.value['customData']) {
                customData[item['id']] = item;
              }
            }

            _itemList.add(GestureDetector(
                onTap: () {
                  if (JSON_NOT_EMPTY(item.value['day'])) {
                    var currentDate = DateTime.parse(STR(item.value['day'].first));
                    LOG('--> select : ${item.value['day'].first} => $currentDate');
                    AppData.currentDate = currentDate;
                  }
                },
                child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.35),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                        color: isAdd ? Theme.of(context).primaryColor : OutLineColor(context),
                        width: isAdd ? 2.0 : 1.0,
                        // color: i == 0 ? Theme.of(context).primaryColor : OutLineColor(context),
                        // width: i == 0 ? 3.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: colorList[count], size: 14),
                            SizedBox(width: 5),
                            Text(STR(item.value['title']), style: DescTitleStyle(context)),
                          ]
                        ),
                        if (STR(item.value['startDate']).isNotEmpty || STR(item.value['endDate']).isNotEmpty)...[
                          SizedBox(height: 5),
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
                        if (LIST_NOT_EMPTY(item.value['day']))...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SubTitleSmall(context, '${'DATE'.tr} : '),
                              Expanded(
                                child: TagTextList(context, List<String>.from(item.value['day']), onSelected: (date) {
                                  LOG('--> TagTextList Select : $date');
                                  widget.currentDate = DateTime.parse(date);
                                  AppData.currentDate = widget.currentDate!;
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
                        if (customData.isNotEmpty)...[
                          showHorizontalDivider(Size(double.infinity * 0.9, 10), color: LineColor(context)),
                          ShowCustomField(context, customData),
                          SizedBox(height: 5),
                        ],
                      ],
                    )
                )
            ));
          }
          count = (count + 1) % colorList.length;
        }
      // }
    // }
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