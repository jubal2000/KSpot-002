import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../utils/local_utils.dart';
import '../../utils/utils.dart';

enum EditListType {
  address,
  user,
  place,
  goods,
  event,
  desc,
  category,
  info,
  sns,
  manager,
  instructor,
  extend,
  timeRange,
  day,
  exDay,
  reserve,
  customField,
}

Widget EditListWidget(BuildContext context, JSON? listItem, EditListType type, Function(EditListType, JSON)? onAddAction, Function(EditListType, String, int)? onSelected, {bool enabled =  true}) {
  return EditListSortWidget(listItem ?? {}, type, onAddAction: onAddAction, onSelected: onSelected, enabled: enabled);
}

class EditListSortWidget extends StatefulWidget {
  EditListSortWidget(this.listItem, this.type,
      {Key? key,
        this.textLine = 1,
        this.padding = const EdgeInsets.only(top: 0),
        this.enabled = true,
        this.onAddAction,
        this.onSelected,
        this.onChanged,
        this.onListItemChanged}) : super(key: key);

  JSON listItem;
  EditListType type;
  int textLine;
  EdgeInsets padding;
  bool enabled;
  Function(EditListType, JSON)? onAddAction;
  Function(EditListType, String, int)? onSelected;
  Function(EditListType, List<String>)? onChanged;
  Function(EditListType, JSON)? onListItemChanged;

  @override
  _EditListSortState createState() => _EditListSortState();
}

class _EditListSortState extends State<EditListSortWidget> {
  var titleText = ['ADDRESS LINK', 'FOLLOW LINK', 'SPOT LINK', 'EVENT LINK', 'GOODS LINK',
    'GOODS DESCRIPTION', 'CATEGORY', 'GOODS INFO', 'SNS LINK', 'MANAGER', 'INSTRUCTOR',
    'EVENT FIELD', 'TIME SETTING', 'DATE SELECT', 'EXCEPT DATE SELECT', 'RESERVATION', 'CUSTOM FIELD'];

  var descText  = ['', '', '', '', '', '', '', '', '', '', '', '핫플에서 이벤트 추가시 기본으로 입력할 수 있는 필드(예: 파티 DJ)', '', '', '', '', ''];

  // var addText   = ['장소 링크 추가', '친구 링크 추가', 'SPOT LINK ADD', 'EVENT LINK ADD', 'GOODS LINK ADD',
  //   '상품 내용 추가', '카테고리 추가', '상품 정보 추가', 'SNS 링크 추가', 'Manager Add', 'Instructor Add',
  //   'Event Field Add', 'Time Range Add', 'Day Select', 'Except Day Select', 'Reservation Add', 'Custom Field Add'];

  var showTextField  = ['address1', 'nickName', 'title', 'title', 'title', 'title', 'title', 'title',
    'link', 'nickName', 'nickName', 'titleEx', 'title', 'date', 'date', 'descEx', 'title'];

  var itemIcon  = [Icons.location_on_outlined, Icons.person, Icons.link, Icons.link, Icons.link,
    Icons.description_outlined, Icons.category_outlined, Icons.info_outline, Icons.share, Icons.account_circle_rounded, Icons.account_circle_rounded,
    Icons.text_fields, Icons.access_time, Icons.event_available, Icons.event_busy_outlined, Icons.event_available_outlined, Icons.text_fields];

  List<JSON> _listData = [];
  List<Widget> _itemList = [];

  refreshData() {
    _listData = [];
    if (JSON_NOT_EMPTY(widget.listItem)) {
      _listData = List<JSON>.from(widget.listItem.entries.map((element) => element.value).toList());
    }
    refreshList();
  }

