import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../data/app_data.dart';
import '../data/style.dart';
import '../utils/utils.dart';
import 'event_time_edit_widget.dart';


class ScheduleWidget extends StatefulWidget {
  ScheduleWidget(
      this.timeList,
      {Key? key, this.currentDate, this.showAddButton = false, this.onAction, this.onInitialSelected, this.onSelected}) : super(key: key);

  JSON timeList;
  bool showAddButton;
  DateTime? currentDate;
  CalendarView? showView;
  Function(int)? onAction;
  Function(CalendarView, DateTime?, JSON?)? onInitialSelected;
  Function(CalendarView, DateTime?, JSON?)? onSelected;

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<ScheduleWidget> {
  final _textStyle = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, shadows: outlinedText(strokeColor: Colors.black54));
  final _monthNames = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  DataSource? dayData;

  refreshData() {
    dayData = getCalendarDataSource(widget.timeList);
    JSON firstDayData = {};
    if (dayData != null && widget.currentDate != null) {
      for (Appointment item in dayData!.appointments!) {
        var checkTime = DateTime.parse(DATE_STR(item.startTime));
        // LOG('--> checkTime : $checkTime / ${widget.currentDate!} => ${checkTime.compareTo(widget.currentDate!)} / ${checkTime.compareDateTo(widget.currentDate!)}');
        if (checkTime.isSameDay(widget.currentDate!)) {
          var noteData = jsonDecode(item.notes!);
          LOG('--> firstDayData added : $noteData');
          firstDayData[noteData['key']] = noteData;
        }
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onInitialSelected != null) {
        LOG('--> firstDayData send : $firstDayData');
        widget.onInitialSelected!(AppData.calenderController!.view!, widget.currentDate, firstDayData);
      }
    });
  }

  @override
  void initState() {
    AppData.calenderController = CalendarController();
    AppData.calenderController!.view = CalendarView.month;
    refreshData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SfCalendar(
          controller: AppData.calenderController,
          initialSelectedDate: widget.currentDate,
          initialDisplayDate: widget.currentDate,
          monthViewSettings: MonthViewSettings(showTrailingAndLeadingDates: false, appointmentDisplayCount: 5),
          todayHighlightColor: Theme
              .of(context)
              .primaryColor
              .withOpacity(0.5),
          backgroundColor: Theme
              .of(context)
              .dialogBackgroundColor
              .withOpacity(0.5),
          appointmentTextStyle: _textStyle,
          dataSource: dayData,
          scheduleViewMonthHeaderBuilder: (context, detail) {
            return Container(
              width: double.infinity,
              color: Theme.of(context).primaryColorLight.withOpacity(0.1),
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 5),
                      SizedBox(
                        height: 60,
                        child: Text('${detail.date.month}', style: TextStyle(fontSize: 50, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800)),
                      ),
                      Text(_monthNames[detail.date.month-1].tr, style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text('  ${detail.date.year}', style: TextStyle(fontSize: 30, color: Theme.of(context).hintColor.withOpacity(0.8), fontWeight: FontWeight.w800)),
                ],
              )
              )
            );
          },
          // allowViewNavigation: true,
          headerHeight: 50,
          maxDate: DateTime.now().add(Duration(days: 364)),
          onTap: (detail) {
            // LOG('--> onSelected date: ${detail.date}');
            JSON? jsonData;
            if (detail.appointments != null && detail.appointments!.isNotEmpty) {
              jsonData = {};
              for (var item in detail.appointments!) {
                var jsonItem = jsonDecode(item.notes.toString());
                jsonData[jsonItem['key']] = jsonItem;
              }
              // jsonData = jsonDecode(detail.appointments!.toString());
            }
            // LOG('--> onSelected json: $jsonData');
            if (widget.onSelected != null) widget.onSelected!(AppData.calenderController!.view!, detail.date, jsonData);
          },
        ),
        Positioned(
          top: 10,
          right: 5,
          child: Row(
            children: [
              showIconButton(Icon(Icons.calendar_today_outlined, size: 20,
                  color: Theme.of(context).primaryColor.withOpacity(AppData.calenderController!.view == CalendarView.month ? 1.0 : 0.5)), () {
                setState(() {
                  AppData.calenderController!.view = CalendarView.month;
                });
              }, Size.square(30)),
              SizedBox(width: 5),
              showIconButton(Icon(Icons.view_week, size: 22,
                  color: Theme.of(context).primaryColor.withOpacity(AppData.calenderController!.view == CalendarView.week ? 1.0 : 0.5)), () {
                setState(() {
                  AppData.calenderController!.view = CalendarView.week;
                });
              }, Size.square(30)),
              SizedBox(width: 5),
              showIconButton(Icon(Icons.view_list, size: 24,
                  color: Theme.of(context).primaryColor.withOpacity(AppData.calenderController!.view == CalendarView.schedule ? 1.0 : 0.5)), () {
                setState(() {
                  AppData.calenderController!.view = CalendarView.schedule;
                });
              }, Size.square(30)),
              SizedBox(width: 5),
              showIconButton(Icon(Icons.schedule, size: 22,
                  color: Theme.of(context).primaryColor.withOpacity(AppData.calenderController!.view == CalendarView.day ? 1.0 : 0.5)), () {
                setState(() {
                  AppData.calenderController!.view = CalendarView.day;
                });
              }, Size.square(30)),
              SizedBox(width: 10),
              if (widget.showAddButton)...[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      return Colors.transparent;
                    }),
                    shadowColor: MaterialStateProperty.resolveWith((states) {
                      return Colors.transparent;
                    }),
                  ),
                  onPressed: () {
                    if (widget.onAction != null) widget.onAction!(0);
                  },
                  child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor)
                ),
              ]
            ]
          )
        ),
      ]
    );
  }
}

