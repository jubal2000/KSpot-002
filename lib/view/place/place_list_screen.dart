import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:get/get.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/theme_manager.dart';
import '../../repository/place_repository.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/event_group_dialog.dart';
import '../../widget/google_map_widget.dart';
import '../../widget/like_widget.dart';

class PlaceListScreen extends StatefulWidget {
  PlaceListScreen({ Key? key,
    this.isSelectable = false,
    this.isCanNoSelect = true,
    this.selectMax = 1,
    this.topTitle = '',
    this.listSelectData})
      : super(key: key);

  bool isSelectable;
  bool isCanNoSelect;
  String topTitle;
  int selectMax;
  JSON? listSelectData;

  var _calendarView = CalendarView.month;

  @override
  _PlaceListScreenState createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> with TickerProviderStateMixin {
  final repo = PlaceRepository();
  List<AnimationController> _aniController = [];
  final _listController = ScrollController();

  final _topHeight = 40.0;
  final _padding = 5.0;
  final _showEmptyHeight = 300.0;

  List<PlaceModel> _placeDataList = [];
  List<Widget>  _placeAllList = [];
  List<Widget>  _placeMyList = [];
  List<Widget>  _placeLikeList = [];
  List<Widget>  _placeSelectList = [];
  List<Widget>  _placePromotionList = [];

  Future<Map<String, PlaceModel>>? _placeInit;
  JSON _placeList = {};
  JSON _selectJsonData = {};
  JSON _selectPlace = {};

  var _showEmptyText = '';

  initData() {
    LOG('--> PlaceListScreen init : ${AppData.currentCountry} / ${AppData.currentState} / ${AppData.currentEventGroup}');
    _placeInit = repo.getPlaceListWithCountry(AppData.currentEventGroup!.id, AppData.currentCountry, AppData.currentState);
    widget.listSelectData ??= {};
  }

  refreshCountry() {
    setState(() {
      initData();
    });
  }

  refreshData() {
    _placeDataList = [];
    _placeAllList = [];
    _placeMyList = [];
    _placeLikeList = [];
    _placeSelectList = [];
    _placePromotionList = [];
    _aniController = [];

    var likeList = {};
    for (var item in AppData.USER_PLACE_LIKE) {
      likeList[item] = item;
    }

    for (var item in _placeList.entries) {
      // if ((widget.isSelectable && CheckManager(item.value)) || (
      //     !widget.isSelectable && widget.parentInfo['id'] == item.value['placeGroup'])) {
      _placeDataList.add(item.value);
      var controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
      var isSelected = widget.listSelectData!.containsKey(item.key);
      LOG('--> _placeList item [$isSelected] : ${item.key} / ${widget.listSelectData}');

      var placeItem = PlaceListCardItem(
        item.value.toJson(),
        itemHeight: UI_ITEM_HEIGHT,
        itemPadding: EdgeInsets.symmetric(vertical: 2),
        mainListType: AppData.mainListType,
        animationController: controller,
        parentInfo: AppData.currentEventGroup!.toJson(),
        selectEventList: _selectJsonData,
        isSelected: isSelected,
        isSelectable: widget.isSelectable,
        isShowEvent: _selectPlace.containsKey(item.key),
        selectMax: widget.selectMax,
        onRefresh: () {
          setState(() {
          });
        },
        onSelected: (_) {
          LOG('--> onSelected : ${item.value}');
          if (widget.selectMax == 1) {
            widget.listSelectData!.clear();
            widget.listSelectData![item.key] = item.value;
            Get.back(result: Map<String, PlaceModel>.from(widget.listSelectData!));
          } else {
            setState(() {
              if (widget.listSelectData!.containsKey(item.key)) {
                widget.listSelectData!.remove(item.key);
              } else if (widget.listSelectData!.length < widget.selectMax) {
                widget.listSelectData![item.key] = item.value;
              }
            });
          }
        }
      );

      if (_selectPlace.containsKey(item.key)) {
        _aniController.add(controller);
        _placeSelectList.add(placeItem);
        // }
      } else if (AppData.mainListType != HomeListType.calendar) {
        if (AppData.mainListType != HomeListType.map && checkPromotionDateRangeFromData(item.value.toJson())) {
          placeItem.setPromotionItem();
          _placePromotionList.add(placeItem);
        } else if (likeList.containsKey(item.key)) {
          _placeLikeList.add(placeItem);
        } else {
          _placeAllList.add(placeItem);
        }
      }
    }

    if (AppData.mainListType == HomeListType.calendar) {
      _showEmptyText = _placeSelectList.isEmpty ? 'No events for that day'.tr : '';
    } else {
      if (widget.isSelectable) {
        _showEmptyText = _placeMyList.isEmpty && _placeLikeList.isEmpty && _placeAllList.isEmpty ? 'No place to choose'.tr : '';
      } else {
        _showEmptyText = _placeMyList.isEmpty && _placeLikeList.isEmpty && _placeAllList.isEmpty ? 'No place data'.tr : '';
      }
    }

    // }
    LOG('--> refresh _placeDataList : ${_placeDataList.length}');
  }

  menuItems(context) {
    return showGroupTabWidget(
      context,
      () {
        LOG('--> PlaceGroupSelectDialog result : ${AppData.currentEventGroup}');
        // refreshMainContent();
      },
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!widget.isSelectable)...[
            showIconButton(
              Icon(Icons.view_list, color: Theme.of(context).primaryColor.withOpacity(AppData.mainListType == HomeListType.list ? 1.0 : 0.5)), () {
              setState(() {
                AppData.mainListType = HomeListType.list;
                _selectPlace.clear();
                refreshData();
              });
              },
            ),
            showIconButton(
              Icon(Icons.map_outlined, color: Theme.of(context).primaryColor.withOpacity(AppData.mainListType == HomeListType.map ? 1.0 : 0.5)), () {
                setState(() {
                  AppData.mainListType = HomeListType.map;
                  _selectPlace.clear();
                  refreshData();
                });
              },
            ),
            // showIconButton(
            //   Icon(Icons.event, color: Theme.of(context).primaryColor.withOpacity(AppData.mainListType == HomeListType.calendar ? 1.0 : 0.5)), () {
            //     setState(() {
            //       AppData.mainListType = HomeListType.calendar;
            //       _selectPlace.clear();
            //       refreshData();
            //     });
            //   },
            // ),
          ]
        ],
      )
    );
  }

  refreshCalendar(jsonData) {
    setState(() {
      _selectPlace.clear();
      _selectJsonData = jsonData ?? {};
      for (var item in _selectJsonData.entries) {
        var placeId = STR(item.value['placeId']);
        if (placeId.isNotEmpty) {
          _selectPlace[placeId] = item.value;
        }
      }
      LOG('--> widget._selectPlace : ${AppData.currentDate} / ${_selectPlace.length} / ${_selectJsonData.length}');
    });
  }

  @override
  void initState() {
    if (!widget.isSelectable) {
      AppData.mainListType = HomeListType.list;
    }
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var _locTextStyle  = TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500);
    // var _locTextStyle2 = TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w400);

    return WillPopScope(
        onWillPop: () async {
          Get.back(result: widget.listSelectData);
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.topTitle, style: AppBarTitleStyle(context)),
              titleSpacing: 0,
              toolbarHeight: _topHeight,
            ),
            body: SafeArea(
                top: false,
                child: FutureBuilder(
                    future: _placeInit,
                    builder: (context, snapshot) {
                      final mapHeight = MediaQuery.of(context).size.width  * 0.65;
                      final calendarHeight = MediaQuery.of(context).size.width  * 0.75;
                      if (snapshot.hasData) {
                        _placeList = snapshot.data as JSON;
                        refreshData();
                        for (var item in _aniController) {
                          item.forward().then((value) => item.reverse());
                        }
                        var _height = MediaQuery.of(context).size.height - _topHeight - (widget.isSelectable ? 82 + (widget.isCanNoSelect ? 90 : 0) : 182);
                        if (!widget.isSelectable) {
                          if (AppData.mainListType == HomeListType.map) _height -= mapHeight;
                          if (AppData.mainListType == HomeListType.calendar) _height -= calendarHeight;
                        }
                        return Column(
                            children: [
                              if (!widget.isSelectable)
                                menuItems(context),
                              if (widget.isSelectable && widget.isCanNoSelect)...[
                                GestureDetector(
                                    onTap: () {
                                      widget.listSelectData!.clear();
                                      Get.back();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 80,
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                      margin:  EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Row(
                                          children: [
                                            Icon(Icons.clear, size: 34),
                                            SizedBox(width: 15),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Don't choose now".tr, style: ItemTitleLargeStyle(context)),
                                                SizedBox(height: 5),
                                                Text('(You can choose later)'.tr, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
                                              ],
                                            ),
                                          ]
                                      ),
                                    )
                                )
                              ],
                              if (!widget.isSelectable)...[
                                if (AppData.mainListType == HomeListType.map)...[
                                  GoogleMapWidget(
                                    _placeDataList.map((e) => e.toJson()).toList(),
                                    mapHeight: mapHeight,
                                    onMarkerSelected: (selectItem) {
                                      LOG('--> onMarkerSelected : ${selectItem['title']} / ${selectItem['id']}');
                                      setState(() {
                                        _selectPlace.clear();
                                        _selectPlace[selectItem['id']] = selectItem;
                                        _listController.animateTo(0, curve: Curves.linear, duration: Duration(milliseconds: 200));
                                        refreshData();
                                      });
                                    },
                                  )
                                ],
                                // if (AppData.mainListType == HomeListType.calendar)...[
                                //   Container(
                                //     // show place time calendar widget..
                                //     height: calendarHeight,
                                //     child: ShowPlaceScheduleList(
                                //         AppData.currentPlaceGroup['id'],
                                //         currentDate: AppData.currentDate ?? DateTime.now(),
                                //         onAction: (status) {
                                //           AddPlaceContent(context, AppData.currentPlaceGroup, (result) {
                                //             if (result.isNotEmpty) {
                                //               setState(() {
                                //                 _placeList[result['id']] = result;
                                //                 LOG('--> _placeList added : $result');
                                //               });
                                //             }
                                //           });
                                //         },
                                //         onSelected: (view, date, jsonData) {
                                //           LOG('--> ShowPlaceTimeList onViewChanged : $jsonData');
                                //           AppData.currentDate = date;
                                //           widget._calendarView = view;
                                //           refreshCalendar(jsonData);
                                //         }
                                //     ),
                                //   ),
                                // ],
                              ],
                              Container(
                                  height: _height,
                                  child: ListView(
                                      controller: _listController,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        if (_placeSelectList.isNotEmpty)...[
                                          SubTitleBarEx(context, 'SELECT PLACE'.tr,
                                              child: Text(AppData.mainListType == HomeListType.calendar && AppData.currentDate != null ? DATE_STR(AppData.currentDate!) : '')),
                                          Container(
                                              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE, vertical: 5),
                                              child: Column(
                                                  children: _placeSelectList
                                              )
                                          ),
                                        ],
                                        // if (_placeMyList.isNotEmpty)...[
                                        //   SubTitleBarEx(context, 'MY SPOT'),
                                        //   Container(
                                        //       padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                        //       child: Column(
                                        //           children: _placeMyList
                                        //       )
                                        //   ),
                                        // ],
                                        if (AppData.mainListType != HomeListType.calendar)...[
                                          if (_placePromotionList.isNotEmpty || _placeLikeList.isNotEmpty || _placeAllList.isNotEmpty)
                                            SubTitleBarEx(context, 'PLACE LIST'.tr),
                                          SizedBox(height: 5),
                                          if (_placePromotionList.isNotEmpty)...[
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                                                child: Column(
                                                    children: _placePromotionList
                                                )
                                            ),
                                          ],
                                          if (_placeLikeList.isNotEmpty)...[
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                                                child: Column(
                                                    children: _placeLikeList
                                                )
                                            ),
                                          ],
                                          if (_placeAllList.isNotEmpty)...[
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                                                child: Column(
                                                    children: _placeAllList
                                                )
                                            ),
                                          ],
                                          if (_showEmptyText.isNotEmpty)...[
                                            Container(
                                                height: _showEmptyHeight,
                                                padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                                                child: Center(
                                                  child: Text(_showEmptyText, style: ItemTitleStyle(context)),
                                                )
                                            )
                                          ],
                                        ]
                                      ]
                                  )
                              ),
                            ]
                        );
                      } else {
                        return showLoadingFullPage(context);
                      }
                    }
                )
            )
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class PlaceListItem extends StatefulWidget {
  PlaceListItem(this.itemData, {Key? key,
    this.parentInfo,
    this.animationController,
    this.selectEventList,
    this.mainListType = 0,
    this.isSelected = false,
    this.isSelectable = false,
    this.isShowLike = true,
    this.isShowEvent = false,
    this.selectMax = 99,
    this.itemHeight = 60,
    this.itemPadding,
    this.onRefresh,
    this.onSelected,
  }) : super(key: key);

  JSON itemData;
  AnimationController? animationController;

  JSON? parentInfo;
  JSON? selectEventList;

  int mainListType;
  bool isSelected;
  bool isSelectable;
  bool isShowLike;
  bool isShowEvent;
  int selectMax;
  double itemHeight;
  EdgeInsets? itemPadding;
  Function()? onRefresh;
  Function(JSON)? onSelected;

  @override
  PlaceListItemState createState() => PlaceListItemState();
}

