import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:kspot_002/models/story_model.dart';
import 'package:kspot_002/view/story/story_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/dialogs.dart';
import '../models/event_model.dart';
import '../repository/event_repository.dart';
import '../utils/utils.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';
import '../view/event/event_detail_screen.dart';
import '../view/event/event_item.dart';
import '../view/profile/profile_content_sceen.dart';
import '../view/profile/profile_tab_screen.dart';
import '../view/story/story_item.dart';

enum ProfileMainTab {
  profile,
  follow,
  like,
}

enum ProfileContentType {
  event,
  story,
}

class UserViewModel extends ChangeNotifier {
  final repo = UserRepository();
  final eventRepo = EventRepository();
  final msgTextController = TextEditingController();

  UserModel? userInfo;
  List<ProfileTabScreen> tabList = [];
  List<GlobalKey> tabKeyList = [];
  BuildContext? context;

  var currentTab = 0;
  var tabListHeight = 0.0;
  var isMyProfile = false;
  var isDisableOpen = false;

  // event, story list..
  final listItemShowMax = 5;
  var listPageNow = 0;
  var listPageMax = 0;
  var selectedTab = ProfileContentType.event;

  Future<JSON>? listDataInit;
  Map<String, EventModel> eventData = {};
  Map<String, StoryModel> storyData = {};
  JSON snsData = {};

  init(context) {
    this.context = context;
  }

  initUserModel(UserModel user) {
    userInfo    = user;
    isMyProfile = userInfo!.checkOwner(AppData.USER_ID);
    snsData     = userInfo!.snsDataMap;
    tabKeyList  = List.generate(3, (index) => GlobalKey());
    tabList = [
      ProfileTabScreen(ProfileMainTab.profile , 'PROFILE'.tr  , this, key: tabKeyList[0]),
      ProfileTabScreen(ProfileMainTab.follow  , 'FOLLOW'.tr   , this, key: tabKeyList[1]),
      ProfileTabScreen(ProfileMainTab.like    , 'LIKE'.tr     , this, key: tabKeyList[2]),
    ];
    setUserMessage();
  }

  initUserModelFromId(String userId) async {
    final info = await repo.getUserInfo(userId);
    if (info != null) {
      initUserModel(info);
    }
  }

  refresh() {
    notifyListeners();
  }

  getEventData(bool addExpired) {
    return repo.getEventFromUserId(userInfo!.id, addExpired);
  }

  getStoryData() {
    return repo.getStoryFromUserId(userInfo!.id);
  }

  getContentDataAll() async {
    LOG('---> getContentDataAll : ${eventData.length} / ${storyData.length}');
    if (eventData.isEmpty) {
      eventData = await repo.getEventFromUserId(userInfo!.id, isMyProfile);
    }
    if (storyData.isEmpty) {
      storyData = await repo.getStoryFromUserId(userInfo!.id);
    }
    return true;
  }

  setMainTab(index) {
    currentTab = index;
    notifyListeners();
  }

  changeUserPic() async {
    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    LOG('---> setUserPic : $pickImage');
    if (pickImage != null) {
      var imageUrl  = await ShowUserPicCroper(pickImage.path);
      LOG('---> imageUrl : $imageUrl');
      if (imageUrl != null) {
        showLoadingDialog(context!, 'uploading now...'.tr);
        var imageData = await ReadFileByte(imageUrl);
        JSON imageInfo = {'id': AppData.userInfo.id, 'data': imageData};
        var upResult = await repo.uploadImageData(imageInfo, 'user_img');
        if (upResult == null) {
          showAlertDialog(context!, 'Profile image'.tr, 'Image update is failed'.tr, '', 'OK'.tr);
        }
        AppData.userInfo.pic = upResult!;
        var setResult = await repo.setUserInfoItem(AppData.userInfo, 'pic');
        hideLoadingDialog();
        if (setResult) {
          showAlertDialog(context!, 'Profile image'.tr, 'Image update is complete'.tr, '', 'OK'.tr);
          AppData.USER_PIC = upResult;
          LOG('---> setUserPic success : ${AppData.USER_PIC}');
          notifyListeners();
        }
      }
    }
  }