Appointment? setCalendarDaySource(String timeId, String eventId, String placeId, String date, JSON timeData, Color color) {
  try {
    LOG('--> _setCalendarDaySource init : $date / ${timeData['startTime']} >> ${STR(timeData['endTime'])}');
    if (STR(timeData['startTime']) == '24:00') timeData['startTime'] = '00:00';
    if (STR(timeData['endTime'  ]) == '24:00') timeData['endTime'  ] = '23:59';
    var startTime = DateTime.parse('$date ${STR(timeData['startTime'], defaultValue: '00:00')}:00');
    var endTime   = DateTime.parse('$date ${STR(timeData['endTime'  ], defaultValue: '23:59')}:59');
    // LOG('--> _setCalendarDaySource : $startTime ~ $endTime / ${DateTime.now()} - ${DateTime.now().isBefore(endTime)}');
    // if (DateTime.now().compareTo(endTime).isNegative) {
      return Appointment(
        startTime: startTime,
        endTime: endTime,
        isAllDay: false,
        subject: STR(timeData['titleEx']).isNotEmpty ? STR(timeData['titleEx']) : STR(timeData['title']),
        // notes: DESC(timeData['desc']),
        notes: '{"key":"$timeId", "eventId":"$eventId", "placeId":"$placeId", "startTime":"${timeData['startTime']}", "endTime":"${timeData['endTime']}"}',
        color: color,
        startTimeZone: '',
        endTimeZone: '',
      );
    // }
  } catch (e) {
    LOG('--> _setCalendarDaySource error : $e');
  }
  return null;
}

DataSource? getCalendarDataSource(JSON timeList) {
  List<Appointment> appointments = <Appointment>[];
  var _defaultBgColor = Colors.blueGrey;
  for (var item in timeList.entries) {
    var eventId = item.value['eventId'] ?? '';
    var placeId = item.value['placeId'] ?? '';
    LOG('--> timeList.entries item : $eventId / $placeId => $item');
    if (LIST_NOT_EMPTY(item.value['day'])) {
      for (var time in item.value['day']) {
        // LOG('--> Day Data : ${item.value['dayData'][i]} / $duration');
        var startDate = DateTime.parse(time);
        var dayStr = startDate.toString().split(' ').first;
        var markColor = COL(item.value['themeColor'], defaultValue:_defaultBgColor);
        var appoint = setCalendarDaySource(item.key, eventId, placeId, dayStr, item.value, markColor);
        if (appoint != null) appointments.add(appoint);
      }
    } else {
      // LOG('--> Date Range init : ${item.value['startDate']} ~ ${item.value['endDate']}');
      if (STR(item.value['startDate']).isEmpty) item.value['startDate'] = DateTime.now().toString().split(' ').first;
      var startDate = DateTime.parse(STR(item.value['startDate']));
      if (STR(item.value['endDate']).isEmpty) item.value['endDate'] = startDate.add(Duration(days: 364)).toString().split(' ').first;
      var endDate = DateTime.parse(STR(item.value['endDate']));
      var duration  = endDate.difference(startDate).inDays + 1;
      LOG('--> Date Range : ${item.value['startDate']} ~ ${item.value['endDate']} => $duration / ${item.value['week']}');
      for (var i=0; i<duration; i++) {
        var day = startDate.add(Duration(days: i));
        var dayStr = day.toString().split(' ').first;
        var isShow = item.value['exceptDay'] == null || !item.value['exceptDay'].contains(dayStr);
        if (isShow && LIST_NOT_EMPTY(item.value['week']) && !item.value['week'].contains(weekText.first)) {
          var wm = day.weekOfMonth;
          isShow = ((wm < weekText.length && item.value['week'].contains(weekText[wm])) || wm >= weekText.length) &&
              (wm == day.lastWeek && item.value['week'].contains(weekText.last) || wm != day.lastWeek);
          LOG('--> week [$dayStr / ${day.weekday}] : $wm / ${day.lastWeek} => $isShow');
        }
        if (isShow && LIST_NOT_EMPTY(item.value['dayWeek']) && !item.value['dayWeek'].contains(dayWeekText.first)) {
          var wm = day.weekday;
          isShow = item.value['dayWeek'].contains(dayWeekText[wm]);
          LOG('--> weekday [$dayStr] : $wm / ${dayWeekText[wm]} => $isShow');
        }
        if (isShow) {
          var markColor = COL(item.value['themeColor'], defaultValue:_defaultBgColor).withOpacity(0.75);
          var appoint = setCalendarDaySource(item.key, eventId, placeId, dayStr, item.value, markColor);
          if (appoint != null) {
            appointments.add(appoint);
          }
        } else {
          // LOG('--> exceptDayData : $dayStr');
        }
      }
    }
  }
  return appointments.isNotEmpty ? DataSource(appointments) : null;
}
