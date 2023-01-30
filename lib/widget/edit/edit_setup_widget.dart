import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import '../../data/theme_manager.dart';
import '../../utils/utils.dart';

class EditSetupWidget extends StatefulWidget {
  EditSetupWidget(this.title, this.optionData, this.optionInfo, {Key? key,
    this.showAllButton = false,
    this.titlePadding = 0,
    this.customData = const {},
    this.showOption = const [],
    this.onDataChanged}) : super(key: key);

  String title;
  double titlePadding;
  JSON optionData;
  JSON optionInfo; // INFO_GOODS_OPTION...
  JSON customData;
  List<JSON> showOption;
  Function(JSON)? onDataChanged;

  bool showAllButton;

  @override
  EditSetupWidgetState createState() => EditSetupWidgetState();
}

class EditSetupWidgetState extends State<EditSetupWidget> {
  List<Widget> _itemList = [];
  JSON _linkList = {};
  int _optionCount = 0;
  bool _isShowAll = true;
  BuildContext? _context;

  initData() {
    setState(() {
      initLink();
    });
  }

  initLink() {
    _linkList = {};
    for (var item in widget.optionInfo.entries) {
      // linked switch..
      if (item.value.runtimeType != String && item.value.runtimeType != int) {
        if (item.value['parent'] != null) {
          var parentKey = item.value['parent'];
          if (_linkList[parentKey] == null) _linkList[parentKey] = {'list': [], 'type': 0};
          _linkList[parentKey]['list'].add(item.key);
        } else if (item.value['parent_rev'] != null) {
          var parentKey = item.value['parent_rev'];
          if (_linkList[parentKey] == null) _linkList[parentKey] = {'list': [], 'type': 1};
          _linkList[parentKey]['list'].add(item.key);
        }
      }
    }
    checkSwitchAll();
  }

  refreshSwitch() {
    LOG('--> refreshSwitch : ${widget.optionData}');
    _itemList = [];
    _optionCount = 0;
    for (var item in widget.optionInfo.entries) {
      if (item.value.runtimeType != String && item.value.runtimeType != int) {
        var _isAdd = true;
        if (item.value['customShow'] != null) {
          _isAdd = false;
          if (JSON_NOT_EMPTY(widget.customData)) {
            for (var customItem in widget.customData.entries) {
              if (STR(customItem.value['customId']) == STR(item.value['customShow'])) {
                _isAdd = true;
                break;
              }
            }
          }
        }
        if (JSON_NOT_EMPTY(widget.showOption)) {
          for (var showItem in widget.showOption) {
            if (STR(showItem['showId']) == item.key ||
                STR(showItem['showId']) == item.value['parent'] ||
                STR(showItem['showId']) == item.value['parent_rev']) {
              _isAdd = BOL(showItem['value']);
              break;
            }
          }
        }
        if (_isAdd) {
          // if (BOL(item.value['value']) && !widget.optionData.containsKey(item.key)) {
          //   widget.optionData[item.key] = '1';
          // }
          widget.optionData[item.key] ??= item.value['value'];
          _optionCount++;
          _itemList.add(SwitchListTile(
            key: Key(item.value['index'].toString()),
            title: Text(STR(item.value['title']), style: ItemTitleStyle(context)),
            secondary: item.value['parent'] != null || item.value['parent_rev'] != null ? Image.asset(
                'assets/ui/sub_line_00.png', color: Theme.of(_context!).hintColor) : null,
            contentPadding: EdgeInsets.all(0),
            subtitle: Text(DESC(item.value['desc']), style: DescBodyExStyle(context)),
            dense: true,
            value: BOL(widget.optionData[item.key]),
            onChanged: (value) {
              setSwitch(item.key, value);
            },
          ));
        }
      }
    }
    _itemList.sort((a,b) => a.key.toString().compareTo(b.key.toString()));
  }

  checkLink(String checkKey) {
    var result = true;
    if (_linkList.isNotEmpty) {
      _linkList.forEach((key, value) {
        value['list'].forEach((item) {
          if (item == checkKey) {
            if (value['type'] == 0 && !BOL(widget.optionData[key])) result = false;
            if (value['type'] == 1 && BOL(widget.optionData[key])) result = false;
          }
        });
      });
    }
    return result;
  }

  setSwitch(String key, bool value) {
    if (value) value = checkLink(key);
    setState(() {
      widget.optionData[key] = value ? '1' : '';
      if (_linkList[key] != null &&
          ((_linkList[key]['type'] == 0 && !BOL(widget.optionData[key])) ||
           (_linkList[key]['type'] == 1 && BOL(widget.optionData[key])))) {
          _linkList[key]['list'].forEach((itemKey) {
            widget.optionData[itemKey] = '';
        });
      }
      checkSwitchAll();
      refreshSwitch();
      if (widget.onDataChanged != null) widget.onDataChanged!(widget.optionData);
    });
  }

  setSwitchAll(bool value) {
    setState(() {
      for (var item in widget.optionInfo.entries) {
        if (item.value.runtimeType != String && item.value.runtimeType != int) {
          var key = item.key;
          if (value) value = checkLink(key);
            widget.optionData[key] = value ? '1' : '';
            if (_linkList[key] != null &&
                ((_linkList[key]['type'] == 0 && !BOL(widget.optionData[key])) ||
                    (_linkList[key]['type'] == 1 && BOL(widget.optionData[key])))) {
              _linkList[key]['list'].forEach((itemKey) {
                widget.optionData[itemKey] = '';
              });
            }
        }
      }
      refreshSwitch();
      if (widget.onDataChanged != null) widget.onDataChanged!(widget.optionData);
    });
  }

  checkSwitchAll() {
    int nowCount = 0;
    for (var item in widget.optionData.entries) {
      if (BOL(widget.optionData[item.key])) nowCount++;
    }
    _isShowAll = nowCount > 0;
  }

  @override
  void initState() {
    initLink();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('--> widget.optionInfo : ${widget.optionData} / ${widget.optionInfo}');
    _context = context;
    refreshSwitch();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Container(
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: widget.titlePadding),
            child: Row(
              children: [
                SubTitle(context, widget.title),
                if (widget.showAllButton)...[
                  Expanded(
                    child: SizedBox(height: 10),
                  ),
                  Switch(
                    value: _isShowAll, onChanged: (status) {
                      setState(() {
                        _isShowAll = status;
                        setSwitchAll(status);
                      });
                    }
                  )
                ],
              ]
            )
          ),
          SizedBox(height: 10),
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                  // border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Column(
                children: _itemList,
            ),
          )
        ]
      )
    );
  }
}
