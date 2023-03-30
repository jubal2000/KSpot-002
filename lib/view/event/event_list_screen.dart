import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/repository/event_repository.dart';
import 'package:kspot_002/services/cache_service.dart';
import 'package:kspot_002/view_model/event_view_model.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../models/event_model.dart';
import '../../utils/utils.dart';
import '../../widget/search_widget.dart';
import '../../widget/event_item.dart';

enum EventListType {
  events,
  classes,
  none,
}

class EventListScreen extends StatefulWidget {
  EventListScreen(this.isMyList, {Key? key, this.isPreview = false, this.isSelectable = false, this.isSelectMy = true, this.selectMax = 1, this.listSelectData}) : super(key: key);

  bool isMyList;
  bool isPreview;
  bool isSelectable;
  bool isSelectMy;
  int  selectMax;
  List<String>? listSelectData;

  @override
  EventListState createState() => EventListState();
}

class EventListState extends State<EventListScreen> {
  final repo  = EventRepository();
  final cache = Get.find<CacheService>();
  final _viewModel = EventViewModel();

  List<EventListTab> _tabList = [];
  List<String> selectList = [];

  refreshTabData() {
    _tabList = [
      EventListTab(0, 'EVENT'.tr, _viewModel, isSelectable: widget.isSelectable, selectMax: widget.selectMax, onSelected: onSelected),
      EventListTab(1, 'CLASS'.tr, _viewModel, isSelectable: widget.isSelectable, selectMax: widget.selectMax, onSelected: onSelected),
    ];
  }

  onSelected(EventModel eventItem) {
    LOG('--> onSelected : ${eventItem.id} / ${selectList.length}');
    if (!selectList.contains(eventItem.id) && selectList.length < widget.selectMax) {
      selectList.add(eventItem.id);
    }
    if (widget.selectMax == 1) {
      Get.back(result: eventItem);
    } else {
      setState(() {});
    }
  }

  @override
  void initState() {
    refreshTabData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
            title: Text(widget.isSelectable ? 'Event select'.tr : 'Event list'.tr, style: AppBarTitleStyle(context)),
            titleSpacing: 0,
          ),
          // body: EventListTab(0, 'EVENT'.tr,
          //   isSelectable: widget.isSelectable, selectMax: widget.selectMax, isSelectMy: widget.isSelectMy, onSelected: onSelected),
          // body: widget.isMyList && !widget.isSelectable ? EventListTab(1, 'ALL'.tr, _viewModel,
          // isSelectable: widget.isSelectable, selectMax: widget.selectMax, isSelectMy: widget.isSelectMy, onSelected: onSelected) :
          body: DefaultTabController(
            length: _tabList.length,
            child: Scaffold(
              appBar: TabBar(
                padding: EdgeInsets.symmetric(horizontal: 50),
                labelColor: Theme.of(context).primaryColor,
                labelStyle: ItemTitleStyle(context),
                unselectedLabelColor: Theme.of(context).hintColor,
                unselectedLabelStyle: ItemTitleStyle(context),
                indicatorColor: Theme.of(context).primaryColor,
                tabs: _tabList.map((item) => item.getTab()).toList(),
              ),
              body: FutureBuilder(
                future: _viewModel.getBookmarkData(AppData.USER_ID),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: _tabList
                    );
                  } else {
                    return showLoadingFullPage(context);
                  }
                }
              )
            )
          )
        )
      )
    );
  }
}

class EventListTab extends StatefulWidget {
  EventListTab(this.eventTab, this.tabTitle, this.viewModel,
      {Key? key, this.topHeight = 40, this.isSelectable = false, this.isSelectMy = true, this.selectMax = 9, this.onSelected}) : super(key: key);

  int eventTab;
  String tabTitle;
  double topHeight;
  bool isSelectable;
  bool isSelectMy;
  int  selectMax;
  EventViewModel viewModel;

  Function(EventModel)? onSelected;

  Widget getTab() {
    return Tab(text: tabTitle, height: topHeight);
  }

  @override
  EventListTabState createState() => EventListTabState();
}

class EventListTabState extends State<EventListTab> {
  final _scrollController = ScrollController();
  final repo  = EventRepository();
  final cache = Get.find<CacheService>();

  Map<String, EventModel> showData = {};
  JSON selectEvent = {};

  var searchText = '';
  var isSearched = false;
  var isHorizontalStyle = false;
  var showEmptyText = 'There are no events'.tr;