class PlaceListItemState extends State<PlaceListItem> {
  final api = Get.find<ApiService>();
  var _myHotSpotTitle = 'MY SPOT'.tr;
  var _hotSpotTitle = 'SPOT'.tr;
  var _imageHeight = 0.0;
  final _eventHeight = 50.0;

  List _selectEventIds = [];

  refreshData() {
    // LOG('--> widget.selectEventList : ${widget.selectEventList}');
    if (JSON_NOT_EMPTY(widget.selectEventList)) {
      _selectEventIds = widget.selectEventList!.entries.map((item) => item.value['eventId']).toList();
    }
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.itemPadding ??= EdgeInsets.symmetric(vertical: 5);
    _imageHeight = widget.itemHeight - widget.itemPadding!.top - widget.itemPadding!.bottom;
    refreshData();
    return Column(
        children: [
          GestureDetector(
              onTap: () {
                LOG('--> isSelectable : ${widget.itemData['id']}');
                if (widget.isSelectable) {
                  if (widget.onSelected != null) widget.onSelected!(widget.itemData);
                  // if (widget.selectMax == 1) {
                  //   widget.listSelectData.clear();
                  //   widget.listSelectData[widget.itemData['id']] = widget.itemData;
                  //   Get.back(result: widget.listSelectData);
                  // } else {
                  //   widget.listSelectData[widget.itemData['id']] = widget.itemData;
                  // }
                } else {
                  // AppData.placeStateKey = GlobalKey<PlaceDetailState>();
                  // api.getPlaceFromId(widget.itemData['id']).then((result) {
                  //   widget.itemData = result;
                  //   Navigator.push(
                  //       context, MaterialPageRoute(builder: (context) =>
                  //       PlaceDetailScreen(widget.itemData, widget.parentInfo,
                  //           key: AppData.placeStateKey,
                  //           isShowHome: false,
                  //           topTitle: widget.itemData['userId'] == AppData.USER_ID ? _myHotSpotTitle : _hotSpotTitle)))
                  //       .then((result) {
                  //     if (result == 'deleted') {
                  //       ShowToast('Deleted'.tr);
                  //     }
                  //     setState(() {
                  //       if (widget.onRefresh != null) widget.onRefresh!();
                  //     });
                  //   });
                  // });
                }
              },
              child: Container(
                width: double.infinity,
                height: widget.itemHeight,
                padding: widget.itemPadding,
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.isSelectable)...[
                      Icon(Icons.arrow_forward_ios, color: widget.isSelected ?
                      Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      SizedBox(width: 5),
                    ],
                    if (widget.animationController != null)
                      ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(
                              parent: widget.animationController!,
                              curve: Curves.linear)
                          ),
                          child: SizedBox(
                              width: _imageHeight,
                              height: _imageHeight,
                              child: Stack(
                                  children: [
                                    showSizedImage(widget.itemData['pic'], widget.itemHeight),
                                    if (INT(widget.itemData['status']) == 2)
                                      ShadowIcon(Icons.visibility_off_outlined, 20, Colors.white, 3, 3),
                                  ]
                              )
                          )
                      ),
                    if (widget.animationController == null)
                      SizedBox(
                          width: _imageHeight,
                          height: _imageHeight,
                          child: Stack(
                              children: [
                                showSizedImage(widget.itemData['pic'], widget.itemHeight),
                                if (INT(widget.itemData['status']) == 2)
                                  ShadowIcon(Icons.visibility_off_outlined, 20, Colors.white, 3, 3),
                              ]
                          )
                      ),
                    SizedBox(width: 10),
                    Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(STR(widget.itemData['title']), style: ItemTitleStyle(context), maxLines: 1),
                            Text(DESC(widget.itemData['desc']), style: ItemDescStyle(context), maxLines: 1),
                            // Text(ADDR(widget.itemData['address1']), style: ItemDescExStyle(context), maxLines: 1),
                          ],
                        )
                    ),
                    if (widget.isShowLike && !widget.isSelectable)...[
                      SizedBox(width: 10),
                      LikeWidget(context, 'place', widget.itemData),
                    ]
                  ],
                ),
              )
          ),
          // if (widget.isShowEvent && widget.selectEventList != null && widget.selectEventList!.isNotEmpty)...[
          //   FutureBuilder(
          //       future: api.getPlaceEventListFromId(widget.itemData['id']),
          //       builder: (context, snapshot) {
          //         if (snapshot.hasData) {
          //           var eventList = snapshot.data as JSON;
          //           if (eventList.isNotEmpty) {
          //             List<JSON> showList = [];
          //             LOG('--> eventList _selectEventIds : $_selectEventIds');
          //             for (var item in eventList.entries) {
          //               LOG('--> eventList check : ${item.key}');
          //               if (_selectEventIds.contains(item.key)) {
          //                 showList.add(item.value);
          //               }
          //             }
          //             if (showList.isNotEmpty) {
          //               return Container(
          //                   width: double.infinity,
          //                   padding: EdgeInsets.fromLTRB(0, 2, 0, 5),
          //                   child: ListView.builder(
          //                       shrinkWrap: true,
          //                       physics: NeverScrollableScrollPhysics(),
          //                       itemCount: showList.length,
          //                       itemBuilder: (context, index) {
          //                         var timeStr = '';
          //                         if (JSON_NOT_EMPTY(showList[index]['timeData'])) {
          //                           for (var item in showList[index]['timeData'].entries) {
          //                             if (widget.selectEventList!.containsKey(item.key)) {
          //                               var timeItemStr = '';
          //                               if (STR(item.value['startTime']).isNotEmpty) timeItemStr += STR(item.value['startTime']);
          //                               if (STR(item.value['startTime']).isNotEmpty || STR(item.value['endTime']).isNotEmpty) timeItemStr += ' ~ ';
          //                               if (STR(item.value['endTime' ]).isNotEmpty) timeItemStr += STR(item.value['endTime']);
          //                               timeStr += timeStr.isNotEmpty ? '' : timeItemStr;
          //                             }
          //                           }
          //                         }
          //                         return GestureDetector(
          //                             onTap: () {
          //                               Navigator.push(
          //                                   context, MaterialPageRoute(builder: (context) =>
          //                                   PlaceEventDetailScreen(showList[index], widget.parentInfo, isShowHome: false))).then((result) {
          //                                 if (result == 'home' && Navigator.of(context).canPop()) {
          //                                   Navigator.of(context).pop('home');
          //                                   return;
          //                                 }
          //                                 if (result == 'deleted') {
          //                                   ShowToast('Deleted'.tr);
          //                                 }
          //                                 setState(() {
          //                                   if (widget.onRefresh != null) widget.onRefresh!();
          //                                 });
          //                               });
          //                             },
          //                             child: Container(
          //                                 color: Colors.transparent,
          //                                 child: Row(
          //                                   children: [
          //                                     if (index < showList.length-1)
          //                                       showImage('assets/ui/treeline_00.png', Size(_eventHeight, _eventHeight), Theme.of(context).primaryColor.withOpacity(0.5)),
          //                                     if (index >= showList.length-1)
          //                                       showImage('assets/ui/treeline_01.png', Size(_eventHeight, _eventHeight), Theme.of(context).primaryColor.withOpacity(0.5)),
          //                                     SizedBox(width: 5),
          //                                     Expanded(
          //                                       child: Container(
          //                                         padding: EdgeInsets.symmetric(vertical: 3),
          //                                         color: Colors.transparent,
          //                                         child: Row(
          //                                             children: [
          //                                               showSizedRoundImage(showList[index]['pic'], _eventHeight - 6, 6),
          //                                               SizedBox(width: 10),
          //                                               Column(
          //                                                 mainAxisAlignment: MainAxisAlignment.center,
          //                                                 crossAxisAlignment: CrossAxisAlignment.start,
          //                                                 children: [
          //                                                   Text(STR(showList[index]['title']), style: ItemTitleStyle(context), maxLines: 2),
          //                                                   if (timeStr.isNotEmpty)...[
          //                                                     SizedBox(height: 5),
          //                                                     Text(timeStr, style: ItemDescExStyle(context), maxLines: 2),
          //                                                   ]
          //                                                 ],
          //                                               )
          //                                             ]
          //                                         ),
          //                                       ),
          //                                     ),
          //                                   ],
          //                                 )
          //                             )
          //                         );
          //                       }
          //                   )
          //               );
          //             } else {
          //               return Container();
          //             }
          //           } else {
          //             return Container();
          //           }
          //         } else {
          //           return showLoadingCircleSquare(40);
          //         }
          //       }
          //   ),
          // ]
        ]
    );
  }
}

