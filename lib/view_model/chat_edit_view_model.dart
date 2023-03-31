import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/app_data.dart';
import 'package:kspot_002/models/chat_model.dart';
import 'package:kspot_002/view/chatting/chatting_group_item.dart';
import 'package:uuid/uuid.dart';

import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/etc_model.dart';
import '../models/user_model.dart';
import '../repository/chat_repository.dart';
import '../repository/message_repository.dart';
import '../repository/user_repository.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/follow/follow_screen.dart';
import '../view/profile/profile_screen.dart';
import '../view/profile/profile_target_screen.dart';
import '../widget/card_scroll_viewer.dart';
import '../widget/edit/edit_component_widget.dart';
import '../widget/edit/edit_list_widget.dart';

class ChatEditViewModel extends ChangeNotifier {
  final repo      = ChatRepository();
  final userRepo  = UserRepository();
  final imageGalleryKey = GlobalKey();

  BuildContext? buildContext;
  ChatRoomModel? editItem;
  String inviteMessage = '';
  final tabText = ['PUBLIC CHAT'.tr, 'PRIVATE CHAT'.tr];
  JSON memberData = {};
  JSON picInfo = {};

  var isEdited = false;
  var type = 0;

  get editMemberToJSON {
    if (editItem != null) {
      return editItem!.getMemberDataMap;
    }
    return {};
  }

  get createButtonEnable {
    switch(type) {
      case 0:
        return editItem!.title.isNotEmpty && inviteMessage.isNotEmpty;
      default:
        return memberData.isNotEmpty && inviteMessage.isNotEmpty;
    }
  }

  init(context, selectedTab) {
    buildContext = context;
    editItem ??= ChatRoomModelEx.create(AppData.USER_ID, selectedTab);
    type = selectedTab;
    editItem!.type = type;
  }

  onItemAdd(EditListType type, JSON listItem) {
    unFocusAll(buildContext!);
    switch (type) {
      case EditListType.member:
        Get.to(() => FollowScreen(AppData.userInfo, selectData: editItem!.getMemberDataMap, isShowMe: false, isSelectable: true))!.then((value) {
          LOG("-->  FollowScreen result : $value");
          if (value == null) return;
          memberData = {};
          if (value.isNotEmpty) {
            for (var item in value.entries) {
              final addItem = {
                'id': item.key,
                'status': 1,
                'nickName': STR(item.value['nickName']),
                'pic': STR(item.value['pic'])
              };
              memberData[item.key] = addItem;
              LOG("--> memberData add [${item.key}] : ${memberData.length}");
            }
          }
          notifyListeners();
        });
        break;
    }
  }