  refreshList() {
    _itemList = [];
    if (_listData.isNotEmpty) {
      _itemList = _listData.map((item) {
        LOG('----> _itemList item : $item');
        JSON _data = {
          'image': widget.listItem[item['id']] != null ? STR(widget.listItem[item['id']]['icon']) : '',
          'title': item[showTextField[widget.type.index]] ?? '',
          'desc': item['desc'] ?? item['titleEx'] ?? '',
        };
        switch (widget.type) {
          case EditListType.reserve:
            break;
        }
        return Container(
          key: GlobalKey(),
          margin: EdgeInsets.symmetric(vertical: 5),
          // color: Theme.of(context).backgroundColor.withOpacity(0.25),
            // decoration: BoxDecoration(
            //   color: Theme.of(context).backgroundColor.withOpacity(0.25),
            //     border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.0),
            //     borderRadius: BorderRadius.all(Radius.circular(8))
            // ),
            child: EditListItem(
              context,
              widget.type,
              item['id'] ?? item['userId'] ??'',
              _listData.indexOf(item),
              itemIcon[widget.type.index],
              _data,
              item['image'],
              item['backPic'],
              ItemTitleStyle(context),
              widget.onChanged != null || widget.onListItemChanged != null,
              BOL(item['disabled']),
              (EditListType type, String key, int status) {
                LOG('--> EditListItem select : $type / $key / $status');
                if (!widget.enabled) return;
                if (type == EditListType.customField && status == 0) {
                  var itemKey = widget.listItem[key]['customId'];
                  var infoItem = AppData.INFO_CUSTOMFIELD[itemKey];
                  if (infoItem != null) {
                    switch(STR(infoItem['type'])) {
                      case 'user':
                        AppData.listSelectData = {};
                        if (widget.listItem[key]['userData'] != null) {
                          for (var user in widget.listItem[key]['userData']) {
                            AppData.listSelectData[user['userId']] = {'id': user['userId'], 'pic': user['userPic'], 'nickName': user['userName']};
                          }
                        }
                      //   LOG('--> AppData.listSelectData : ${AppData.listSelectData}');
                      //   Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      //       FollowScreen(AppData.userInfo, topTitle: 'FOLLOWER SELECT'.tr, isShowMe: true, isSelectable: true))).then((value) {
                      //   setState(() {
                      //     widget.listItem[key]['desc'] = '';
                      //     if (AppData.listSelectData.isNotEmpty) {
                      //       widget.listItem[key]['userData'] = [];
                      //       for (var item in AppData.listSelectData.entries) {
                      //         widget.listItem[key]['userData'].add({
                      //           'id': item.key,
                      //           'userId': item.key,
                      //           'userPic': STR(item.value['pic']),
                      //           'userName': STR(item.value['nickName'])
                      //         });
                      //         if (widget.listItem[key]['desc'].isNotEmpty) widget.listItem[key]['desc'] += ', ';
                      //         widget.listItem[key]['desc'] += STR(item.value['nickName']);
                      //       }
                      //     } else {
                      //       widget.listItem[key].remove('userData');
                      //     }
                      //     LOG("--> widget.listItem[$key]['userData'] : ${widget.listItem[key]}");
                      //     if (widget.onListItemChanged != null) widget.onListItemChanged!(widget.type, widget.listItem);
                      //   });
                      // });
                      break;
                    case 'image':
                      picLocalImage(key);
                      break;
                    default:
                      TextInputType? textInputType;
                      switch (infoItem['inputType']) {
                        case 'text'   : textInputType = TextInputType.multiline; break;
                        case 'number' : textInputType = TextInputType.number; break;
                        case 'email'  : textInputType = TextInputType.emailAddress; break;
                        case 'phone'  : textInputType = TextInputType.number; break;
                        case 'price'  :
                          showPriceInputDialog(context, STR(infoItem['title'] ?? 'Price'.tr), STR(infoItem['title']), item['priceData'] ?? {}).then((result) {
                            if (result.isNotEmpty) {
                              setState(() {
                                widget.listItem[key]['priceData'] = result;
                                widget.listItem[key]['desc'] = result['desc'];
                                AppData.currentCurrency = result['currency'];
                                LOG('--> showPriceInputDialog result : $result / ${AppData.currentCurrency}');
                                AppData.localInfo['currency'] = AppData.currentCurrency;
                                writeLocalInfo();
                              });
                            }
                          });
                          break;
                        case '2text'  :
                          widget.listItem[key]['textData'] ??= {'title':'', 'desc':''};
                          showDoubleTextInputDialog(context, STR(infoItem['title'] ?? 'Text input field'.tr), widget.listItem[key]['textData'], 'Title'.tr, 'Desc'.tr).then((result) {
                            if (result.isNotEmpty) {
                              widget.listItem[key]['textData'] = result;
                              widget.listItem[key]['title']    = result['title'];
                              widget.listItem[key]['desc']     = result['desc'];
                              LOG('--> showDoubleTextInputDialog result : $result / ${widget.listItem[key]['desc']}');
                            }
                          });
                          break;
                      }
                      if (textInputType != null) {
                        showTextInputTypeDialog(context, item['title'], '', STR(widget.listItem[key]['desc']), 1,
                            textInputType == TextInputType.multiline ? 5 : 1,
                            textInputType).then((result) {
                          if (result.isNotEmpty) {
                            setState(() {
                              widget.listItem[key]['desc'] = result;
                              if (widget.onListItemChanged != null) widget.onListItemChanged!(widget.type, widget.listItem);
                            });
                          }
                        });
                      }
                      break;
                  }
                }
              } else {
                if (widget.onSelected != null) widget.onSelected!(type, key, status);
              }
            },
            iconEx: item['icon'] ?? ''
          )
        );
      }).toList();
    }
  }