class PlaceListCardItem extends StatefulWidget {
  PlaceListCardItem(this.itemData, {Key? key,
    this.parentInfo,
    this.animationController,
    this.selectEventList = const {},
    this.mainListType = 0,
    this.isSelected = false,
    this.isSelectable = false,
    this.isShowLike = true,
    this.isShowEvent = false,
    this.selectMax = 99,
    this.itemHeight = 100,
    this.itemPadding,
    this.onRefresh,
    this.onSelected,
  }) : super(key: key);

  JSON itemData;
  AnimationController? animationController;

  JSON? parentInfo;
  JSON selectEventList;

  int mainListType;
  bool isSelected;
  bool isSelectable;
  bool isShowLike;
  bool isShowEvent;
  int selectMax;
  double itemHeight;
  EdgeInsets? itemPadding;
  Function()? onRefresh;
  Function(JSON)? onSelected;

  bool _isPromotionItem = false;

  setPromotionItem() {
    _isPromotionItem = true;
  }

  @override
  PlaceListCardItemState createState() => PlaceListCardItemState();
}

class PlaceListCardItemState extends State<PlaceListCardItem> {
  final repo = PlaceRepository();
  var _myHotSpotTitle = 'MY SPOT'.tr;
  var _hotSpotTitle = 'SPOT'.tr;
  var _imageHeight = 0.0;
  final _eventHeight = 60.0;