  onItemSelected(EditListType type, String key, int status) async {
    unFocusAll(buildContext!);
    switch (type) {
      case EditListType.member:
        if (status == 0) {
          var userInfo = await userRepo.getUserInfo(memberData[key]['id']);
          if (userInfo != null) {
            Get.to(() => ProfileTargetScreen(userInfo));
          } else {
            showUserAlertDialog(buildContext!, '${memberData[key]['id']}');
          }
        } else {
          showAlertYesNoDialog(buildContext!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            if (result == 1) {
              memberData.remove(key);
              editItem!.setMemberDataMap(memberData);
              isEdited = true;
              notifyListeners();
            }
          });
        }
        break;
    }
  }

  showTypeSelect() {
    return Column(
    children: [
      SubTitle(buildContext!, 'TYPE SELECT'.tr, child: SubTitleSmall(buildContext!, '(You can choose only one type)'.tr, height: 15)),
      SizedBox(height: 10.w),
      Row(
        children: tabText.map((item) => Expanded(
          child: GestureDetector(
            onTap: () {
                isEdited = true;
                editItem!.type = tabText.indexOf(item);
                type = editItem!.type;
                // initDayData();
                LOG('----> selectTab type : $type');
                notifyListeners();
            },
            child: Container(
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: type == tabText.indexOf(item) ? Theme.of(buildContext!).colorScheme.tertiaryContainer :
                Theme.of(buildContext!).colorScheme.primary.withOpacity(0.05),
                borderRadius: tabText.indexOf(item) == 0 ? BorderRadius.only(
                    topLeft:Radius.circular(10),
                    bottomLeft:Radius.circular(10)
                ) :  BorderRadius.only(
                    topRight:Radius.circular(10),
                    bottomRight:Radius.circular(10)
                ),
                border: Border.all(
                    color: type == tabText.indexOf(item) ? Theme.of(buildContext!).colorScheme.tertiary.withOpacity(0.8) :
                    Theme.of(buildContext!).colorScheme.primary.withOpacity(0.5), width: type == tabText.indexOf(item) ? 2.0 : 1.0),
                ),
                child: Text(item,
                    style: type == tabText.indexOf(item) ? ItemTitleHotStyle(buildContext!) : ItemTitleStyle(buildContext!),
                    textAlign: TextAlign.center),
              )
            )
          )).toList(),
        ),
      ]
    );
  }


  setImageData() {
    editItem!.pic = STR(picInfo['url']);
    LOG('----> setImageData: $picInfo');
  }

  picLocalImage() async {
    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      var url   = await ShowImageCroper(pickImage.path);
      var data  = await ReadFileByte(url);
      var resizeData = await resizeImage(data!, IMAGE_SIZE_MAX) as Uint8List;
      var key = Uuid().v1();
      picInfo = {'id': key, 'type': 0, 'url': '', 'data': resizeData};
      // LOG('----> picLocalImage: ${picInfo.toString()} / $key');
    }
    setImageData();
    notifyListeners();
  }

  showImageSelector() {
    LOG('----> showImageSelector: ${picInfo.toString()}');
    return ImageEditScrollViewer(
        picInfo.isNotEmpty ? {picInfo['id']: picInfo} : {},
        key: imageGalleryKey,
        title: 'ROOM IMAGE'.tr,
        addText: 'Photo Add'.tr,
        onActionCallback: (key, status) {
          LOG('----> onActionCallback: $key / $status');
          switch (status) {
            case 1: {
              picLocalImage();
              break;
            }
            case 2: {
              picInfo = {};
              notifyListeners();
              break;
            }
          }
        }
    );
  }

  showTitle() {
    return EditTextField(buildContext!, 'TITLE'.tr, editItem!.title, hint: 'Room Title *'.tr, maxLength: TITLE_LENGTH,
      maxLines: 1, keyboardType: TextInputType.text, onChanged: (value) {
        editItem!.title = value;
      });
  }

  showPassword() {
    return EditTextField(buildContext!, 'PASSWORD'.tr, editItem!.password, hint: 'Password *'.tr, maxLength: PASSWORD_LENGTH,
      maxLines: 1, keyboardType: TextInputType.text, onChanged: (value) {
        editItem!.password = value;
      });
  }

  showInviteMessage() {
    return EditTextField(buildContext!, 'INVITE MESSAGE'.tr, inviteMessage, hint: 'Enter message *'.tr, maxLength: TITLE_LENGTH,
      maxLines: 1, keyboardType: TextInputType.text, onChanged: (value) {
        inviteMessage = value;
      });
  }

  showMembers() {
    return EditListWidget(memberData, title:'INVITE START MEMBERS', EditListType.member, onItemAdd,
        onItemSelected);
  }

  uploadStart() async {
    LOG('---> uploadStart: $inviteMessage / $createButtonEnable');
    if (!createButtonEnable || !AppData.isMainActive) return;
    AppData.isMainActive = false;
    showLoadingDialog(buildContext!, 'Uploading now...'.tr);
    // upload new images..
    if (picInfo.isNotEmpty && picInfo['data'] != null) {
      var result = await repo.uploadImageInfo(picInfo);
      if (result != null) {
        editItem!.pic = result;
        LOG('---> editItem!.pic: $result');
      } else {
        hideLoadingDialog();
        showAlertDialog(buildContext!, 'Chat room create'.tr, 'Chat room create failed'.tr, '', 'OK'.tr);
        AppData.isMainActive = true;
        return;
      }
    }
    editItem!.memberList = [];
    editItem!.memberData = [];
    editItem!.memberList.add(AppData.USER_ID);
    editItem!.memberData.add(MemberData(
        id: AppData.USER_ID,
        status: 2, // 1: normal 2: room manager..
        nickName: AppData.USER_NICKNAME,
        pic: AppData.USER_PIC,
        createTime: DateTime.now()
      )
    );
    for (var item in memberData.entries) {
      editItem!.memberList.add(item.key);
      editItem!.memberData.add(MemberData.fromJson(item.value));
    }
    editItem!.userId = AppData.USER_ID;
    editItem!.status = 1;

    editItem!.groupId = AppData.currentEventGroup!.id;
    editItem!.country = AppData.currentCountry;
    editItem!.countryState = AppData.currentState;

    LOG('---> upload editItem: ${editItem!.toJson()}');

    repo.addRoomItem(editItem!).then((result) {
      LOG('---> addRoomItem result: ${result.toString()}');
      editItem!.id = result['id'];
      repo.createChatItem(editItem!, '', inviteMessage);
      hideLoadingDialog();
      AppData.isMainActive = true;
      showAlertDialog(buildContext!, 'Chat room create'.tr, 'Chat room create complete'.tr, '', 'OK'.tr).then((_) {
        Get.back(result: editItem);
      });
    });
  }
}