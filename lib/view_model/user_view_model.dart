import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:kspot_002/models/story_model.dart';
import 'package:kspot_002/models/recommend_model.dart';
import 'package:kspot_002/services/cache_service.dart';
import 'package:kspot_002/view/bookmark/bookmark_screen.dart';
import 'package:kspot_002/view/event/event_list_screen.dart';
import 'package:kspot_002/view/follow/follow_screen.dart';
import 'package:kspot_002/view/promotion/promotion_screen.dart';
import 'package:kspot_002/view/story/story_detail_screen.dart';
import 'package:kspot_002/view/story/story_edit_screen.dart';
import 'package:kspot_002/widget/bookmark_widget.dart';
import 'package:kspot_002/widget/recommend_item.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/dialogs.dart';
import '../models/etc_model.dart';
import '../models/event_model.dart';
import '../models/promotion_model.dart';
import '../repository/event_repository.dart';
import '../repository/place_repository.dart';
import '../repository/recommend_repository.dart';
import '../utils/utils.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';
import '../view/event/event_detail_screen.dart';
import '../view/event/event_edit_screen.dart';
import '../widget/event_item.dart';
import '../view/profile/profile_content_sceen.dart';
import '../view/profile/profile_tab_screen.dart';
import '../view/story/story_item.dart';
import '../widget/search_widget.dart';

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
  follow,
  bookmark,
  promotion,
  recommend,
  max,
}

class UserViewModel extends ChangeNotifier {
  final repo      = UserRepository();
  final eventRepo = EventRepository();
  final sponRepo  = RecommendRepository();
  final placeRepo = PlaceRepository();

  final cache     = Get.find<CacheService>();
  final searchFocus = GlobalKey();

  final msgTextController = TextEditingController();
  final scrollController = List.generate(ProfileContentType.max.index, (index) => ScrollController());

  UserModel? userInfo;

  var currentTab = 0;
  var isMyProfile = false;
  var isDisableOpen = false;
  var searchText = '';

  // event, story list..
  final listItemShowMax = 5;
  var listPageNow = 0;
  var listPageMax = 0;
  var selectedTab = ProfileContentType.event;

  Future<JSON>? listDataInit;
  List<Map<String, Widget>> showWidgetList = List.generate(ProfileContentType.max.index, (index) => {});
  List<DateTime?> showLastTime = List.generate(ProfileContentType.max.index, (index) => null);
  List<bool> isLastContent = List.generate(ProfileContentType.max.index, (index) => false);

  Map<String, EventModel>     eventData = {};
  Map<String, StoryModel>     storyData = {};
  Map<String, PromotionModel> promotionData = {};
  Map<String, RecommendModel>   recommendData = {};
  JSON snsData = {};
  JSON likeData = {};
  JSON bookmarkData = {};

  initUserModel(UserModel user) {
    userInfo    = user;
    isMyProfile = userInfo!.checkOwner(AppData.USER_ID);
    snsData     = userInfo!.snsDataMap;
    setUserMessage();
  }

  initUserModelFromId(String userId) async {
    final info = await repo.getUserInfo(userId);
    if (info != null) {
      initUserModel(info);
    }
  }

  copyUserModel(UserViewModel source) {
    initUserModel(source.userInfo!);
    eventData     = source.eventData;
    storyData     = source.storyData;
    recommendData   = source.recommendData;
    bookmarkData  = source.bookmarkData;
  }

  refresh() {
    notifyListeners();
  }

  getEventData([bool isShowEmpty = false]) async {
    // if (JSON_NOT_EMPTY(eventData)) {
    //   for (var item in eventData.entries) {
    //     var checkTime = item.value.createTime;
    //     if (showLastTime[ProfileContentType.event.index] == null ||
    //         checkTime.isBefore(showLastTime[ProfileContentType.event.index]!)) {
    //       showLastTime[ProfileContentType.event.index] = checkTime;
    //     }
    //   }
    // }
    // LOG('---> getEventData : ${eventData.length} - ${showLastTime[ProfileContentType.event.index].toString()}');
    var eventNewData = await repo.getEventFromUserId(userInfo!.id, isAuthor: isMyProfile);
        // isAuthor: isMyProfile, lastTime: showLastTime[ProfileContentType.event.index]);
    if (eventNewData.isNotEmpty) {
      for (var item in eventNewData.entries) {
        var placeInfo = await placeRepo.getPlaceFromId(item.value.placeId);
        if (placeInfo != null) {
          item.value.placeInfo = placeInfo;
        }
        eventData[item.key] = item.value;
      }
    // } else {
    //   isLastContent[ProfileContentType.event.index] = true;
    //   if (isShowEmpty) {
    //     ShowErrorToast('No more list'.tr);
    //   }
    }
    return eventData;
  }

