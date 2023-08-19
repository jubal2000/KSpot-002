
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/place_model.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/like_widget.dart';

class PlaceListItem extends StatefulWidget {
  PlaceListItem(this.itemData, {Key? key,
    this.parentInfo,
    this.animationController,
    this.selectEventList,
    this.mainListType = 0,
    this.isSelectable = false,
    this.isShowLike = true,
    this.isShowEvent = false,
    this.selectMax = 99,
    this.itemHeight = 60,
    this.itemPadding,
    this.onRefresh}) : super(key: key);

  PlaceModel itemData;
  AnimationController? animationController;

  JSON? parentInfo;
  JSON? selectEventList;

  int mainListType;
  bool isSelectable;
  bool isShowLike;
  bool isShowEvent;
  int selectMax;
  double itemHeight;
  EdgeInsets? itemPadding;
  Function()? onRefresh;

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
                if (widget.isSelectable) {
                  if (widget.selectMax == 1) {
                    AppData.listSelectData.clear();
                    AppData.listSelectData[widget.itemData.id] = widget.itemData;
                    Navigator.of(context).pop();
                  } else {
                    AppData.listSelectData[widget.itemData.id] = widget.itemData;
                  }
                } else {
                  // LOG('--> getPlaceFromId : ${widget.itemData.id}');
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
                      Icon(Icons.arrow_forward_ios, color: AppData.listSelectData.containsKey(widget.itemData.id) ?
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
                                    showSizedImage(widget.itemData.pic, widget.itemHeight),
                                    if (INT(widget.itemData.status) == 2)
                                      OutlineIcon(Icons.visibility_off_outlined, 20, Colors.white, x:3, y:3),
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
                                showSizedImage(widget.itemData.pic, widget.itemHeight),
                                if (INT(widget.itemData.status) == 2)
                                  OutlineIcon(Icons.visibility_off_outlined, 20, Colors.white, x:3, y:3),
                              ]
                          )
                      ),
                    SizedBox(width: 10),
                    Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(STR(widget.itemData.title), style: ItemTitleStyle(context), maxLines: 1),
                            Text(DESC(widget.itemData.desc), style: ItemDescStyle(context), maxLines: 1),
                            // Text(ADDR(widget.itemData['address1']), style: ItemDescExStyle(context), maxLines: 1),
                          ],
                        )
                    ),
                    if (widget.isShowLike)...[
                      SizedBox(width: 10),
                      LikeWidget(context, 'place', widget.itemData.toJson()),
                    ]
                  ],
                ),
              )
          ),
          if (widget.isShowEvent && widget.selectEventList != null && widget.selectEventList!.isNotEmpty)...[
            FutureBuilder(
                future: api.getEventListFromPlaceId(widget.itemData.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var eventList = snapshot.data as JSON;
                    if (eventList.isNotEmpty) {
                      List<JSON> showList = [];
                      LOG('--> eventList _selectEventIds : $_selectEventIds');
                      for (var item in eventList.entries) {
                        LOG('--> eventList check : ${item.key}');
                        if (_selectEventIds.contains(item.key)) {
                          showList.add(item.value);
                        }
                      }
                      if (showList.isNotEmpty) {
                        return Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(0, 2, 0, 5),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: showList.length,
                                itemBuilder: (context, index) {
                                  var timeStr = '';
                                  if (JSON_NOT_EMPTY(showList[index]['timeData'])) {
                                    for (var item in showList[index]['timeData'].entries) {
                                      if (widget.selectEventList!.containsKey(item.key)) {
                                        var timeItemStr = '';
                                        if (STR(item.value['startTime']).isNotEmpty) timeItemStr += STR(item.value['startTime']);
                                        if (STR(item.value['startTime']).isNotEmpty || STR(item.value['endTime']).isNotEmpty) timeItemStr += ' ~ ';
                                        if (STR(item.value['endTime' ]).isNotEmpty) timeItemStr += STR(item.value['endTime']);
                                        timeStr += timeStr.isNotEmpty ? '' : timeItemStr;
                                      }
                                    }
                                  }
                                  return GestureDetector(
                                      onTap: () {
                                        // Navigator.push(
                                        //     context, MaterialPageRoute(builder: (context) =>
                                        //     EventDetailScreen(showList[index], widget.parentInfo, isShowHome: false))).then((result) {
                                        //   if (result == 'home' && Navigator.of(context).canPop()) {
                                        //     Navigator.of(context).pop('home');
                                        //     return;
                                        //   }
                                        //   if (result == 'deleted') {
                                        //     ShowToast('Deleted'.tr);
                                        //   }
                                        //   setState(() {
                                        //     if (widget.onRefresh != null) widget.onRefresh!();
                                        //   });
                                        // });
                                      },
                                      child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              if (index < showList.length-1)
                                                showImage('assets/ui/treeline_00.png', Size(_eventHeight, _eventHeight), color: Theme.of(context).primaryColor.withOpacity(0.5)),
                                              if (index >= showList.length-1)
                                                showImage('assets/ui/treeline_01.png', Size(_eventHeight, _eventHeight), color:Theme.of(context).primaryColor.withOpacity(0.5)),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 3),
                                                  color: Colors.transparent,
                                                  child: Row(
                                                      children: [
                                                        showSizedRoundImage(showList[index]['pic'], _eventHeight - 6, 6),
                                                        SizedBox(width: 10),
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(STR(showList[index]['title']), style: ItemTitleStyle(context), maxLines: 2),
                                                            if (timeStr.isNotEmpty)...[
                                                              SizedBox(height: 5),
                                                              Text(timeStr, style: ItemDescExStyle(context), maxLines: 2),
                                                            ]
                                                          ],
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      )
                                  );
                                }
                            )
                        );
                      } else {
                        return Container();
                      }
                    } else {
                      return Container();
                    }
                  } else {
                    return showLoadingCircleSquare(40);
                  }
                }
            ),
          ]
        ]
    );
  }
}