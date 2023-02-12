import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view/place/place_detail_screen.dart';
import 'package:kspot_002/widget/google_map_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../models/place_model.dart';
import '../models/user_model.dart';
import '../repository/event_repository.dart';
import '../repository/user_repository.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/event/event_edit_screen.dart';
import '../view/profile/target_profile.dart';
import '../widget/comment_widget.dart';
import '../widget/content_item_card.dart';
import '../widget/custom_field_widget.dart';
import '../widget/image_scroll_viewer.dart';
import '../widget/like_widget.dart';
import '../widget/share_widget.dart';
import '../widget/time_list_widget.dart';
import '../widget/user_card_widget.dart';

class EventDetailViewModel extends ChangeNotifier {
  final scrollController = AutoScrollController();
  final eventRepo = EventRepository();
  final userRepo  = UserRepository();
  final cache     = Get.find<CacheService>();

  final topHeight = 50.0;
  final botHeight = 70.0;
  final subTabHeight = 45.0;
  final mapHeight = 200.0;
  // Future<JSON>? _initData;

  var isManager = false;
  var isOpenStoryList = false;
  var isCanReserve = false;
  var isShowReserveBtn = false;
  var isShowReserveList = false;
  var isShowMap = false;
  var isEdited = false;

  JSON? selectReserve;
  JSON? selectInfo;
  EventModel? eventInfo;
  PlaceModel? placeInfo;
  BuildContext? buildContext;

  init(BuildContext context) {
    buildContext = context;
  }

  setEventData(EventModel eventModel, PlaceModel? placeModel) {
    eventInfo = eventModel;
    placeInfo = placeModel;
    isManager = CheckManager(eventInfo!.toJson());
    LOG('--> setEventData : $isManager / ${eventInfo!.toJson()}');
  }

