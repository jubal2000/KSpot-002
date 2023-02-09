import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../repository/event_repository.dart';
import '../repository/user_repository.dart';
import '../utils/utils.dart';
import '../view/event/event_edit_screen.dart';
import '../view/profile/target_profile.dart';
import '../widget/comment_widget.dart';
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

  final topHeight = 50.0;
  final botHeight = 70.0;
  final subTabHeight = 45.0;
  // Future<JSON>? _initData;

  var isManager = false;
  var isOpenStoryList = false;
  var isCanReserve = false;
  var isShowReserveBtn = false;
  var isShowReserveList = false;

  JSON? selectReserve;
  JSON? selectInfo;
  EventModel? eventInfo;
  BuildContext? buildContext;

  init(BuildContext context) {
    buildContext = context;
  }

  setEventData(EventModel eventModel) {
    eventInfo = eventModel;
    LOG('--> setEventData : ${eventInfo!.toJson()}');
    isManager = CheckManager(eventInfo!.toJson());
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
              notifyListeners();
          }
        });
      }
    });
  }

  moveToEventEdit() {
    Get.to(() => EventEditScreen())!.then((result) {
      if (result != null) {
        eventInfo = result;
        notifyListeners();
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
            if (!AppData.isDevMode) {
              showTextInputDialog(buildContext!, 'Delete confirm'.tr,
                  'Typing \'delete now\''.tr, 'Alert) Recovery is not possible'.tr, 10, null).then((result) {
                if (result == 'delete now') {
                  eventRepo.setEventStatus(eventInfo!.id, 0).then((result) {
                    if (result) {
                      eventInfo!.status = 0;
                      Get.back(result:'deleted');
                    }
                  });
                }
              });
            } else {
              eventRepo.setEventStatus(eventInfo!.id, 0).then((result) {
                if (result) {
                  eventInfo!.status = 0;
                  Get.back(result:'deleted');
                }
              });
            }
          }
        });
        break;
      case DropdownItemType.promotion:
        // Navigator.push(buildContext!, MaterialPageRoute(builder: (context) =>
        //     PromotionTabScreen('event', targetInfo: widget.eventInfo)));
    }
  }

  showImageList(height) {
    if (eventInfo!.picData != null && eventInfo!.picData!.isNotEmpty) {
      return ImageScrollViewer(
        eventInfo!.getPicDataList,
        rowHeight: height,
        showArrow: eventInfo!.picData!.length > 1,
        showPage:  eventInfo!.picData!.length > 1,
        autoScroll: false,
      );
    } else {
      return Container();
    }
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
    return Text(eventInfo!.title, style: MainTitleStyle(buildContext!), maxLines: 9);
  }

  showDesc() {
    return Text(eventInfo!.desc, style: DescBodyStyle(buildContext!));
  }

  showShareBox() {
    return Row(
        children: [
          ShareWidget(buildContext!, 'event', eventInfo!.toJson(), showTitle: true),
          SizedBox(width: 10),
          LikeWidget(buildContext!, 'event', eventInfo!.toJson(), showCount: true),
        ]
    );
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