  picLocalImage(String key) async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      var imageUrl = await ShowImageCroper(image.path);
      var imageData = await ReadFileByte(imageUrl);
      imageData = await resizeImage(imageData!.buffer.asUint8List(), 512) as Uint8List;
      setState(() {
        widget.listItem[key]['image'] = imageData;
      });
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
      padding: widget.padding,
      child: Column(
        children: [
          SubTitle(context, titleText[widget.type.index].tr),
          ReorderableListView(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8.sp))
                ),
                child: child,
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) newIndex -= 1;
              setState(() {
                var item = _listData.removeAt(oldIndex);
                _listData.insert(newIndex, item);
                refreshList();
                widget.listItem = JSON.from({});
                for (var item in _listData) {
                  widget.listItem[item['id']] = item;
                }
                if (widget.onListItemChanged != null) widget.onListItemChanged!(widget.type, widget.listItem);
              });
            },
            children: _itemList,
          ),
          SizedBox(height: 5.w),
          Container(
            height: descText[widget.type.index].isNotEmpty ? 50.w : 40.w,
            child: ElevatedButton(
              onPressed: () {
                if (!widget.enabled) return;
                if (widget.onAddAction != null) widget.onAddAction!(widget.type, widget.listItem ?? {});
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).splashColor.withOpacity(0.1),
                shadowColor: Colors.transparent,
                minimumSize: Size.zero, // Set this
                padding: EdgeInsets.only(left: 5.w), // and this
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.sp),
                )
              ),
              child: Row(
                children: [
                  SizedBox(width: 6.w),
                  Icon(Icons.add, size: 24.sp, color: Theme.of(context).hintColor.withOpacity(0.85)),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${titleText[widget.type.index].tr} ${'add'.tr}', style: DescBodyStyle(context)),
                        if (descText[widget.type.index].isNotEmpty)...[
                          SizedBox(height: 2),
                          Text(descText[widget.type.index].tr, style: DescBodyExStyle(context)),
                        ]
                      ]
                    )
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
// String image, String title, String desc
Widget EditListItem(BuildContext context, EditListType type, String key, int index,
    IconData icon, JSON data, dynamic imageData, String? backPic,
    TextStyle style, bool isCanMove, bool isDisabled, Function(EditListType, String, int)? onCallback, {String iconEx = ''}) {
  final _textController = TextEditingController();
  final _descStyle = TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.normal, fontSize: 14);

  var _isCustomField = type == EditListType.customField;
  var _height = _isCustomField ? 50.0 : 30.0;
  var _textStyle = style;
  if (isDisabled) {
    _textStyle = ItemDescStyle(context);
  }
  if (type == EditListType.customField) {
    _textController.text = STR(data['desc']);
  }
  return Container(
    // height: _height,
      child: GestureDetector(
      onTap: () {
        if (onCallback != null) onCallback(type, key, 0); // select..
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          children: [
            if (isCanMove)
              ReorderableDragStartListener(
              index: index,
              enabled: isCanMove,
              child: Container(
                  padding: EdgeInsets.only(right: 5),
                  child: Icon(Icons.drag_handle, size: 22, color: Theme.of(context).hintColor),
                ),
              ),
            if (STR(data['pic']).isNotEmpty)...[
              SizedBox(width: 5),
              showImage(data['pic'], Size(_height - 10, _height - 10)),
              SizedBox(width: 10),
            ],
            if (STR(data['pic']).isEmpty && iconEx.isEmpty && !_isCustomField)...[
              SizedBox(width: 5),
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              SizedBox(width: 10),
            ],
            if (iconEx.isNotEmpty)...[
              SizedBox(width: 5),
              SizedBox(
                width: 20,
                height: 20,
                child: showImageWidget(iconEx, BoxFit.fitHeight, color: Theme.of(context).hintColor),
              ),
              SizedBox(width: 10),
            ],
            if (_isCustomField)
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.0),
                      //   borderRadius: BorderRadius.all(Radius.circular(8))
                      // ),
                      child: Text(STR(data['title']), style: _textStyle),
                    ),
                    SizedBox(width: 5),
                    if (backPic != null)
                      showImage(backPic, Size(_height - 10, _height - 10), fit: BoxFit.fitHeight),
                    if (backPic == null && imageData != null)
                      SizedBox(
                        height: _height - 10,
                        child: Image.memory(imageData as Uint8List, fit: BoxFit.fitHeight),
                      ),
                    if (backPic == null && imageData == null)
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                          child: Text(DESC(data['desc']), style: _textStyle, maxLines: null),
                      ),
                    ),
                  ]
                )
              ),
            if (!_isCustomField)...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(STR(data['title']), style: _textStyle, maxLines: 1),
                    if (STR(data['desc']).isNotEmpty)...[
                      SizedBox(height: 5),
                      Text(DESC(data['desc']), style: _descStyle, maxLines: 2),
                    ]
                  ]
                )
              ),
            ],
            SizedBox(width: 10),
            GestureDetector(
              child: Icon(
                Icons.close,
                size: 20.0,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                if (onCallback != null) onCallback(type, key, 1); // delete..
              },
            ),
          ],
        ),
      ),
    )
  );
}