  getStoryData([bool isShowEmpty = false]) async {
    if (JSON_NOT_EMPTY(storyData)) {
      for (var item in storyData.entries) {
        var checkTime = item.value.createTime;
        if (showLastTime[ProfileContentType.story.index] == null ||
            checkTime.isBefore(showLastTime[ProfileContentType.story.index]!)) {
          showLastTime[ProfileContentType.story.index] = checkTime;
        }
      }
    } else {
      showLastTime[ProfileContentType.story.index] = DateTime.now();
    }
    LOG('---> getStoryData : ${storyData.length} - ${showLastTime[ProfileContentType.story.index].toString()}');
    var newData = await repo.getStoryFromUserId(userInfo!.id,
        isAuthor: isMyProfile, lastTime: showLastTime[ProfileContentType.story.index]);
    if (newData.isNotEmpty) {
      storyData.addAll(newData);
    } else {
      isLastContent[ProfileContentType.story.index] = true;
      if (isShowEmpty) {
        ShowErrorToast('No more list'.tr);
      }
    }
    return storyData;
  }

  getPromotionData([bool isShowEmpty = false]) async {
    // LOG('--> getRecommendData : ${recommendData.length}');
    promotionData.clear();
    var newData = await repo.getPromotionFromUserId(userInfo!.id, isAuthor: isMyProfile);
    promotionData.addAll(newData);
    return promotionData;
  }

