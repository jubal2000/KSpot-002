import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/widget/slide_time_picker.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:intl/intl.dart' as intl;

import '../data/theme_manager.dart';
import '../utils/utils.dart';

class SlideTimePickerScreen extends StatefulWidget {
  SlideTimePickerScreen(this.startTime, this.endTime, {Key? key}) : super(key: key);

  DateTime startTime;
  DateTime endTime;

  @override
  _SlideTimePickerScreenState createState() => _SlideTimePickerScreenState();
}

class _SlideTimePickerScreenState extends State<SlideTimePickerScreen> {
  final _clockTimeFormat = ClockTimeFormat.twentyFourHours;
  final _topHeight = 50.0;
  final _pickerKey = GlobalKey();

  PickedTime _startTime = PickedTime(h: 0, m: 0);
  PickedTime _endTime = PickedTime(h: 8, m: 0);
  PickedTime _intervalTime = PickedTime(h: 0, m: 0);

  var _clockSize = 260.0;

  @override
  void initState() {
    super.initState();
    _startTime  = PickedTime(h: widget.startTime.hour, m: widget.startTime.minute);
    var end = PickedTime(h: widget.endTime.hour, m: widget.endTime.minute);
    _endTime = end.h == 0 && end.m == 0 ? PickedTime(h: 24, m: 0) : end;
    _intervalTime = formatIntervalTime(
        init: _startTime, end: _endTime, clockTimeFormat: _clockTimeFormat);
  }

  @override
  Widget build(BuildContext context) {
    _clockSize = MediaQuery.of(context).size.width * 0.85;
    LOG('--> SlideTimePickerScreen => start : ${_startTime.h}:${_startTime.m} ~ ${_endTime.h}:${_endTime.m}');
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select Time Range'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: _topHeight,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - _topHeight,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SlideTimePicker(
                    key: _pickerKey,
                    initTime: _startTime,
                    endTime: _endTime,
                    height: _clockSize,
                    width: _clockSize,
                    onSelectionChange: _updateLabels,
                    onSelectionEnd: (a, b, c) => LOG(
                        '--> onSelectionEnd => start : ${a.h}:${a.m}, end : ${b.h}:${b.m}'),
                    primarySectors: _clockTimeFormat.value,
                    secondarySectors: _clockTimeFormat.value * 2,
                    decoration: TimePickerDecoration(
                      baseColor: Theme.of(context).canvasColor,
                      sweepDecoration: TimePickerSweepDecoration(
                        pickerStrokeWidth: 35.0,
                        pickerColor: Theme.of(context).colorScheme.primary,
                      ),
                      initHandlerDecoration: TimePickerHandlerDecoration(
                        color: Theme.of(context).canvasColor,
                        shape: BoxShape.circle,
                        radius: 16.0,
                        icon: Icon(
                          Icons.power_settings_new_outlined,
                          size: 20.0,
                          color: Theme.of(context).indicatorColor,
                        ),
                      ),
                      endHandlerDecoration: TimePickerHandlerDecoration(
                        color: Theme.of(context).canvasColor,
                        shape: BoxShape.circle,
                        radius: 16.0,
                        icon: Icon(
                          Icons.notifications_active_outlined,
                          size: 20.0,
                          color: Theme.of(context).indicatorColor,
                        ),
                      ),
                      primarySectorsDecoration: TimePickerSectorDecoration(
                        color: Theme.of(context).indicatorColor,
                        width: 1.0,
                        size: 4.0,
                        radiusPadding: 30.0,
                      ),
                      secondarySectorsDecoration: TimePickerSectorDecoration(
                        color: Theme.of(context).hintColor,
                        width: 1.0,
                        size: 2.0,
                        radiusPadding: 30.0,
                      ),
                      clockNumberDecoration: TimePickerClockNumberDecoration(
                        defaultTextColor: Theme.of(context).indicatorColor,
                        defaultFontSize: 10.0,
                        scaleFactor: 2.3,
                        showNumberIndicators: true,
                        clockTimeFormat: _clockTimeFormat,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(62.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${intl.NumberFormat('00').format(_intervalTime.h)}:${intl.NumberFormat('00').format(_intervalTime.m)}',
                            style: TextStyle(
                                fontSize: 30.0,
                                color: Theme.of(context).indicatorColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _timeWidget(
                        context,
                        'START TIME'.tr,
                        _startTime,
                        Icon(
                          Icons.power_settings_new_outlined,
                          size: 25.0,
                          color: Theme.of(context).indicatorColor,
                        ),
                        () {
                          showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_startTime.datetime)).then((result) {
                            if (result != null) {
                              setState(() {
                                var state = _pickerKey.currentState as SlideTimePickerState;
                                state.refreshData(_startTime, _endTime);
                                _startTime = PickedTime(h:result.hour, m:result.minute);
                              });
                            }
                          });
                        }
                      ),
                      _timeWidget(
                        context,
                        'END TIME'.tr,
                        _endTime,
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 25.0,
                          color: Theme.of(context).indicatorColor,
                        ),
                        () {
                          showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_endTime.datetime)).then((result) {
                            if (result != null) {
                              setState(() {
                                var state = _pickerKey.currentState as SlideTimePickerState;
                                state.refreshData(_startTime, _endTime);
                                _endTime = PickedTime(h:result.hour, m:result.minute);
                              });
                            }
                          });
                        }
                      ),
                    ],
                  ),
                  SizedBox(height: 50.0),
                ]
              ),
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop({
                      'startTime': TIME_STR(_startTime.datetime),
                      'endTime': TIME_STR(_endTime.datetime),
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      // borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text('Done'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              )
            ]
          )
        )
      )
    );
  }

  Widget _timeWidget(BuildContext context, String title, PickedTime time, Icon icon, Function()? onSelected) {
    return GestureDetector(
      onTap: () {
        if (onSelected != null) onSelected();
      },
      child: Container(
        width: 150.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Text(
                '${intl.NumberFormat('00').format(time.h)}:${intl.NumberFormat('00').format(time.m)}',
                style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              icon,
            ],
          ),
        ),
      ),
    );
  }

  void _updateLabels(PickedTime init, PickedTime end, bool? status) {
    setState(() {
      _startTime = init;
      _endTime = end.h == 0 && end.m == 0 ? PickedTime(h: 24, m: 0) : end;
      _intervalTime = formatIntervalTime(
          init: _startTime, end: _endTime, clockTimeFormat: _clockTimeFormat);
    });
  }
}

extension PickedTimeHelpers on PickedTime {
  DateTime get datetime {
    return DateTime(0, 0, 0, h, m, 0);
  }
}