Widget EditFileListSortWidget(BuildContext context, String title, JSON listItem, Function()? onAddAction, Function(String, int)? onSelected) {
  final _addTextStyle   = TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 15);
  final _itemTextStyle  = TextStyle(color: Colors.black, fontSize: 15);
  final _subTitleStyle  = TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
  List<JSON> _listData = [];
  List<Widget> _itemList = [];

  if (listItem != null && listItem.isNotEmpty) {
    _listData = List<JSON>.from(listItem.entries.map((element) => element.value).toList());
  }

  refreshList() {
    if (_listData.isNotEmpty) {
      _itemList = _listData.map((item) {
        // log('--> EditListSortWidget item : $item');
        return Container(
            key: Key(_listData.indexOf(item).toString()),
            child: EditFileListItem(item['id'] ?? '',
                _listData.indexOf(item),
                STR(listItem[item['id']]['icon']),
                item['title'],
                _itemTextStyle,
                true,
                BOL(item['disabled']),
                onSelected)
        );
      }).toList();
    }
  }

  refreshList();

  return Column(
    children: [
      Container(
        height: 20,
        alignment: Alignment.centerLeft,
        child: Text(
          'File upload'.tr,
          style: _subTitleStyle,
        ),
      ),
      StatefulBuilder(
        builder: (context, setState) {
          return ReorderableListView(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child: child,
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) newIndex -= 1;
              setState(() {
                var item = _listData.removeAt(oldIndex);
                _listData.insert(newIndex, item);
                // var key = _keyList.removeAt(oldIndex);
                // _keyList.insert(newIndex, key);
                // if (onSorted != null) onSorted(type, _keyList);
                refreshList();
              });
            },
            children: _itemList,
          );
        }
      ),
      Container(
        height: 40,
        margin: EdgeInsets.only(top: 10),
        child: ElevatedButton(
          onPressed: () {
            if (onAddAction != null) {
              LOG('--> onAddAction');
              onAddAction();
            }
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.white,
              minimumSize: Size.zero, // Set this
              padding: EdgeInsets.only(left: 5), // and this
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey)
              )
          ),
          child: Row(
            children: [
              SizedBox(width: 6),
              Icon(Icons.add, size: 24, color: _addTextStyle.color),
              SizedBox(width: 5),
              Expanded(
                child: Text(title, style: _addTextStyle),
              ),
            ],
          ),
        ),
      )
    ],
  );
}

Widget EditFileListItem(String key, int index, String image, String title, TextStyle style, bool isCanMove, bool isDisabled, Function(String, int)? onCallback) {
  var _height = 36.0;
  var _textStyle = style;
  if (isDisabled) {
    _textStyle = TextStyle(fontSize:style.fontSize, fontWeight:style.fontWeight, color:Colors.grey);
  }
  return Container(
    height: _height,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: GestureDetector(
      onTap: () {
        if (onCallback != null) onCallback(key, 0); // select..
      },
      child: Row(
        children: [
          if (isCanMove)
            ReorderableDragStartListener(
                index: index,
                enabled: isCanMove,
                child: Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.drag_handle, size: 22),
                )
            ),
          // SizedBox(width: 10),
          SizedBox(width: 5),
          Expanded(
            child: Text(title, style: _textStyle),
          ),
          GestureDetector(
            child: Icon(
              Icons.close,
              size: 20.0,
              color: Colors.grey,
            ),
            onTap: () {
              if (onCallback != null) onCallback(key, 1); // delete..
            },
          ),
        ],
      ),
    ),
  );
}