  showUserPic() {
    return Container(
      width: UI_FACE_SIZE.w,
      height: UI_FACE_SIZE.w,
      child: Stack(
        children: [
          Container(
            width: UI_FACE_SIZE.w,
            height: UI_FACE_SIZE.w,
            decoration: BoxDecoration(
              color: const Color(0xff7c94b6),
              borderRadius: BorderRadius.all(Radius.circular(UI_FACE_SIZE.w)),
              border: Border.all(
                color: Theme.of(context!).colorScheme.secondary,
                width: 4.0,
              ),
            ),
            child: getCircleImage(userInfo!.pic, UI_FACE_SIZE.w),
          ),
          if (isMyProfile)
            Positioned(
              right: 2,
              bottom: 2,
              child: IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.edit, color: Colors.black.withOpacity(0.5), size: 26),
                    Icon(Icons.edit, color: Colors.white, size: UI_MENU_ICON_SIZE.w),
                  ]
                ),
                onPressed: () {
                  if (isMyProfile) {
                    changeUserPic();
                  }
                },
              )
          )
        ]
      )
    );
  }

  showSnsData() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: UI_BOTTOM_SPACE.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var item in snsData.entries)...[
            if (snsData.containsKey(STR(item.value['id'])))...[
              GestureDetector(
                onTap: () async {
                  final snsItem = snsData[item.value['id']];
                  if (snsItem == null) return;
                  var protocolUrl = '';
                  var launchMode = LaunchMode.platformDefault;
                  LOG('--> SNS select : $snsItem');
                  switch(STR(item.value['id'])) {
                    case 'facebook':
                      protocolUrl = 'fb://facewebmodal/f?href=${STR(snsItem['link'])}';
                      break;
                    case 'instagram':
                      protocolUrl = 'instagram://user?username=${STR(snsItem['link']).toString().replaceAll("@", '')}';
                      break;
                    default:
                      protocolUrl = STR(snsItem['link']);
                      launchMode = LaunchMode.externalApplication;
                      break;
                  }
                  LOG('--> protocolUrl : $protocolUrl');
                  var url = Uri.parse(protocolUrl);
                  await launchUrl(url, mode: launchMode);
                },
                child: showImage(STR(item.value['icon']), Size(UI_SNS_SIZE.sp, UI_SNS_SIZE.sp), color: Theme.of(context!).hintColor)
              ),
            ]
          ]
        ],
      )
    );
  }

  onMessageEdit() {
    showTextInputLimitDialog(context!, 'Edit message'.tr, '', userInfo!.message, 1, 200, 6, null).then((result) async {
      if (result.isNotEmpty) {
        userInfo!.message = result;
        showLoadingDialog(context!, 'Now Uploading...');
        var setResult = await repo.setUserInfoItem(userInfo!, 'message');
        hideLoadingDialog();
        if (setResult) {
          AppData.userInfo.message = userInfo!.message;
          setUserMessage();
          notifyListeners();
        }
      }
    });
  }

  setUserMessage() {
    if (userInfo!.message.isEmpty) {
      msgTextController.text = isMyProfile ? 'Enter your message to show here'.tr : '';
      userInfo!.message = '';
    } else {
      msgTextController.text = userInfo!.message;
    }
  }

  showMessageBox() {
    return Stack(
      children: [
        TextField(
          readOnly: true,
          controller: msgTextController,
          maxLines: 6,
          enabled: isMyProfile,
          decoration: isMyProfile ? inputLabel(context!, '', 'Enter your message to show here'.tr) : viewLabel(context!, '', ''),
          onTap: () {
            onMessageEdit();
          },
        ),
        if (isMyProfile)
          Positioned(
            right: 10.w,
            bottom: 10.w,
            child: GestureDetector(
              onTap: () {
                onMessageEdit();
              },
              child: Icon(Icons.edit, color: Theme.of(context!).hintColor)
            )
          ),
      ]
    );
  }

  //----------------------------------------------------------------------------
  //
  //  My Event, Story list..
  //

  // initListTab(selectedTab) {
  //   this.selectedTab = selectedTab;
  // }

  // refreshContentShowList() {
  //   switch(selectedTab) {
  //     case ProfileContentType.event:
  //       eventShowList.clear();
  //       for (var i=0; i<listPageMax; i++) {
  //         var itemIndex = listPageNow * listItemShowMax + i;
  //         if (itemIndex >= eventData.length) break;
  //         var key = eventData.keys.elementAt(itemIndex);
  //         if (eventData.containsKey(key)) {
  //           eventShowList.add(eventData[key]!);
  //         }
  //       }
  //       listPageMax = (eventShowList.length / listItemShowMax).floor() + (eventShowList.length % listItemShowMax > 0 ? 1 : 0);
  //     break;
  //     case ProfileContentType.story:
  //       storyShowList.clear();
  //       for (var i=0; i<listPageMax; i++) {
  //         var itemIndex = listPageNow * listItemShowMax + i;
  //         if (itemIndex >= storyData.length) break;
  //         var key = storyData.keys.elementAt(itemIndex);
  //         if (storyData.containsKey(key)) {
  //           storyShowList.add(storyData[key]!);
  //         }
  //       }
  //       listPageMax = (storyShowList.length / listItemShowMax).floor() + (storyShowList.length % listItemShowMax > 0 ? 1 : 0);
  //       break;
  //   }
  // }
  
  contentItem(IconData icon, String title, String desc, int count, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: UI_ITEM_HEIGHT_L.w,
        margin: EdgeInsets.symmetric(vertical: 5.w),
        padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w, vertical: 5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
          color: Theme.of(context!).primaryColor.withOpacity(0.2)
        ),
        child: Row(
          children: [
            Icon(icon, size: UI_MENU_ICON_SIZE.w, color: Theme.of(context!).hintColor.withOpacity(0.25)),
            SizedBox(width: UI_ITEM_SPACE.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ItemTitleLargeStyle(context!)),
                  if (desc.isNotEmpty)...[
                    SizedBox(height: 5.w),
                    Text(desc, style: ItemTitleExStyle(context!)),
                  ],
                ],
              )
            ),
            SizedBox(width: 10.w),
            Container(
              height: UI_MENU_ICON_SIZE_S.w,
              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE_S.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(UI_MENU_ICON_SIZE_S.w)),
                color: Theme.of(context!).cardColor,
              ),
              child: Center(
                child: Text('$count', style: ItemTitleNormalStyle(context!)),
              ),
            ),
            SizedBox(width: UI_ITEM_SPACE.w),
            Icon(Icons.keyboard_arrow_right_outlined, size: UI_MENU_ICON_SIZE.w),
          ],
        ),
      )
    );
  }

  get eventLength {
    var result = 0;
    for (var item in eventData.entries) {
      if (item.value.status > 0) result++;
    }
    return result;
  }

  get storyLength {
    var result = 0;
    for (var item in storyData.entries) {
      if (item.value.status > 0) result++;
    }
    return result;
  }

  showUserContentList() {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w, vertical: 5.w),
      children: [
        // if (userInfo!.checkOption('event_on'))
          contentItem(Icons.event_available, 'EVENT LIST'.tr, '', eventLength, () {
            Navigator.of(context!).push(createAniRoute(ProfileContentScreen(this, ProfileContentType.event, 'EVENT LIST'))).then((_) {
            });
          }),
        // if (userInfo!.checkOption('story_on'))
          contentItem(Icons.photo_library_outlined, 'STORY LIST'.tr, '', storyLength, () {
            Navigator.of(context!).push(createAniRoute(ProfileContentScreen(this, ProfileContentType.story, 'STORY LIST'))).then((_) {
            });
          }),
      ],
    );
  }

  showEventItemDetail(EventModel item) {
    Navigator.of(context!).push(createAniRoute(EventDetailScreen(item, null))).then((result) {
      if (result != null) {
        notifyListeners();
      }
    });
  }

  showStoryItemDetail(StoryModel item) {
    Navigator.of(context!).push(createAniRoute(StoryDetailScreen(item))).then((result) {
      if (result != null) {
        notifyListeners();
      }
    });
  }

  showEventList() {
    LOG('-->  eventData [$isMyProfile] : ${eventData.length}');
    // sort status..
    List<List<Widget>> showItemList = List.generate(3, (index) => []);
    for (var item in eventData.entries) {
      var isExpired = eventRepo.checkIsExpired(item.value);
      var eventItem = EventCardItem(
        item.value,
        isMyItem: isMyProfile,
        isExpired: isExpired,
        isShowTheme: false,
        isShowUser: false,
        isShowHomeButton: false,
        isShowLike: false,
        itemHeight: UI_CONTENT_ITEM_HEIGHT.w,
        itemPadding: EdgeInsets.only(bottom: 10),
        onRefresh: (updateData) {
          eventData[updateData['id']] = EventModel.fromJson(updateData);
          notifyListeners();
        },
        onShowDetail: (key, status) {
          showEventItemDetail(item.value);
        },
      );
      if (item.value.status == 1 && !isExpired) {
        showItemList[0].add(eventItem);
      } else if (item.value.status == 2 && !isExpired) {
        showItemList[1].add(eventItem);
      } else if (item.value.status > 0) {
        showItemList[2].add(eventItem);
      }
    }

    return ListView(
      children: [
        SubTitleBar(context!, '${'Activated event'.tr} ${showItemList[0].length}'),
        SizedBox(height: 10.h),
        ...showItemList[0],
        SubTitleBar(context!, '${'Disabled event'.tr} ${showItemList[1].length + showItemList[2].length}',
          icon: isDisableOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, onActionSelect: (select) {
          isDisableOpen = !isDisableOpen;
          notifyListeners();
        }),
        if (isDisableOpen)...[
          SizedBox(height: 10.h),
          ...showItemList[1],
          ...showItemList[2],
        ],
        // for (var item in showItemList)
        //   ...item,
      ]
    );
  }

  showStoryList() {
    final space = 10.w;
    List<List<Widget>> showItemList = List.generate(3, (index) => []);
    for (var item in storyData.entries) {
      var eventItem = ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: StoryVerCardItem(
            item.value,
            itemHeight: Get.width.w / 3 - space * 2,
            isShowUser: false,
            onRefresh: (updateData) {
              LOG('--> onRefresh : ${updateData['id']} / ${updateData['status']}');
              storyData[updateData['id']] = StoryModel.fromJson(updateData);
              notifyListeners();
            },
            onShowDetail: (_) {
              showStoryItemDetail(item.value);
            },
          )
      );
      if (item.value.status == 1) {
        showItemList[0].add(eventItem);
      } else if (item.value.status > 0) {
        showItemList[1].add(eventItem);
      }
    }

    return ListView(
      children: [
        SubTitleBar(context!, '${'Activated story'.tr} ${showItemList[0].length}'),
        SizedBox(height: 10.h),
        MasonryGridView.count(
          itemCount: showItemList[0].length,
          crossAxisCount: 3,
          mainAxisSpacing: space,
          crossAxisSpacing: space,
          padding: EdgeInsets.symmetric(vertical: UI_HORIZONTAL_SPACE.w),
          itemBuilder: (BuildContext context, int index) {
            var item = showItemList[0][index];
            return item;
          }
        ),
        SubTitleBar(context!, '${'Disabled story'.tr} ${showItemList[1].length + showItemList[2].length}',
            icon: isDisableOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, onActionSelect: (select) {
              isDisableOpen = !isDisableOpen;
              notifyListeners();
            }),
        if (isDisableOpen)...[
          SizedBox(height: 10.h),
          MasonryGridView.count(
            itemCount: showItemList[1].length,
            crossAxisCount: 3,
            mainAxisSpacing: space,
            crossAxisSpacing: space,
            padding: EdgeInsets.symmetric(vertical: UI_HORIZONTAL_SPACE.w),
            itemBuilder: (BuildContext context, int index) {
              var item = showItemList[1][index];
              return item;
            }
          ),
        ],
      ]
    );
    //   ListView(
    //   children: [
    //     SizedBox(height: 10.h),
    //     ...storyData.entries.map((item) => StoryCardItem(
    //       item.value,
    //       itemHeight: UI_CONTENT_ITEM_HEIGHT.w,
    //       isShowHomeButton: false,
    //       isShowPlaceButton: false,
    //       isShowTheme: false,
    //       isShowUser: false,
    //       isShowLike: false,
    //       itemPadding: EdgeInsets.only(bottom: 10),
    //       onRefresh: (updateData) {
    //         storyData[updateData['id']] = StoryModel.fromJson(updateData);
    //         notifyListeners();
    //       }
    //     )).toList(),
    //     SizedBox(height: 5.h),
    //   ]
    // );
  }

  showContentList(ProfileContentType type) {
    switch(type) {
      case ProfileContentType.event:
        return showEventList();
      case ProfileContentType.story:
        return showStoryList();
    }
  }
}