  toggleStatus() {
    if (eventInfo == null) return;
    var title = eventInfo!.status == 1 ? 'Disable' : 'Enable';
    showAlertYesNoDialog(buildContext!, title.tr, '$title spot?'.tr, 'In the disable state, other users cannot see it'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
      if (value == 1) {
        if (eventRepo.checkIsExpired(eventInfo!)) {
          showAlertDialog(buildContext!, title.tr, 'Event period has ended'.tr, 'Event duration must be modified'.tr, 'OK'.tr);
          return;
        }
        eventRepo.setEventStatus(eventInfo!.id, eventInfo!.status == 1 ? 2 : 1).then((result) {
          if (result) {
              eventInfo!.status = eventInfo!.status == 1 ? 2 : 1;
              ShowToast(eventInfo!.status == 1 ? 'Enabled'.tr : 'Disabled'.tr, Theme.of(buildContext!).primaryColor);
              updateEventInfo();
          }
        });
      }
    });
  }

  moveToEventEdit() {
    Get.to(() => EventEditScreen(eventInfo: eventInfo, placeInfo: placeInfo))!.then((result) {
      if (result != null) {
        eventInfo = result;
        LOG('--> EventEditScreen result : ${eventInfo!.title}');
        updateEventInfo();
      }
    });
  }

  onEventTopMenuAction(selected) {
    LOG("--> selected.index : ${selected.type}");
    switch (selected.type) {
      case DropdownItemType.enable:
      case DropdownItemType.disable:
        toggleStatus();
        break;
      case DropdownItemType.edit:
        moveToEventEdit();
        break;
      case DropdownItemType.delete:
        showAlertYesNoDialog(buildContext!, 'Delete'.tr,
            'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((value) {
          if (value == 1) {
            showTextInputDialog(buildContext!, 'Delete confirm'.tr,
                'Typing \'delete now\''.tr, 'Alert) Recovery is not possible'.tr, 10, null).then((result) {
              if (result.toLowerCase() == 'delete now') {
                eventRepo.setEventStatus(eventInfo!.id, 0).then((result) {
                  if (result) {
                    eventInfo!.status = 0;
                    Get.back(result: eventInfo!);
                  }
                });
              }
            });
          }
        });
        break;
      case DropdownItemType.promotion:
        // Navigator.push(buildContext!, MaterialPageRoute(builder: (context) =>
        //     PromotionTabScreen('event', targetInfo: widget.eventInfo)));
    }
  }

  showImageList() {
    return ImageScrollViewer(
      eventInfo!.getPicDataList,
      rowHeight: Get.width,
      showArrow: eventInfo!.picData!.length > 1,
      showPage:  eventInfo!.picData!.length > 1,
      autoScroll: false,
    );
  }

  showPicture() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(color: Theme.of(buildContext!).primaryColor.withOpacity(0.5), width: 3),
      ),
      child: showSizedRoundImage(eventInfo!.pic, 60, 8),
    );
  }

  showTitle() {
    return Text(DESC(eventInfo!.title), style: MainTitleStyle(buildContext!), maxLines: 2);
  }

  showDesc() {
    return Text(DESC(eventInfo!.desc), style: DescBodyStyle(buildContext!));
  }

  showShareBox() {
    return Row(
        children: [
          ShareWidget(buildContext!, 'event', eventInfo!.toJson(), showTitle: true),
          SizedBox(width: 10),
          LikeWidget(buildContext!, 'event', eventInfo!.toJson(), showCount: true, isEnabled: AppData.IS_LOGIN, onChangeCount: (count) {
            LOG('--> LikeWidget result : $count');
            eventInfo!.likeCount = count;
            updateEventInfo();
          }),
        ]
    );
  }

  updateEventInfo() {
    isEdited = true;
    cache.setEventItem(eventInfo!);
    notifyListeners();
  }

  showManagerList() {
    List<Widget> userList = [];
    LOG('--> ShowManagerList : ${eventInfo!.getManagerDataMap}');
    for (var user in eventInfo!.getManagerDataMap.entries) {
      userList.add(
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: UserCardWidget(user.value, onSelected: (userId) {
              userRepo.getUserInfo(user.value['userId'] ?? user.value['id']).then((userInfo) {
                if (JSON_NOT_EMPTY(userInfo)) {
                  Get.to(() => TargetProfileScreen(userInfo!));
                } else {
                  showUserAlertDialog(buildContext!, '${user.value['userId']}');
                }
              });
            }),
          )
      );
    }
    return Column(
      children: [
        SubTitle(buildContext!, 'MANAGER'.tr),
        Wrap(
          children: userList,
        )
      ],
    );
  }

  showCustomFieldList() {
    return ShowCustomField(buildContext!, eventInfo!.getCustomDataMap);
  }

  showTagList() {
    return TagTextList(buildContext!, eventInfo!.tagData!, headTitle: '#');
  }

  showLocation() {
    return Column(
      children: [
        SubTitle(buildContext!, 'PLACE & LOCATION'.tr, height: 40),
        ContentItem(placeInfo!.toJson(),
          padding: EdgeInsets.zero,
          showType: GoodsItemCardType.place,
          descMaxLine: 2,
          isShowExtra: false,
          outlineColor: Theme.of(buildContext!).colorScheme.tertiary,
          titleStyle: ItemTitleLargeStyle(buildContext!),
          descStyle: ItemDescStyle(buildContext!),
          onShowDetail: (id, type) {
            Get.to(() => PlaceDetailScreen(placeInfo!, AppData.currentEventGroup));
          },
        ),
        SizedBox(height: 5),
        SubTitle(buildContext!, 'ADDRESS'.tr, height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(placeInfo!.address.address1, style: Theme
                .of(buildContext!)
                .textTheme
                .bodyText1),
            SizedBox(height: 2),
            Text(placeInfo!.address.address2, style: Theme
                .of(buildContext!)
                .textTheme
                .bodyText1),
            SizedBox(height: 15),
            Row(
              children: [
                GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Theme.of(buildContext!).cardColor,
                    ),
                    child: Icon(Icons.map_outlined, size: 24),
                  ),
                  onTap: () {
                    isShowMap = !isShowMap;
                    notifyListeners();
                  },
                ),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    var addr = '${placeInfo!.address.address1} ${placeInfo!.address.address2}';
                    LOG('--> clipboard copy : $addr');
                    Clipboard.setData(ClipboardData(text: addr));
                    ShowToast('copied to clipboard'.tr);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Theme.of(buildContext!).cardColor,
                    ),
                    child: Icon(Icons.copy, size: 24),
                  ),
                )
              ],
            )
          ]
        ),
        if (isShowMap)...[
          SizedBox(height: 10),
          GoogleMapWidget(
              [placeInfo!.toJson()],
              mapHeight: mapHeight,
              showDirection: true,
              showButtons: true,
              showMyLocation: true,
              onButtonAction: (action) {
                if (action == MapButtonAction.direction) {
                  var url = Uri.parse(GoogleMapLinkDirectionMake(
                      placeInfo!.title, placeInfo!.address.lat, placeInfo!.address.lng));
                  canLaunchUrl(url).then((result) {
                    if (!result) {
                      if (Platform.isIOS) {
                        url = Uri.parse(
                            'https://apps.apple.com/gb/app/google-maps-transit-food/id585027354');
                      } else {
                        url = Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.google.android.apps.maps');
                      }
                    }
                    launchUrl(url);
                  });
                } else {
                  GetCurrentLocation().then((result) {
                    if (AppData.currentLocation != null) {
                      var url = Uri.parse(GoogleMapLinkBusLineMake(
                          'My Location'.tr, AppData.currentLocation!,
                          placeInfo!.title, LATLNG(placeInfo!.address.toJson())));
                      canLaunchUrl(url).then((result) {
                        if (!result) {
                          if (Platform.isIOS) {
                            url = Uri.parse(
                                'https://apps.apple.com/gb/app/google-maps-transit-food/id585027354');
                          } else {
                            url = Uri.parse(
                                'https://play.google.com/store/apps/details?id=com.google.android.apps.maps');
                          }
                        }
                        LOG('--> url : $url');
                        launchUrl(url);
                      });
                    }
                  });
                }
              }),
        ],
      ],
    );
  }

  showTimeList() {
    return Column(
      children: [
        SubTitleBar(buildContext!, 'SCHEDULE'.tr),
        ShowTimeList(eventInfo!.getTimeDataMap, currentDate: AppData.currentDate, showAddButton: false,
          onInitialSelected: (dateTime, jsonData) {
            LOG('--> ShowTimeList onInitialSelected : $dateTime / $jsonData');
            // refreshReservButton(dateTime, jsonData);
          },
          onSelected: (dateTime, jsonData) {
            LOG('--> ShowTimeList onSelected : $dateTime / $jsonData');
            // refreshReservButton(dateTime, jsonData);
          }
        ),
      ],
    );
  }

  showCommentList() {
    return Column(
      children: [
        SubTitleBar(buildContext!, 'COMMENT'.tr, height: subTabHeight, icon: isOpenStoryList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, onActionSelect: (select) {
            isOpenStoryList = !isOpenStoryList;
            notifyListeners();
        }),
        if (isOpenStoryList)...[
          AutoScrollTag(
            key: ValueKey(0),
            controller: scrollController,
            index: 0,
            child: CommentTabWidget(eventInfo!.toJson(), 'event'),
          ),
        ]
      ]
    );
  }

  showReserveButton() {
    return GestureDetector(
      onTap: () {
        var _addItem = {
          'status'    : 1,
          'people'    : 1,
          'reserveStatus': 'request',
          'price'     : DBL(selectReserve!['price']),
          'currency'  : STR(selectReserve!['currency']),
          'title'     : eventInfo!.title,
          'targetType': 'event',
          'targetId'  : eventInfo!.id,
          'targetDate': DATE_STR(AppData.currentDate!),
          'userId'    : AppData.USER_ID,
          'userName'  : AppData.USER_NICKNAME,
          'userPic'   : AppData.USER_PIC,
        };
        // Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(
        //   ReservationScreen(_addItem, _selectReserve!, typeTitle: 'EVENT'.tr))).then((value) => {
        // });
      },
      child: Container(
        width: Get.width,
        height: botHeight,
        color: Theme.of(buildContext!).colorScheme.secondary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('RESERVATION'.tr, style: ItemTitleLargeInverseStyle(buildContext!)),
              // Text(STR(_selectReserve!['descEx']), style: ItemTitleInverseStyle(context)),
            ]
          )
        ),
      )
    );
  }
}