  refreshShowData() {
    showData.clear();
    // add promotion event..
    // for (var item in cache.eventData!.entries) {
    //   if (_selectEvent.containsKey(item.key)) {
    //     showData[item.key] = item.value;
    //     if (checkPromotionDateRangeFromData(item.value)) {
    //       item.value['promotion'] = '1';
    //       showData[item.key] = item.value;
    //     }
    //   }
    // }
    // add normal event..
    if (cache.eventData.isNotEmpty) {
      for (var item in cache.eventData.entries) {
        if (item.value.type == widget.eventTab && (!widget.isSelectMy || item.value.userId == AppData.USER_ID) && checkSearch(item.value)) {
          if (!showData.containsKey(item.key)) {
            var bookmarkItem = widget.viewModel.bookmarkData[item.key];
            item.value.bookmarked = bookmarkItem != null;
            showData[item.key] = item.value;
            LOG('--> bookmarked check [${item.key}] : ${item.value.title} / ${item.value.bookmarked}');
          }
        }
      }
    }
    LOG('--> refreshShowData result : ${showData.length} / ${cache.eventData!.entries.length}');
    showData = repo.INDEX_SORT_ASC(showData);
  }

  checkSearch(EventModel item) {
    var isAdd = 0;
    if (isSearched) {
      isAdd = -1;
      var checkText = searchText.toLowerCase();
      if (STR(item.title).toString().toLowerCase().contains(checkText)) isAdd = 0;
      if (STR(item.desc ).toString().toLowerCase().contains(checkText)) isAdd = 1;
      if (item.tagData != null) {
        for (var tag in item.tagData!) {
          if (STR(tag).toString().toLowerCase().contains(checkText)) isAdd = 2;
          if (isAdd >= 0) break;
        }
      }
      if (JSON_NOT_EMPTY(item.timeData)) {
        for (var time in item.timeData!) {
          if (STR(time.title).toString().toLowerCase().contains(checkText)) isAdd = 3;
          if (isAdd >= 0) break;
        }
      }
    }
    if (isAdd >= 0) {
      item.sortIndex = isAdd;
      showData[item.id] = item;
    }
    LOG('--> checkSearch result : ${showData.length} / $isAdd');
    return isAdd >= 0;
  }

  @override
  void initState() {
    refreshShowData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LOG('--> showData : ${showData.length}');
    return SafeArea(
      child: ChangeNotifierProvider<EventViewModel>.value(
        value: widget.viewModel,
        child: Consumer<EventViewModel>(
          builder: (context, viewModel, _) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE, vertical: 5),
              width: double.infinity,
              child: ListView(
                children: [
                  SearchWidget(
                    key: AppData.searchWidgetKey[SearchKeys.events.index + widget.eventTab],
                    initialText: searchText,
                    isShowList: true,
                    padding: EdgeInsets.zero,
                    onEdited: (result, status) {
                      LOG('--> SearchWidget edited : $result / $status');
                      setState(() {
                        if (status < 0) {
                          searchText = '';
                          isSearched = false;
                          if (isSearched) {
                            unFocusAll(context);
                          }
                        } else {
                          searchText = result;
                          isSearched = result.isNotEmpty;
                        }
                        refreshShowData();
                      });
                    },
                  ),
                  Container(
                    width: Get.width,
                    height: showData.isEmpty ? 0 : Get.height,
                    padding: isHorizontalStyle ? EdgeInsets.all(UI_HORIZONTAL_SPACE) : EdgeInsets.zero,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: isHorizontalStyle ? Axis.horizontal : Axis.vertical,
                      itemCount: showData.length,
                      itemBuilder: (context, index) {
                        var itemKey = showData.keys.elementAt(index);
                        if (isHorizontalStyle) {
                          return PlaceEventVerCardItem(showData[itemKey]!.toJson(), itemHeight: Get.height, itemWidth: Get.height * 0.5,
                            isShowHomeButton: false,
                            isShowPlaceButton: true,
                            isShowTheme: false,
                            itemPadding: EdgeInsets.only(right: 10),
                            isSelectable: widget.isSelectable, selectMax: widget.selectMax, onRefresh: (selectItem) {
                              // setState(() {
                              //   showData[itemKey] = updateData;
                              // });
                            }
                          );
                        } else {
                          return EventCardItem(showData[itemKey]!,
                            isShowHomeButton: false,
                            isShowPlaceButton: true,
                            isSelectable: widget.isSelectable, selectMax: widget.selectMax, onShowDetail: (key, status) {
                                LOG('--> EventCardItem onShowDetail : $itemKey');
                              if (widget.onSelected != null) widget.onSelected!(showData[itemKey]!);
                              // setState(() {
                              //   showData[itemKey] = updateData;
                              // });
                            }
                          );
                        }
                      }
                    )
                  ),
                  if (showData.isEmpty)
                    Container(
                      width: Get.width,
                      height: Get.height - 300,
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Center(
                        child: Text(showEmptyText, style: ItemTitleStyle(context)),
                      )
                    )
                ]
              )
            );
          }
        )
      )
    );
  }
}