  JSON _selectEventTime = {};
  List<JSON> _userListData = [];

  refreshData() {
    _selectEventTime.clear();
    for (var item in widget.selectEventList.entries) {
      var eventId = STR(item.value['eventId']);
      LOG('--> _selectEventTime add [$eventId] : ${item.value}');
      _selectEventTime[eventId] = item.value;
    }
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _lineColor = Theme.of(context).scaffoldBackgroundColor;
    widget.itemPadding ??= EdgeInsets.symmetric(vertical: 5);
    _imageHeight = widget.itemHeight - widget.itemPadding!.top - widget.itemPadding!.bottom;
    refreshData();
    return Container(
        padding: widget.itemPadding,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
                children: [
                  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: widget.isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).canvasColor,
                          border: widget.isSelected ? Border.all(width: 3, color: Theme.of(context).primaryColor) :
                            Border.all(width: 0, color: Colors.transparent),
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  if (widget.isSelectable) {
                                    if (widget.onSelected != null) widget.onSelected!(widget.itemData);
                                    // if (widget.selectMax == 1) {
                                    //   AppData.listSelectData.clear();
                                    //   AppData.listSelectData[widget.itemData['id']] = widget.itemData;
                                    //   Navigator.of(context).pop();
                                    // } else {
                                    //   setState(() {
                                    //     if (AppData.listSelectData.containsKey(widget.itemData['id'])) {
                                    //       AppData.listSelectData.remove(widget.itemData['id']);
                                    //     } else if (AppData.listSelectData.length < widget.selectMax) {
                                    //       AppData.listSelectData[widget.itemData['id']] = widget.itemData;
                                    //     }
                                    //   });
                                    // }
                                  } else {
                                    LOG('--> getPlaceFromId : ${widget.itemData['id']}');
                                    // AppData.placeStateKey = GlobalKey<PlaceDetailState>();
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     PlaceDetailScreen(widget.itemData, widget.parentInfo,
                                    //         key: AppData.placeStateKey,
                                    //         isShowHome: false,
                                    //         topTitle: widget.itemData['userId'] == AppData.USER_ID ? _myHotSpotTitle : _hotSpotTitle)))
                                    //     .then((result) {
                                    //   if (result == 'deleted') {
                                    //     ShowToast('Deleted'.tr);
                                    //   }
                                    //   setState(() {
                                    //     if (widget.onRefresh != null) widget.onRefresh!();
                                    //   });
                                    // });
                                  }
                                },
                                child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (widget.isSelectable)...[
                                          Icon(Icons.arrow_forward_ios, color: widget.isSelected ?
                                          Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.25)),
                                          SizedBox(width: 5),
                                        ],
                                        SizedBox(
                                            width: _imageHeight,
                                            height: _imageHeight,
                                            child: Stack(
                                                children: [
                                                  showImage(STR(widget.itemData['pic']), Size(_imageHeight, _imageHeight)),
                                                  if (INT(widget.itemData['status']) == 2)
                                                    ShadowIcon(Icons.visibility_off_outlined, 20, Colors.white, 3, 3),
                                                ]
                                            )
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                            child: Container(
                                                height: _imageHeight,
                                                padding: EdgeInsets.symmetric(vertical: 5),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(STR(widget.itemData['title']), style: ItemTitleStyle(context), maxLines: 1),
                                                        if (widget._isPromotionItem)...[
                                                          SizedBox(width: 2),
                                                          Icon(Icons.star, size: 20, color: Theme.of(context).colorScheme.tertiary),
                                                        ],
                                                      ],
                                                    ),
                                                    RichText(
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      text: TextSpan(
                                                          text: DESC(widget.itemData['desc']),
                                                          style: ItemDescStyle(context)
                                                      ),
                                                    ),
                                                    // RichText(
                                                    //   maxLines: 1,
                                                    //   overflow: TextOverflow.ellipsis,
                                                    //   text: TextSpan(
                                                    //     text: ADDR(widget.itemData['address1']),
                                                    //     style: ItemDescExStyle(context),
                                                    //   )
                                                    // )
                                                  ],
                                                )
                                            )
                                        ),
                                        if (widget.isShowLike && !widget.isSelectable)...[
                                          LikeSmallWidget(context, 'place', widget.itemData),
                                        ],
                                        SizedBox(width: 5),
                                      ],
                                    )
                                )
                            ),
                            // if (widget.isShowEvent)...[
                            //   FutureBuilder(
                            //       future: api.getPlaceEventListFromId(widget.itemData['id']),
                            //       builder: (context, snapshot) {
                            //         if (snapshot.hasData) {
                            //           var eventList = snapshot.data as JSON;
                            //           if (eventList.isNotEmpty) {
                            //             List<JSON> showList = [];
                            //             for (var item in eventList.entries) {
                            //               LOG('--> showList check : ${item.key}');
                            //               if (_selectEventTime.isEmpty || _selectEventTime.containsKey(item.key)) {
                            //                 LOG('--> showList add [${showList.length}]: ${_selectEventTime[item.key]}');
                            //                 // if (JSON_NOT_EMPTY(item.value['timeData'])) {
                            //                 //   for (var time in item.value['timeData'].entries) {
                            //                 //     if (STR(time['startTime']))
                            //                 //     timeList.add()
                            //                 //   }
                            //                 // }
                            //                 showList.add(item.value);
                            //               }
                            //             }
                            //             if (showList.isNotEmpty) {
                            //               return Container(
                            //                   width: double.infinity,
                            //                   padding: EdgeInsets.symmetric(vertical: 10),
                            //                   color: Theme.of(context).colorScheme.surface,
                            //                   child: ListView.builder(
                            //                       shrinkWrap: true,
                            //                       physics: NeverScrollableScrollPhysics(),
                            //                       itemCount: showList.length,
                            //                       itemBuilder: (context, index) {
                            //                         var timeStr = '';
                            //                         if (JSON_NOT_EMPTY(showList[index]['timeData'])) {
                            //                           for (var item in showList[index]['timeData'].entries) {
                            //                             if (widget.selectEventList.containsKey(item.key)) {
                            //                               var timeItemStr = '';
                            //                               if (STR(item.value['startTime']).isNotEmpty) timeItemStr += STR(item.value['startTime']);
                            //                               if (STR(item.value['startTime']).isNotEmpty || STR(item.value['endTime']).isNotEmpty) timeItemStr += ' ~ ';
                            //                               if (STR(item.value['endTime'  ]).isNotEmpty) timeItemStr += STR(item.value['endTime']);
                            //                               timeStr += timeStr.isNotEmpty ? '' : timeItemStr;
                            //                             }
                            //                           }
                            //                         }
                            //                         _userListData.clear();
                            //                         if (JSON_NOT_EMPTY(showList[index]['managerData'])) {
                            //                           for (var item in showList[index]['managerData'].entries) {
                            //                             _userListData.add(item.value as JSON);
                            //                             // List<JSON>.from(widget.itemData['managerData'].entries.map((key, value) => JSON.from(value)).toList());
                            //                           }
                            //                         } else if (STR(showList[index]['userId']).isNotEmpty) {
                            //                           _userListData.add(widget.itemData);
                            //                         }
                            //                         return GestureDetector(
                            //                             onTap: () {
                            //                               Navigator.push(
                            //                                   context, MaterialPageRoute(builder: (context) =>
                            //                                   PlaceEventDetailScreen(showList[index], widget.parentInfo, isShowHome: false))).then((result) {
                            //                                 if (result == 'home' && Navigator.of(context).canPop()) {
                            //                                   Navigator.of(context).pop('home');
                            //                                   return;
                            //                                 }
                            //                                 if (result == 'deleted') {
                            //                                   ShowToast('Deleted'.tr, Colors.deepOrange);
                            //                                 }
                            //                                 setState(() {
                            //                                   if (widget.onRefresh != null) widget.onRefresh!();
                            //                                 });
                            //                               });
                            //                             },
                            //                             child: Container(
                            //                                 color: Colors.transparent,
                            //                                 child: Row(
                            //                                   children: [
                            //                                     if (index < showList.length-1)
                            //                                       showImage('assets/ui/treeline_00.png', Size(_eventHeight, _eventHeight), color: Theme.of(context).primaryColor.withOpacity(0.5)),
                            //                                     if (index >= showList.length-1)
                            //                                       showImage('assets/ui/treeline_01.png', Size(_eventHeight, _eventHeight), color: Theme.of(context).primaryColor.withOpacity(0.5)),
                            //                                     showSizedRoundImage(showList[index]['pic'], _eventHeight - 6, 6),
                            //                                     SizedBox(width: 5),
                            //                                     Expanded(
                            //                                         child: Column(
                            //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //                                           crossAxisAlignment: CrossAxisAlignment.start,
                            //                                           children: [
                            //                                             Text(STR(showList[index]['title']), style: ItemTitleStyle(context), maxLines: 2),
                            //                                             if (timeStr.isNotEmpty)...[
                            //                                               SizedBox(height: 5),
                            //                                               Text(timeStr, style: ItemDescPriceStyle(context), maxLines: 2),
                            //                                             ]
                            //                                           ],
                            //                                         )
                            //                                     ),
                            //                                     if (_userListData.isNotEmpty)...[
                            //                                       UserIdCardWidget(_userListData),
                            //                                       SizedBox(width: 5),
                            //                                     ],
                            //                                   ],
                            //                                 )
                            //                             )
                            //                         );
                            //                       }
                            //                   )
                            //               );
                            //             } else {
                            //               return Container();
                            //             }
                            //           } else {
                            //             return Container();
                            //           }
                            //         } else {
                            //           return showLoadingCircleSquare(40);
                            //         }
                            //       }
                            //   ),
                            // ]
                          ]
                      )
                  ),
                  if (widget.isShowEvent)
                    Positioned(
                        top: _imageHeight - 10,
                        child: Row(
                            children: [
                              Image.asset('assets/ui/ticketline_01.png', color: _lineColor, width: 10, height: 20),
                              SizedBox(
                                child: Image.asset('assets/ui/ticketline_00.png', color: _lineColor, width: MediaQuery.of(context).size.width - 50, height: 10),
                              ),
                              Image.asset('assets/ui/ticketline_02.png', color: _lineColor, width: 10, height: 20),
                            ]
                        )
                    ),
                ]
            )
        )
    );
  }
}