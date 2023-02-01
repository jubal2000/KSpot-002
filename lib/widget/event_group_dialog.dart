// import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:helpers/helpers.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/theme_manager.dart';
import '../models/event_group_model.dart';
import '../repository/event_group_repository.dart';
import '../utils/local_utils.dart';
import '../utils/utils.dart';
import 'content_item_card.dart';

Future<EventGroupModel?> EventGroupSelectDialog(
    BuildContext mainContext,
    String groupId, // selected group id..
    String contentTypeId, // selected content type..
    {
      List<String>? orderList,
      var selectMax = 1,
      var topTitle = '',
      var isGridMode = true,
      var isShowCancel = false,
      var isSelectable = false,
      Function(List<String>)? onOrderChanged,
    }) async {
  final repo = EventGroupRepository();
  final _gridController = List.generate(2, (index) => ScrollController());
  const _padding = 3.0;
  var _dialogHeight = 100.0;

  var _showCountrySelect = false;
  var _isReorderMode = false;

  List<Widget> _placeSelectList = [];
  List<Widget> _placeLikeList = [];
  List<Widget> _placeAllList = [];
  List<Widget> _placeGridList = [];

  Future<JSON>? placeGroupInit;
  JSON placeGroupData = {};

  refresh(BuildContext context) {
    _placeSelectList = [];
    _placeAllList = [];
    _placeLikeList = [];
    var itemIndex = 0;
    final borderColor = Theme.of(context).primaryColor.withOpacity(0.5);
    for (var item in placeGroupData.entries) {
      final isCurrentGroup = groupId == item.value.id;
      Widget addWidget;
      if (isGridMode) {
        addWidget = StatefulBuilder(
            key: Key(item.key),
            builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                // AppData.currentPlaceGroup = item.value;
                // AppData.localInfo['eventGroup'] = item.value;
                // writeLocalInfo();
                Navigator.of(context).pop(item.value);
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: isCurrentGroup ? 4 : 0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: showSizedImage(item.value.pic, UI_ITEM_HEIGHT - _padding * 2),
                    ),
                    BottomCenterAlign(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(item.value.title.toUpperCase(), style: ItemDescOutlineExStyle(context, borderColor: Colors.black38), maxLines: 3)
                      ),
                    ),
                  ]
                )
              )
            );
          }
        );
      } else {
        addWidget = ContentItem(
          item.value,
          key: Key(item.key),
          showType: GoodsItemCardType.placeGroup,
          padding: EdgeInsets.all(5),
          titleStyle: ItemTitleLargeStyle(context), descStyle: ItemDescStyle(context),
          showOutline: isCurrentGroup,
          outlineColor: borderColor,
          isShowExtra: false,
          onShowDetail: (key, status) {
            LOG('--> onSelected : $key / $status');
            // AppData.currentPlaceGroup = item.value;
            // AppData.localInfo['eventGroup'] = item.value;
            // writeLocalInfo();
            Navigator.of(context).pop(item.value);
          },
        );
      }
      if (item.value.contentType == contentTypeId) {
        if (isCurrentGroup) {
          _placeSelectList.add(addWidget);
        }
        else if (AppData.USER_EVENT_GROUP_LIKE.contains(item.key)) {
          _placeLikeList.add(addWidget);
        }
        else {
          _placeAllList.add(addWidget);
        }
      }
    }

    List<Widget> _tmpList = [];
    _tmpList.addAll(_placeSelectList);
    _tmpList.addAll(_placeLikeList);
    _tmpList.addAll(_placeAllList);
    LOG('--> _placeGroupData.keys : ${placeGroupData.keys.toList()}');

    _placeGridList.clear();
    AppData.localInfo['eventGroupOrder'] ??= placeGroupData.keys.toList();
    if (groupId.isNotEmpty && orderList != null) {
      var selectIndex = orderList.indexOf(groupId);
      if (selectIndex >= 0) {
        orderList.removeAt(selectIndex);
        orderList.insert(0, groupId);
        LOG('--> AppData.USER_PLACE_GROUP_ORDER orderList : $orderList');
        if (onOrderChanged != null) onOrderChanged(orderList);
      }
      // var selectIndex = AppData.localInfo['eventGroupOrder'].indexOf(groupId);
      // if (selectIndex >= 0) {
      //   AppData.localInfo['eventGroupOrder'].removeAt(selectIndex);
      //   AppData.localInfo['eventGroupOrder'].insert(0, groupId);
      //   LOG('--> AppData.USER_PLACE_GROUP_ORDER After : ${AppData.localInfo['eventGroupOrder']}');
      //   writeLocalInfo();
      // }
    }

    for (var item in AppData.localInfo['eventGroupOrder']) {
      for (var tmp in _tmpList) {
        if ((tmp.key as ValueKey).value == item) {
          _placeGridList.add(tmp);
          _tmpList.remove(tmp);
          break;
        }
      }
    }

    _placeGridList.addAll(_tmpList);
    LOG('--> _placeGridList : $_placeGridList');
  }

  refreshGroupOrder() async {
    AppData.localInfo['eventGroupOrder'] = _placeGridList.map((item) => (item.key as ValueKey).value).toList();
    LOG('--> eventGroupOrder:  ${AppData.localInfo['eventGroupOrder']}');
    writeLocalInfo();
  }

  placeGroupInit = repo.getEventGroupList();
  AppData.listSelectData.clear();

  _dialogHeight = MediaQuery.of(mainContext).size.height * 0.8;

  return await showDialog(
      context: mainContext,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: AlertDialog(
            title: Text('Spot group select'.tr),
            titleTextStyle: Theme.of(context).textTheme.subtitle1,
            contentPadding: EdgeInsets.all(10),
            insetPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 100),
            scrollable: true,
            content: Container(
                width: Get.size.width - UI_HORIZONTAL_SPACE_L * 2,
                height: _dialogHeight,
                padding: EdgeInsets.zero,
                child: FutureBuilder(
                  future: placeGroupInit,
                  builder: (context, snapshot) {
                    if (snapshot.hasData || _isReorderMode) {
                      if (!_isReorderMode) {
                        placeGroupData = snapshot.data as JSON;
                        LOG('--> placeGroupData : $placeGroupData');
                        refresh(context);
                      }
                      _isReorderMode = false;
                      LOG('--> country info : ${AppData.currentCountryFlag} - ${AppData.currentCountry} / ${AppData
                        .currentState} > $_showCountrySelect');
                      final iconColor0 = Theme.of(context).primaryColor.withOpacity(0.5);
                      final iconColor1 = Theme.of(context).primaryColor;
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SubTitleBar(context, 'CATEGORY'.tr),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    ContentTypeSelectWidget(context, contentTypeId, (result) {
                                      setState(() {
                                        contentTypeId = result;
                                        // AppData.currentCategory = result;
                                        // AppData.localInfo['currentCategory'] = AppData.currentCategory;
                                        // writeLocalInfo();
                                        refresh(context);
                                      });
                                    }),
                                  ],
                                ),
                                SizedBox(height: 10),
                                SubTitleBarEx(context, 'SPOT GROUP'.tr,
                                  child: Row(
                                    children: [
                                      Icon(Icons.grid_view, color: AppData.isEventGroupGridMode ? iconColor1 : iconColor0),
                                      SizedBox(width: 10),
                                      Icon(Icons.view_list_rounded, color: !AppData.isEventGroupGridMode ? iconColor1 : iconColor0),
                                    ],
                                  ),
                                  onActionSelect: (_) {
                                    setState(() {
                                      AppData.isEventGroupGridMode = !AppData.isEventGroupGridMode;
                                      if (AppData.isEventGroupGridMode) {
                                        AppData.localInfo['isEventGroupGridMode'] = '1';
                                      } else {
                                        AppData.localInfo.remove('isEventGroupGridMode');
                                      }
                                      writeLocalInfo();
                                      refresh(context);
                                    });
                                  }
                                ),
                              if (AppData.isEventGroupGridMode)...[
                                Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: _dialogHeight - 400,
                                    child: MasonryGridView.count(
                                      shrinkWrap: true,
                                        controller: _gridController[0],
                                        itemCount: _placeGridList.length,
                                        crossAxisCount: 4,
                                        mainAxisSpacing: _padding * 2,
                                        crossAxisSpacing: _padding * 2,
                                        itemBuilder: (BuildContext context, int index) {
                                          return _placeGridList[index];
                                        }
                                    )
                                ),
                              ],
                              if (!AppData.isEventGroupGridMode)...[
                                Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: _dialogHeight - 400,
                                    child: ReorderableListView.builder(
                                      shrinkWrap: true,
                                      // buildDefaultDragHandles: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: _placeGridList.length,
                                      itemBuilder: (context, index) {
                                        return _placeGridList[index];
                                      },
                                      proxyDecorator: (Widget child, int index, Animation<double> animation) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(15))
                                          ),
                                          child: child,
                                        );
                                      },
                                      onReorder: (int oldIndex, int newIndex) {
                                        setState(() {
                                          if (oldIndex < newIndex) newIndex -= 1;
                                          var item = _placeGridList.removeAt(oldIndex);
                                          _placeGridList.insert(newIndex, item);
                                          _isReorderMode = true;
                                          refreshGroupOrder();
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ]
                            )
                          );
                        }
                    );
                  } else {
                    return showLoadingFullPage(context);
                  }
                }
              ),
            ),
            actions: [
              if (isShowCancel)...[
                TextButton(
                  child: Text('Cancel'.tr),
                  onPressed: () {
                    if (AppData.currentEventGroup != null) {
                      Get.back();
                    }
                  },
                ),
                SizedBox(width: 20),
              ],
              TextButton(
                child: Text('Done'.tr),
                onPressed: () {
                  if (AppData.currentEventGroup != null) {
                    Get.back();
                  }
                },
              ),
            ],
          )
        );
      }
  );
}

