import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/widget/rounded_button.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:uuid/uuid.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';
import 'edit/edit_list_widget.dart';
import 'slide_timepicker_screen.dart';


class EventTimeSelectWidget extends StatefulWidget {
  EventTimeSelectWidget(this.timeInfo, {Key? key, this.title = '', this.isEdit = false}) : super(key: key);

  JSON timeInfo;
  String title;
  bool isEdit;

  @override
  _EventTimeSelectState createState() => _EventTimeSelectState();
}

enum TextType {
  title,
  startDate,
  endDate,
  startTime,
  endTime,
}

final weekText     = ['Every', '1st', '2nd', '3rd', '4th', 'Last'];
final dayWeekText  = ['Every', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class _EventTimeSelectState extends State<EventTimeSelectWidget> {
  final _textController  = List<TextEditingController>.generate(TextType.values.length, (index) => TextEditingController());
  final _tabText        = ['SELECT DAYS', 'SELECT PERIOD'];
  final _selectColor    = Colors.purple;
  final _bottomHeight   = 50.0;
  final _lineSpace      = 30.0;
  bool _isEdited = false;
  late var _selectTab   = _tabText.first;

  JSON _timeData = {};
  
  initData() {
    _timeData = {};
    _timeData.addAll(widget.timeInfo);

    _timeData['status'] ??= 1;
    _timeData['type'] ??= 0;
    _timeData['title'] ??= 'Time 1';
    _timeData['desc'] ??= '';
    _timeData['startTime'] ??= '09:00';
    _timeData['endTime'] ??= '18:00';
    _timeData['exceptDayMap'] ??= JSON.from({});
    _timeData['exceptDay'] ??= [];
    _timeData['dayMap'] ??= JSON.from({});
    _timeData['day'] ??= [];
    _timeData['week'] ??= [];
    _timeData['dayWeek'] ??= [];
    _timeData['customMap'] ??= JSON.from({});
    _timeData['customData'] ??= [];

    if (_timeData['week'].isEmpty) {
      _timeData['week'].add(weekText.first);
    }
    if (_timeData['dayWeek'].isEmpty) {
      _timeData['dayWeek'].add(dayWeekText.first);
    }
    if (STR(_timeData['startDate']).isEmpty) {
      _timeData['startDate'] = DATE_STR(DateTime.now());
    }
    if (STR(_timeData['endDate']).isEmpty) {
      _timeData['endDate'] = DATE_STR(DateTime.now().add(Duration(days: 365)));
    }
    _textController[TextType.title.index].text = STR(_timeData['title']);

    LOG('--> _timeData : ${INT(_timeData['type'])} / $_timeData');
    _selectTab = INT(_timeData['type']) == 0 ? _tabText.first : _tabText.last;

    refreshTimeData();
    createDayDataMap();
    createExDayDataMap();
    createCustomMap();
  }

  refreshTimeData() {
    if (_timeData['startDate'] != null) _textController[TextType.startDate.index].text  = STR(_timeData['startDate']);
    if (_timeData['endDate'] != null)   _textController[TextType.endDate.index].text    = STR(_timeData['endDate']);
    if (_timeData['startTime'] != null) _textController[TextType.startTime.index].text  = STR(_timeData['startTime']);
    if (_timeData['endTime'] != null)   _textController[TextType.endTime.index].text    = STR(_timeData['endTime']);
  }

  onItemAdd(EditListType type, JSON listItem) {
    AppData.listSelectData = listItem;
    switch (type) {
      case EditListType.customField:
        showCustomFieldSelectDialog(context).then((customId) {
          if (customId.isNotEmpty) {
            LOG("-->  showCustomFieldSelectDialog result : $customId / ${AppData.INFO_CUSTOMFIELD[customId]}");
            setState(() {
              var key = Uuid().v1();
              var customInfo = AppData.INFO_CUSTOMFIELD[customId];
              var title = customInfo['titleEdit'] ?? customInfo['title'];
              _timeData['customMap'][key] = {'id':key, 'title':title, 'customId':customId};
              if (customInfo['titleEx'] != null) _timeData['customMap'][key]['titleEx'] = customInfo['titleEx'];
              refreshCustomData();
            });
          }
        });
        break;
      case EditListType.day:
        showMultiDatePickerDialog(context, List<String>.from(_timeData['day']))!.then((result) {
          if (result != null) {
            setState(() {
              _timeData['day'] = LIST_DATE_SORT_ASCE(List<String>.from(result));
              createDayDataMap();
              _isEdited = true;
            });
          }
        });
        break;
      case EditListType.exDay:
        showMultiDatePickerDialog(context, List<String>.from(_timeData['exceptDay']))!.then((result) {
          if (result != null) {
            setState(() {
              _timeData['exceptDay'] = LIST_DATE_SORT_ASCE(List<String>.from(result));
              createExDayDataMap();
              _isEdited = true;
            });
          }
        });
        break;
    }
  }

  onItemSelected(EditListType type, String key, int status) {
    switch (type) {
      case EditListType.customField:
        if (status == 1) {
          showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete that field?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            setState(() {
              if (result == 1) {
                _timeData['customMap'].remove(key);
                refreshCustomData();
                _isEdited = true;
              }
            });
          });
        }
        break;
      case EditListType.day:
        if (status == 1) {
          showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete that date?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            setState(() {
              if (result == 1) {
                _timeData['dayMap'].remove(key);
                refreshDayData();
                _isEdited = true;
              }
            });
          });
        }
        break;
      case EditListType.exDay:
        showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete that date?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
          if (result != null) {
            setState(() {
              _timeData['exceptMap'].remove(key);
              createExDayDataMap();
              _isEdited = true;
            });
          }
        });
        break;
    }
  }

  onListItemChanged(EditListType type, JSON result) {
    LOG('--> onListItemChanged : $result');
    _timeData['customMap'] = result;
    refreshCustomData();
  }

  cleanDayData() {
    _timeData.remove('exceptDayMap');
    _timeData.remove('dayMap');
    _timeData.remove('customMap');

    if (_selectTab == _tabText.first) {
      _timeData.remove('startDate');
      _timeData.remove('endDate');
      _timeData.remove('exceptDay');
      _timeData.remove('week');
      _timeData.remove('dayWeek');
    } else {
      _timeData.remove('day');
    }
  }

  createExDayDataMap() {
    _timeData['exceptDayMap'] = JSON.from(jsonDecode('{}'));
    for (var item in _timeData['exceptDay']) {
      var key = Uuid().v1();
      _timeData['exceptDayMap'][key] = JSON.from(jsonDecode('{"id": "$key", "date": "$item", "index": 999}'));
    }
    LOG('----> createExDayDataMap : ${_timeData['exceptDayMap']}');
  }

  refreshExDayData() {
    _timeData['exceptDay'] = [];
    for (var item in _timeData['exceptDayMap'].entries) {
      _timeData['exceptDay'].add(STR(item.value['date']));
    }
    LOG('----> refreshExDayData : ${_timeData['exceptDay']}');
  }

  createDayDataMap() {
    _timeData['dayMap'] = JSON.from(jsonDecode('{}'));
    for (var item in _timeData['day']) {
      var key = Uuid().v1();
      _timeData['dayMap'][key] = JSON.from(jsonDecode('{"id": "$key", "date": "$item", "index": 999}'));
    }
    LOG('----> createDayDataMap : ${_timeData['dayMap']}');
  }

  refreshDayData() {
    _timeData['day'] = [];
    for (var item in _timeData['dayMap'].entries) {
      _timeData['day'].add(STR(item.value['date']));
    }
    LOG('----> refreshDayData : ${_timeData['day']}');
  }

  createCustomMap() {
    _timeData['customMap'] = JSON.from(jsonDecode('{}'));
    for (var item in _timeData['customData']) {
      LOG('----> customData item : $item');
      var key = STR(item['id']);
      _timeData['customMap'][key] = JSON.from(item);
    }
    LOG('----> createCustomMap : ${_timeData['customMap']}');
  }

  refreshCustomData() {
    _timeData['customData'] = [];
    for (var item in _timeData['customMap'].entries) {
      LOG('----> customMap item : $item');
      _timeData['customData'].add(item.value);
    }
    LOG('----> refreshCustomData : ${_timeData['customData']}');
  }

  showTimeRangePicker() {
    var startTime = DateTime.parse('2022-01-01 ${TME2(_timeData['startTime'], defaultValue: '00:00')}:00');
    var endTime   = DateTime.parse('2022-01-01 ${TME2(_timeData['endTime'  ], defaultValue: '24:00')}:00');
    Get.to(() => SlideTimePickerScreen(startTime, endTime))!.then((result) {
      if (result != null) {
        setState(() {
          LOG('--> SlideTimePickerScreen result: $result');
          _timeData['startTime']  = STR(result['startTime']) == '24:00' ? '00:00' : STR(result['startTime']);
          _timeData['endTime']    = STR(result['endTime'  ]) == '00:00' ? '24:00' : STR(result['endTime'  ]);
          refreshTimeData();
        });
      }
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LOG('--> _timeData[customData] : ${_timeData['customMap']}');
    return WillPopScope(
      onWillPop: () async {
        if (_isEdited) {
          var result = await showBackAgreeDialog(context);
          switch (result) {
            case 1:
              _timeData = {};
              break;
            default:
              return false;
          }
        }
        return true;
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.isEdit ? 'SET TIME'.tr : 'ADD TIME'.tr, style: AppBarTitleStyle(context)),
            titleSpacing: 0,
            toolbarHeight: 50,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height - 50,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE.w, 0, UI_HORIZONTAL_SPACE.w, 0),
                  child: SingleChildScrollView(
                    child: Form(
                      child: Column(
                        children: [
                          SubTitle(context, 'INFO'.tr, height: 40.0),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: _textController[TextType.title.index],
                            decoration: inputLabel(context, 'Title'.tr, ''),
                            maxLines: 1,
                            autofocus: _textController[TextType.title.index].text.isEmpty,
                            onChanged: (text) {
                                _timeData['title'] = text;
                                _isEdited = true;
                            },
                          ),
                          SizedBox(height: _lineSpace),
                          SubTitle(context, 'TYPE SELECT'.tr,
                              child: SubTitleSmall(context, '(You can choose only one type)'.tr, height: 15)),
                          SizedBox(height: 10),
                          Row(
                            children: _tabText.map((item) => Expanded(
                              child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectTab = item;
                                  _isEdited = true;
                                  _timeData['type'] = _tabText.indexOf(item);
                                  // initDayData();
                                  LOG('----> _selectTab : $_selectTab / ${_timeData['type']}');
                                });
                              },
                              child: Container(
                                height: 45.w,
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectTab == item ? Theme.of(context).colorScheme.tertiaryContainer :
                                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                  borderRadius: _tabText.indexOf(item) == 0 ? BorderRadius.only(
                                      topLeft:Radius.circular(10),
                                      bottomLeft:Radius.circular(10)
                                  ) :  BorderRadius.only(
                                      topRight:Radius.circular(10),
                                      bottomRight:Radius.circular(10)
                                  ),
                                  border: Border.all(
                                    color: _selectTab == item ?
                                      Theme.of(context).colorScheme.tertiary.withOpacity(0.8) :
                                      Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                        width: _selectTab == item ? 2.0 : 1.0),
                                ),
                                child: Text(item.tr,
                                    style: _selectTab == item ?
                                      ItemTitleHotStyle(context) : ItemTitleStyle(context),
                                    textAlign: TextAlign.center),
                              )
                            )
                          )).toList(),
                        ),
                          if (_selectTab == _tabText.first)...[
                            SizedBox(height: UI_LIST_TEXT_SPACE),
                            SubTitle(context, '${_tabText[0].tr} *', height: 60,
                                textColor: THEME_ALERT_COLOR),
                            EditListWidget(_timeData['dayMap'], EditListType.day,
                                isTitleShow: false, onItemAdd, onItemSelected),
                          ],
                        if (_selectTab != _tabText.first)...[
                          SizedBox(height: UI_LIST_TEXT_SPACE),
                          SubTitle(context, '${_tabText[1].tr} *', height: 60,
                              textColor: THEME_ALERT_COLOR),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _textController[TextType.startDate.index],
                                  decoration: inputLabel(context, 'Start date'.tr, ''),
                                  maxLines: 1,
                                  readOnly: true,
                                  textAlign: TextAlign.center,
                                  onTap: () {
                                    showDatePickerDialog(context, _timeData['startDate'] ?? CURRENT_DATE()).then((result) {
                                      LOG('----> showDatePickerDialog startDate result : $result');
                                      if (result != null) {
                                        setState(() {
                                          _timeData['startDate'] = result.toString();
                                          _textController[TextType.startDate.index].text = _timeData['startDate'];
                                          _isEdited = true;
                                        });
                                      }
                                    });
                                  },
                                )
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(' ~ '),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _textController[TextType.endDate.index],
                                  decoration: inputLabel(context, 'End date'.tr, ''),
                                  maxLines: 1,
                                  readOnly: true,
                                  textAlign: TextAlign.center,
                                  onTap: () {
                                    showDatePickerDialog(context, _timeData['endDate'] ?? CURRENT_DATE()).then((result) {
                                      LOG('----> showDatePickerDialog endDate result : $result');
                                      if (result != null) {
                                        setState(() {
                                          _timeData['endDate'] = result.toString();
                                          _textController[TextType.endDate.index].text = _timeData['endDate'];
                                          _isEdited = true;
                                        });
                                      }
                                    });
                                  },
                                )
                              ),
                            ]
                          ),
                          SizedBox(height: _lineSpace),
                          Row(
                            children: weekText.map((item) => Expanded(
                              child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_timeData['week'].contains(item)) {
                                    _timeData['week'].remove(item);
                                    if (_timeData['week'].isEmpty) {
                                      _timeData['week'].add(weekText.first);
                                    }
                                  } else {
                                    if (item == weekText.first) {
                                      _timeData['week'].clear();
                                    } else {
                                      _timeData['week'].remove(weekText.first);
                                    }
                                    _timeData['week'].add(item);
                                  }
                                  _isEdited = true;
                                  LOG('----> week : ${_timeData['week']}');
                                });
                              },
                              child: Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _timeData['week'].contains(item) ? Theme.of(context).splashColor : Theme.of(context).backgroundColor,
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(
                                      color: _timeData['week'].contains(item) ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                ),
                                child: Text(item.tr,
                                    style: _timeData['week'].contains(item) ? ItemTitleHotStyle(context) : ItemTitleStyle(context),
                                    textAlign: TextAlign.center),
                              )
                            ))).toList(),
                          ),
                          SizedBox(height: _lineSpace * 0.5),
                          Row(
                            children: dayWeekText.map((item) => Expanded(
                                flex: dayWeekText.indexOf(item) == 0 ? 2 : 1,
                                child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_timeData['dayWeek'].contains(item)) {
                                      _timeData['dayWeek'].remove(item);
                                      if (_timeData['dayWeek'].isEmpty) {
                                        _timeData['dayWeek'].add(dayWeekText.first);
                                      }
                                    } else {
                                      if (item == dayWeekText.first) {
                                        _timeData['dayWeek'].clear();
                                      } else {
                                        _timeData['dayWeek'].remove(dayWeekText.first);
                                      }
                                      _timeData['dayWeek'].add(item);
                                    }
                                    _isEdited = true;
                                    LOG('----> dayWeek : ${_timeData['dayWeek']}');
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.w),
                                  decoration: BoxDecoration(
                                    color: _timeData['dayWeek'].contains(item) ? Theme.of(context).splashColor : Theme.of(context).backgroundColor,
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    border: Border.all(
                                        color: _timeData['dayWeek'].contains(item) ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                  ),
                                  child: Text(item.tr,
                                      style: _timeData['dayWeek'].contains(item) ? ItemTitleHotStyle(context) : ItemTitleStyle(context),
                                      textAlign: TextAlign.center),
                                )
                            ))).toList(),
                          ),
                          SizedBox(height: UI_LIST_TEXT_SPACE),
                          EditListWidget(_timeData['exceptDayMap'], EditListType.exDay, onItemAdd, onItemSelected),
                        ],
                        SizedBox(height: UI_LIST_TEXT_SPACE),
                        SubTitle(context, 'TIME SELECT *'.tr, height: 60.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _textController[TextType.startTime.index],
                                decoration: inputLabel(context, 'Start time'.tr, ''),
                                maxLines: 1,
                                readOnly: true,
                                textAlign: TextAlign.center,
                                onTap: () {
                                  // showTimeRangePicker();
                                  final startTime = DateTime.parse('2022-01-01 ${TME2(_timeData['startTime'], defaultValue: '00:00')}:00');
                                  final start = PickedTime(h: startTime.hour, m: startTime.minute);
                                  showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(start.datetime)).then((result) {
                                    if (result != null) {
                                      setState(() {
                                        _timeData['startTime'] = TME2('${result.hour}:${result.minute}');
                                        _textController[TextType.startTime.index].text = _timeData['startTime'];
                                      });
                                    }
                                  });
                                },
                              )
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(' ~ ', style: ItemTitleStyle(context)),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _textController[TextType.endTime.index],
                                decoration: inputLabel(context, 'End time'.tr, ''),
                                maxLines: 1,
                                readOnly: true,
                                textAlign: TextAlign.center,
                                onTap: () {
                                  // showTimeRangePicker();
                                  final startTime = DateTime.parse('2022-01-01 ${TME2(_timeData['endTime'], defaultValue: '00:00')}:00');
                                  final start = PickedTime(h: startTime.hour, m: startTime.minute);
                                  showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(start.datetime)).then((result) {
                                    if (result != null) {
                                      setState(() {
                                        _timeData['endTime'] = TME2('${result.hour}:${result.minute}');
                                        _textController[TextType.endTime.index].text = _timeData['endTime'];
                                      });
                                    }
                                  });
                                },
                              )
                            ),
                          ]
                        ),
                        SizedBox(height: UI_LIST_TEXT_SPACE),
                        EditListSortWidget(_timeData['customMap'], EditListType.customField,
                             onItemAdd, onItemSelected, onListItemChanged: onListItemChanged),
                        SizedBox(height: _bottomHeight.w + 20),
                      ]
                    )
                    )
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: _selectTab == _tabText.first &&
                          JSON_EMPTY(_timeData['day']) ? Colors.grey :
                          Theme.of(context).primaryColor,
                        shadowColor: Colors.transparent,
                        minimumSize: Size(double.infinity, _bottomHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        )
                      ),
                      child: Text('Done'.tr, style: ItemTitleLargeInverseStyle(context)),
                      onPressed: () {
                        if (_selectTab == _tabText.first && JSON_EMPTY(_timeData['day'])) {
                          ShowToast('Please select a date'.tr);
                          return;
                        // } else if (_selectTab == _tabText[1]) {
                        //   if (STR(_timeData['startDate']).isEmpty) {
                        //
                        //   }
                        }
                        cleanDayData();
                        LOG('----> back : $_timeData');
                        Get.back(result: _timeData);
                      },
                    )
                  )
                )
              ]
            )
          ),
        )
      )
    );
  }
}