  getRecommendData([bool isShowEmpty = false]) async {
    // LOG('--> getRecommendData : ${recommendData.length}');
    var countIndex = ProfileContentType.recommend.index;
    if (JSON_NOT_EMPTY(recommendData)) {
      for (var item in recommendData.entries) {
        var checkTime = item.value.createTime;
        if (showLastTime[countIndex] == null ||
            checkTime.isBefore(showLastTime[countIndex]!)) {
          showLastTime[countIndex] = checkTime;
        }
      }
    } else {
      showLastTime[countIndex] = DateTime.now();
    }
    LOG('---> getStoryData : ${recommendData.length} - ${showLastTime[countIndex].toString()}');
    var newData = await repo.getRecommendFromUserId(userInfo!.id,
        isAuthor: isMyProfile, lastTime: showLastTime[countIndex]);
    if (newData.isNotEmpty) {
      recommendData.addAll(newData);
    } else {
      isLastContent[countIndex] = true;
      if (isShowEmpty) {
        ShowErrorToast('No more list'.tr);
      }
    }
    // recommendData.clear();
    // var newData = await repo.getRecommendFromUserId(userInfo!.id, isAuthor: isMyProfile);
    // recommendData.addAll(newData);
    return recommendData;
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
        showLoadingDialog(Get.context!, 'uploading now...'.tr);
        var imageData = await ReadFileByte(imageUrl);
        JSON imageInfo = {'id': AppData.userInfo.id, 'data': imageData};
        var upResult = await repo.uploadImageData(imageInfo, 'user_img');
        if (upResult == null) {
          showAlertDialog(Get.context!, 'Profile image'.tr, 'Image update is failed'.tr, '', 'OK'.tr);
        }
        AppData.userInfo.pic = upResult!;
        var setResult = await repo.setUserInfoItem(AppData.userInfo, 'pic');
        hideLoadingDialog();
        if (setResult) {
          showAlertDialog(Get.context!, 'Profile image'.tr, 'Image update is complete'.tr, '', 'OK'.tr);
          AppData.USER_PIC = upResult;
          LOG('---> setUserPic success : ${AppData.USER_PIC}');
          notifyListeners();
        }
      }
    }
  }

  showProfile() {
    return ProfileTabScreen(ProfileMainTab.profile, 'PROFILE'.tr, this);
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
                color: Theme.of(Get.context!).colorScheme.secondary,
                width: 2.0,
              ),
            ),
            child: getCircleImage(STR(userInfo?.pic), UI_FACE_SIZE.w),
          ),
          if (isMyProfile)
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.edit, color: Colors.black, size: UI_MENU_ICON_SIZE.w),
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
                child: showImage(STR(item.value['icon']), Size(UI_SNS_SIZE.sp, UI_SNS_SIZE.sp), color: Theme.of(Get.context!).hintColor)
              ),
            ]
          ]
        ],
      )
    );
  }

  onMessageEdit() {
    showTextInputLimitDialog(Get.context!, 'Edit message'.tr, '', userInfo!.message, 1, 200, 6, null).then((result) async {
      if (result.isNotEmpty) {
        userInfo!.message = result;
        showLoadingDialog(Get.context!, 'Now Uploading...');
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
          decoration: isMyProfile ? inputLabel(Get.context!, '', 'Enter your message to show here'.tr) : viewLabel(Get.context!, '', ''),
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
              child: Icon(Icons.edit, color: Theme.of(Get.context!).hintColor)
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
        height: UI_ITEM_HEIGHT_S.w,
        padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w, vertical: 5.w),
        child: Row(
          children: [
            Icon(icon, size: UI_MENU_ICON_SIZE.w, color: Theme.of(Get.context!).primaryColor.withOpacity(0.5)),
            SizedBox(width: UI_ITEM_SPACE.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ItemTitleLargeStyle(Get.context!)),
                  if (desc.isNotEmpty)...[
                    SizedBox(height: 5.w),
                    Text(desc, style: ItemTitleExStyle(Get.context!)),
                  ],
                ],
              )
            ),
            if (count > 0)...[
            SizedBox(width: 10.w),
            Container(
              height: UI_MENU_ICON_SIZE_S.w,
              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE_S.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(UI_MENU_ICON_SIZE_S.w)),
                color: Theme.of(Get.context!).cardColor,
              ),
              child: Center(
                child: Text('$count', style: ItemTitleNormalStyle(Get.context!)),
              ),
            ),
            SizedBox(width: UI_ITEM_SPACE.w),
            ],
            Icon(Icons.keyboard_arrow_right_outlined, size: UI_MENU_ICON_SIZE.w, color: Theme.of(Get.context!).primaryColor),
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

  showProfileUserBackground() {
    if (userInfo!.backPic != null) {
      return showImageFit(userInfo!.backPic);
    }
    return Image.asset('assets/samples/profile_back_00.png');
  }

  showProfileUserFace() {
    return showUserPic();
  }

  showUserContentList() {
    return Column(
      children: [
        showHorizontalDivider(Size(double.infinity, 30.w)),
      // if (userInfo!.checkOption('event_on'))
        contentItem(Icons.event_available, isMyProfile ? 'MY EVENT LIST'.tr : 'EVENT LIST'.tr, '', 0, () {
          Navigator.of(Get.context!).push(createAniRoute(ProfileContentScreen(this, ProfileContentType.event, 'EVENT LIST'.tr)));
        }),
      // if (userInfo!.checkOption('story_on'))
        contentItem(Icons.photo_library_outlined, isMyProfile ? 'MY STORY LIST'.tr : 'STORY LIST'.tr, '', 0, () {
          Navigator.of(Get.context!).push(createAniRoute(ProfileContentScreen(this, ProfileContentType.story, 'STORY LIST'.tr)));
        }),
        // if (userInfo!.checkOption('follow_on'))
        contentItem(Icons.face, isMyProfile ? 'MY FOLLOW LIST'.tr : 'FOLLOW LIST'.tr, '', 0, () {
          Navigator.of(Get.context!).push(createAniRoute(FollowScreen(userInfo!)));
        }),
        // if (userInfo!.checkOption('bookmark_on'))
        contentItem(Icons.bookmark_border, isMyProfile ? 'MY BOOKMARK LIST'.tr : 'BOOKMARK LIST'.tr, '', 0, () {
          Navigator.of(Get.context!).push(createAniRoute(BookmarkScreen(userInfo!)));
        }),
        if (isMyProfile && APP_STORE_OPEN)...[
          contentItem(Icons.workspace_premium_outlined, 'MY PROMOTION LIST'.tr, '', 0, () {
            Navigator.of(Get.context!).push(createAniRoute(ProfileContentScreen(this, ProfileContentType.promotion, 'MY PROMOTION LIST'.tr, addText: 'PROMOTION'.tr)));
          }),
          contentItem(Icons.star_border_outlined, 'MY RECOMMENDED LIST'.tr, '', 0, () {
            Navigator.of(Get.context!).push(createAniRoute(ProfileContentScreen(this, ProfileContentType.recommend, 'MY RECOMMENDED LIST'.tr, addText: 'RECOMMEND'.tr)));
          }),
        ],
      ],
    );
  }

  showEventItemDetail(EventModel item) {
    Navigator.of(Get.context!).push(createAniRoute(EventDetailScreen(item, item.placeInfo))).then((result) {
      if (result != null) {
        notifyListeners();
      }
    });
  }

  showStoryItemDetail(StoryModel item) {
    Navigator.of(Get.context!).push(createAniRoute(StoryDetailScreen(item))).then((result) {
      if (result != null) {
        notifyListeners();
      }
    });
  }

  showEventList() {
    LOG('-->  eventData [$isMyProfile] : ${eventData.length}');
    // sort status..
    List<Widget> showItemList = [];
    for (var item in eventData.entries) {
      if (searchText.isEmpty || item.value.title.contains(searchText) || item.value.desc.contains(searchText)) {
        var isExpired = eventRepo.checkIsExpired(item.value);
        var showItem = showWidgetList[ProfileContentType.event.index][item.key];
        // LOG('-->  eventData [${showItem == null ? 'null' : '-'}] : ${item.value.toJson()}');
        showItem ??= EventCardItem(
          item.value,
          isMyItem: isMyProfile,
          isExpired: isExpired,
          isShowUser: false,
          isShowHomeButton: false,
          isShowLike: false,
          isShowBookmark: !isMyProfile,
          itemHeight: UI_CONTENT_ITEM_HEIGHT.w,
          itemPadding: EdgeInsets.only(top: 10),
          onRefresh: (updateData) {
            eventData[updateData['id']] = EventModel.fromJson(updateData);
            notifyListeners();
          },
          onShowDetail: (key, status) {
            showEventItemDetail(item.value);
          },
        );
        if (item.value.status > 0) {
          showItemList.add(showItem);
        }
      }
    }
    return Column(
      children: showItemList
    );
  }

  showStoryList() {
    final space = 10.w;
    List<Widget> showItemList = [];
    for (var item in storyData.entries) {
      if (searchText.isEmpty || item.value.desc.contains(searchText)) {
        var showItem = showWidgetList[ProfileContentType.story.index][item.key];
        showItem ??= ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: StoryVerImageItem(
              item.value,
              // itemHeight: Get.width.w / 3 - space * 2,
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
        }
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
    //       SubTitleBar(Get.context!, '${'Activated story'.tr} ${showItemList[0].length}'),
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
    //       SubTitleBar(Get.context!, '${'Disabled story'.tr} ${showItemList[1].length}',
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

  showRecommendList() {
    List<Widget> showItemList = [];
    for (var item in recommendData.entries) {
      if (searchText.isEmpty || item.value.targetTitle.contains(searchText) || item.value.desc.contains(searchText)) {
        var showItem = showWidgetList[ProfileContentType.story.index][item.key];
        showItem ??= ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: RecommendCardItem(
            item.value,
            isShowUser: false,
            onRefresh: (updateData) {
              LOG('--> onRefresh : ${updateData['id']} / ${updateData['status']}');
              recommendData[updateData['id']] = RecommendModel.fromJson(updateData);
              notifyListeners();
            },
            onShowDetail: (key, status) {
              eventRepo.getEventFromId(item.value.targetId).then((result) {
                if (result != null) {
                  showEventItemDetail(result);
                }
              });
            },
          )
        );
        if (item.value.status > 0) {
          showItemList.add(showItem);
        }
      }
    }
    return Column(
      children: showItemList
    );
  }

  showThumbList() {
    LOG('-->  showThumbList [$isMyProfile] : ${recommendData.length}');
    // sort status..
    List<Widget> showItemList = [];
    for (var item in recommendData.entries) {
      var showItem = showWidgetList[ProfileContentType.recommend.index][item.key];
      showItem ??= Container(
      );
      if (item.value.status > 0) {
        showItemList.add(showItem);
      }
    }
    return Column(
      children: showItemList
    );
  }

  getStartContentData(ProfileContentType type) async {
    LOG('-->  getStartContentData : $type');
    switch(type) {
      case ProfileContentType.event:
        if (eventData.isEmpty) {
          return getEventData(false);
        } else {
          return eventData;
        }
      case ProfileContentType.story:
        if (storyData.isEmpty) {
          return getStoryData(false);
        } else {
          return storyData;
        }
      case ProfileContentType.promotion:
        if (promotionData.isEmpty) {
          return getRecommendData(false);
        } else {
          return promotionData;
        }
      case ProfileContentType.recommend:
        if (recommendData.isEmpty) {
          return getRecommendData(false);
        } else {
          return recommendData;
        }
    }
  }

  reloadContentData(ProfileContentType type, [bool isShowEmpty = true]) async {
    LOG('--> reloadContentData : $type / $isLastContent / ${AppData.isMainActive}');
    if (isLastContent[type.index] || !AppData.isMainActive) return;
    AppData.isMainActive = false;
    showLoadingToast(Get.context!);
    await Future.delayed(Duration(seconds: 1));
    switch(type) {
      case ProfileContentType.event:
        await getEventData(isShowEmpty);
        break;
      case ProfileContentType.story:
        await getStoryData(isShowEmpty);
        break;
      case ProfileContentType.recommend:
        await getRecommendData(isShowEmpty);
        break;
    }
    AppData.isMainActive = true;
    scrollController[type.index].animateTo(scrollController[type.index].position.maxScrollExtent - 1,
      duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
    hideLoadingDialog();
    notifyListeners();
  }

  showContentSearchBar() {
    return SearchWidget(
      key: searchFocus,
      initialText: searchText,
      isShowList: true,
      padding: EdgeInsets.zero,
      onEdited: (result, status) {
        LOG('--> SearchWidget edited : $result / $status');
        if (status < 0) {
          searchText = '';
          // isSearched = false;
          // if (isSearched) {
          //   unFocusAll(context);
          // }
        } else {
          searchText = result;
        }
        notifyListeners();
      },
    );
  }

  showContentList(ProfileContentType type) {
    if (type == ProfileContentType.story || type == ProfileContentType.recommend) {
      scrollController[type.index].addListener(() {
        if (scrollController[type.index].position.pixels == scrollController[type.index].position.maxScrollExtent) {
          reloadContentData(type);
        }
      });
    }
    return LayoutBuilder(
      builder: (context, layout) {
        return Container(
          height: layout.maxHeight,
          child: SingleChildScrollView(
            controller: scrollController[type.index],
            child: Container(
              constraints: BoxConstraints(
                minHeight: layout.maxHeight + 1,
              ),
              child: Column(
                children: [
                  if (type == ProfileContentType.event)
                    showEventList(),
                  if (type == ProfileContentType.story)
                    showStoryList(),
                  if (type == ProfileContentType.recommend)
                    showRecommendList(),
                ],
              )
            )
          )
        );
      }
    );
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
      case ProfileContentType.promotion:
        // Get.to(() => PromotionScreen(isSelect: true))!.then((result1) {
        //   Get.to(() => EventListScreen(isMyProfile, isSelectable: true))!.then((result) {
        //     if (result != null) {
        //       LOG('--> EventListScreen result : ${result.toJson()}');
        //       showEventRecommendDialog(Get.context!, result, AppData.userInfo.creditCount).then((dResult) {
        //         LOG('--> showEventRecommendDialog result : $dResult');
        //         if (dResult != null) {
        //           sponRepo.addRecommendItem(dResult).then((addItem) {
        //             if (addItem != null) {
        //               recommendData[addItem['id']] = RecommendModel.fromJson(addItem);
        //               LOG('--> recommendData Success : ${recommendData.length} / ${addItem.toString()}');
        //               ShowToast('Event Recommendship Success'.tr);
        //               notifyListeners();
        //             } else {
        //               ShowToast('Event Recommendship Failed'.tr);
        //             }
        //           });
        //         }
        //       });
        //     }
        //   });
        // });
        break;
      case ProfileContentType.recommend:
        Get.to(() => EventListScreen(isMyProfile, isSelectable: true))!.then((result) {
          LOG('--> EventListScreen result : ${result.toString()}');
          if (result != null && result.isNotEmpty) {
            EventModel eventInfo = result.first;
            showEventRecommendDialog(Get.context!, eventInfo, AppData.userInfo.creditCount, '').then((dResult) {
              if (dResult != null) {
                LOG('--> showEventRecommendDialog result : ${dResult.toJson()}');
                sponRepo.addRecommendItem(dResult).then((addItem) {
                  if (addItem != null) {
                    recommendData[addItem['id']] = RecommendModel.fromJson(addItem);
                    var recommendItem = RecommendData.fromRecommendModel(RecommendModel.fromJson(addItem));
                    cache.eventData[result.id]!.recommendData ??= [];
                    cache.eventData[result.id]!.recommendData!.add(recommendItem);
                    LOG('--> recommendData Success : ${recommendData.length} / ${addItem.toString()}');
                    ShowToast('Event Recommend Success'.tr);
                    notifyListeners();
                  } else {
                    ShowToast('Event Recommend Failed'.tr);
                  }
                });
              }
            });
          }
        });
        break;
    }
  }

  @override
  void dispose() {
    for (var item in scrollController) {
      item.dispose();
    }
    super.dispose();
  }
}
