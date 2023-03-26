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
import 'package:kspot_002/view/story/story_edit_screen.dart';
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
import '../view/event/event_edit_screen.dart';
import '../view/event/event_item.dart';
import '../view/profile/profile_content_sceen.dart';
import '../view/profile/profile_tab_screen.dart';
import '../view/story/story_item.dart';

enum ProfileMainTab {
  profile,
  follow,
  bookmark,
  like,
  max,
}

enum ProfileContentType {
  event,
  story,
}

class UserViewModel extends ChangeNotifier {
  final repo = UserRepository();
  final eventRepo = EventRepository();
  final msgTextController = TextEditingController();
  final scrollController = ScrollController();

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
  JSON likeData = {};
  JSON bookmarkData = {};
  DateTime? eventLastTime;
  DateTime? eventLastTime2;
  DateTime? storyLastTime;
  DateTime? storyLastTime2;

  init(context) {
    this.context = context;
  }

  initUserModel(UserModel user) {
    userInfo    = user;
    isMyProfile = userInfo!.checkOwner(AppData.USER_ID);
    snsData     = userInfo!.snsDataMap;
    tabKeyList  = List.generate(ProfileMainTab.max.index, (index) => GlobalKey());
    tabList = [
      ProfileTabScreen(ProfileMainTab.profile   , 'PROFILE'.tr  , this, key: tabKeyList[0]),
      ProfileTabScreen(ProfileMainTab.follow    , 'FOLLOW'.tr   , this, key: tabKeyList[1]),
      ProfileTabScreen(ProfileMainTab.bookmark  , 'BOOKMARK'.tr , this, key: tabKeyList[2]),
      // ProfileTabScreen(ProfileMainTab.like      , 'LIKE'.tr     , this, key: tabKeyList[3]),
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

  getEventData() async {
    if (JSON_NOT_EMPTY(eventData)) {
      for (var item in eventData.entries) {
        var checkTime = DateTime.parse(item.value.createTime);
        if (item.value.status == 1 && (eventLastTime == null || checkTime.isBefore(eventLastTime!))) {
          eventLastTime = checkTime;
        }
        if (item.value.status == 2 && (eventLastTime2 == null || checkTime.isBefore(eventLastTime2!))) {
          eventLastTime2 = checkTime;
        }
      }
    }
    LOG('---> getEventData : ${eventData.length} - ${eventLastTime.toString()}');
    var eventNewData = await repo.getEventFromUserId(userInfo!.id, isAuthor: isMyProfile,
        lastTime: storyLastTime, lastTime2: storyLastTime2);
    if (eventNewData.isNotEmpty) {
      eventData.addAll(eventNewData);
    } else {
      ShowErrorToast('No more event'.tr);
    }
    return eventData;
  }

  getStoryData() async {
    if (JSON_NOT_EMPTY(storyData)) {
      for (var item in storyData.entries) {
        var checkTime = DateTime.parse(item.value.createTime);
        if (item.value.status == 1 && (storyLastTime == null || checkTime.isBefore(storyLastTime!))) {
          storyLastTime = checkTime;
        }
        if (item.value.status == 2 && (storyLastTime2 == null || checkTime.isBefore(storyLastTime2!))) {
          storyLastTime2 = checkTime;
        }
      }
    }
    LOG('---> getStoryData : ${storyData.length} - ${storyLastTime.toString()}');
    var storyNewData = await repo.getStoryFromUserId(userInfo!.id,
        isAuthor: isMyProfile, lastTime: storyLastTime, lastTime2: storyLastTime2);
    if (storyNewData.isNotEmpty) {
      storyData.addAll(storyNewData);
    } else {
      ShowErrorToast('No more story'.tr);
    }
    return storyData;
  }

  getContentData() async {
    await getEventData();
    await getStoryData();
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
      var showItem = EventCardItem(
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
        showItemList[0].add(showItem);
      } else if (item.value.status == 2 && !isExpired) {
        showItemList[1].add(showItem);
      } else if (item.value.status > 0) {
        showItemList[2].add(showItem);
      }
    }

    return Column(
      children: [
        if (showItemList[0].isNotEmpty)...[
          SubTitleBar(context!, '${'Activated event'.tr} ${showItemList[0].length}'),
          SizedBox(height: 10.h),
          ...showItemList[0],
        ],
        if (isMyProfile && (showItemList[1].isNotEmpty || showItemList[2].isNotEmpty))...[
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
        ],
      ]
    );
  }

  showStoryList() {
    final space = 10.w;
    // List<List<Widget>> showItemList = List.generate(3, (index) => []);
    List<Widget> showItemList = [];
    for (var item in storyData.entries) {
      var showItem = ClipRRect(
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
      if (item.value.status > 0) {
        showItemList.add(showItem);
        // if (item.value.showStatus == 1) {
        //   showItemList[0].add(showItem);
        // } else {
        //   showItemList[1].add(showItem);
        // }
      }
    }

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: showItemList.length,
      crossAxisCount: 3,
      mainAxisSpacing: space,
      crossAxisSpacing: space,
      padding: EdgeInsets.symmetric(vertical: UI_HORIZONTAL_SPACE.w),
      itemBuilder: (BuildContext context, int index) {
        var item = showItemList[index];
        return item;
      }
    );

    // return Column(
    //   children: [
    //     if (showItemList[0].isNotEmpty)...[
    //       SubTitleBar(context!, '${'Activated story'.tr} ${showItemList[0].length}'),
    //       MasonryGridView.count(
    //         shrinkWrap: true,
    //         physics: NeverScrollableScrollPhysics(),
    //         itemCount: showItemList[0].length,
    //         crossAxisCount: 3,
    //         mainAxisSpacing: space,
    //         crossAxisSpacing: space,
    //         padding: EdgeInsets.symmetric(vertical: UI_HORIZONTAL_SPACE.w),
    //         itemBuilder: (BuildContext context, int index) {
    //           var item = showItemList[0][index];
    //           return item;
    //         }
    //       ),
    //     ],
    //     if (showItemList[1].isNotEmpty)...[
    //       SubTitleBar(context!, '${'Disabled story'.tr} ${showItemList[1].length}',
    //         icon: isDisableOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, onActionSelect: (select) {
    //           isDisableOpen = !isDisableOpen;
    //           notifyListeners();
    //         }),
    //       if (isDisableOpen)...[
    //         MasonryGridView.count(
    //           shrinkWrap: true,
    //           physics: NeverScrollableScrollPhysics(),
    //           itemCount: showItemList[1].length,
    //           crossAxisCount: 3,
    //           mainAxisSpacing: space,
    //           crossAxisSpacing: space,
    //           padding: EdgeInsets.symmetric(vertical: UI_HORIZONTAL_SPACE.w),
    //           itemBuilder: (BuildContext context, int index) {
    //             var item = showItemList[1][index];
    //             return item;
    //           }
    //         ),
    //       ],
    //     ],
    //   ]
    // );
  }

  reloadContentData(ProfileContentType type) async {
    LOG('--> reloadContentData : $type / ${AppData.isMainActive}');
    if (!AppData.isMainActive) return;
    AppData.isMainActive = false;
    await Future.delayed(Duration(seconds: 1));
    switch(type) {
      case ProfileContentType.event:
        await getEventData();
        break;
      case ProfileContentType.story:
        await getStoryData();
        break;
    }
    AppData.isMainActive = true;
    notifyListeners();
  }

  showContentList(ProfileContentType type) {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        reloadContentData(type);
      }
    });
    return LayoutBuilder(
      builder: (context, layout) {
        return Container(
          height: layout.maxHeight,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Container(
              constraints: BoxConstraints(
                minHeight: layout.maxHeight + 1,
              ),
              child: showStoryList(),
            )
          )
        );
      }
    );
    //   child: LayoutBuilder(
    //   builder: (context, layout)
    // {
    //   return ListView(
    //     controller: storyScrollController,
    //     children: [
    //       if (type == ProfileContentType.event)
    //         showEventList(),
    //       if (type == ProfileContentType.story)
    //         Container(
    //           height: layout.maxHeight,
    //           child: showStoryList(),
    //         ),
    //     ],
    //   );
    // }
    // )
  }

  addNewContent(ProfileContentType type) {
    switch(type) {
      case ProfileContentType.event:
        Get.to(() => EventEditScreen())!.then((result) {
          if (result != null) {
            LOG('--> EventEditScreen result : ${result.toJson()}');
            eventData[result.id] = result;
            notifyListeners();
          }
        });
        break;
      case ProfileContentType.story:
        Get.to(() => StoryEditScreen())!.then((result) {
          if (result != null) {
            LOG('--> StoryEditScreen result : ${result.toJson()}');
            storyData[result.id] = result;
            notifyListeners();
          }
        });
        break;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
