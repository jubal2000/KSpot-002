
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/setup/setup_content_screen.dart';
import 'package:kspot_002/widget/rounded_button.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/etc_model.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../view/setup/setup_block_screen.dart';
import '../view/setup/setup_contact_screen.dart';
import '../view/setup/setup_faq_screen.dart';
import '../view/setup/setup_notice_screen.dart';
import '../view/setup/setup_profile_screen.dart';
import '../view/setup/setup_push_screen.dart';
import '../view/setup/setup_service_screen.dart';
import '../widget/dropdown_widget.dart';
import '../widget/edit/edit_setup_widget.dart';
import '../widget/theme_select_widget.dart';
import '../widget/verify_phone_widget.dart';

enum SetupTextType {
  nickName,
  realName,
  refundBank,
  refundAcc,
  refundAuth,

  email,
  mobileIntl,
  mobile,
}


class SetupViewModel extends ChangeNotifier {
  final api = Get.find<ApiService>();
  final userRepo = UserRepository();

  final textController  = List<TextEditingController>.generate(SetupTextType.values.length, (index) => TextEditingController());
  final formKey         = GlobalKey<FormState>();
  final minText         = 2;
  final buttonHeight    = 60.0;
  final genderN         = {'f': 'Female', 'm': 'Male', 'n': 'No select'};
  final startYear       = DateTime.now().year - 12;
  JSON pushSettingData  = {};
  JSON optionData  = {};

  late final genderList   = List.generate(genderN.length, (index) => {'title': genderN[genderN.keys.elementAt(index)], 'key': genderN.keys.elementAt(index)});
  late final yearList     = List.generate(100, (index) => {'title': '${startYear - index}', 'key': '${startYear - index}'});
  var itemEditFlag        = List.generate(SetupTextType.values.length, (index) => false);
  var isEditMode          = false;
  var isEmailValidate     = false;

  Function(bool)? onRefresh;
  UserModel? editUserInfo;
  BuildContext? context;
  bool isEdited = false;


  init(BuildContext context) {
    this.context = context;
    refreshData();
  }

  refreshData() {
    AppData.isMainActive = true;
    LOG('--> SetupViewModel init');

    // copy user for edit..
    editUserInfo = UserModel.fromJson(AppData.userInfo.toJson());
    editUserInfo!.refundBank ??= BankData.empty;

    // set profile..
    textController[SetupTextType.nickName.index].text   = editUserInfo!.nickName;
    textController[SetupTextType.realName.index].text   = editUserInfo!.realName;
    textController[SetupTextType.refundBank.index].text = editUserInfo!.refundBank!.name;
    textController[SetupTextType.refundAcc.index].text  = editUserInfo!.refundBank!.account;
    textController[SetupTextType.refundAuth.index].text = editUserInfo!.refundBank!.author;

    // set contact..
    textController[SetupTextType.email.index].text      = editUserInfo!.email;
    textController[SetupTextType.mobileIntl.index].text = editUserInfo!.mobileIntl;
    textController[SetupTextType.mobile.index].text     = editUserInfo!.mobile;

  }

  setUserData() async {
    if (editUserInfo == null) return false;
    LOG('--> setUserData : ${editUserInfo!.toJson()}');
    showLoadingDialog(context!, 'updating now...'.tr);
    AppData.userInfo = UserModel.fromJson(editUserInfo!.toJson());
    var result = await userRepo.setMyUserInfo();
    hideLoadingDialog();
    if (result ) {
      ShowToast('Update is complete'.tr);
    } else {
      ShowErrorToast('Update is failed'.tr);
    }
    return result;
  }

  showSetupList(Function(bool) onRefresh) {
    this.onRefresh = onRefresh;
    return setupList;
  }

  showTextInputField(
    TextEditingController controller,
    Function(String)? onChanged,
    {
      bool? enabled,
      TextInputType? keyboardType,
      String? label,
      int? maxLines,
      int? maxLength,
      FormFieldValidator? validator,
    }) {
    return TextFormField(
      enabled: enabled ?? true,
      controller: controller,
      decoration: enabled ?? true ? inputLabel(context!, label ?? '', '') : viewLabel(context!, label ?? '', ''),
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      autovalidateMode: AutovalidateMode.always,
      style: ItemTitleNormalStyle(context!),
      validator: validator,
      onChanged: (value) {
        if (onChanged != null) onChanged(controller.text);
        isEdited = true;
      },
    );
  }

  showDropListSelect(String title, List<JSON> dropList, String selectKey, Function(String) onChanged) {
    return DropDownMenuWidget(
      dropList,
      title: title,
      selectKey: selectKey,
      onSelected: (key) {
        onChanged(key);
        isEdited = true;
        notifyListeners();
      },
    );
  }

  showTextEditButton(SetupTextType type,
    {
      bool isCanEdit    = true,
      bool isValidated  = true,
      bool isEnabled    = true,
      int? maxLines,
      Function(String)? onChanged,
      Function()? onPressed,
    }) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: showTextInputField(textController[type.index], onChanged,
              maxLines: maxLines ?? 1,
              enabled: isEnabled,
            ),
          ),
          SizedBox(width: 10),
          if (isCanEdit)...[
            if (isEditMode)
              IconButton(
                onPressed: () {
                },
                icon: Icon(Icons.edit, color: Theme.of(context!).disabledColor),
              ),
            if (!isEditMode)
              IconButton(
                onPressed: () {
                  itemEditFlag[type.index] = !itemEditFlag[type.index];
                  isEditMode = true;
                  if (onPressed != null) onPressed();
                  notifyListeners();
                },
                icon: Icon(Icons.edit),
              ),
          ],
          if (!isCanEdit)...[
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Icon(
                isValidated ? Icons.check : Icons.close,
                size: 30,
                color: isValidated ? Colors.green : Colors.grey,
              )
            )
          ]
        ],
      )
    );
  }

  showMobileEdit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerifyPhoneWidget(
          editUserInfo!.mobile,
          phoneIntl: editUserInfo!.mobileIntl,
          isSignIn: false,
          isValidated: true,
          onCheckComplete: (intl, number, _) {
            isEditMode = false;
            itemEditFlag[SetupTextType.mobile.index] = false;
            ShowToast('Mobile change completed'.tr);
            refreshData();
            notifyListeners();
          },
        ),
        RoundedButton.edit(
          'CANCEL'.tr,
          fullWidth: false,
          minWidth: 80.w,
          radius: 8.w,
          textColor: Theme.of(context!).colorScheme.inverseSurface,
          backgroundColor: Theme.of(context!).colorScheme.secondary.withOpacity(0.5),
          onPressed: () {
            isEditMode = false;
            itemEditFlag[SetupTextType.mobile.index] = false;
            ShowToast('Mobile change canceled'.tr);
            notifyListeners();
          },
        ),
      ]
    );
  }

  showEmailEdit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: showTextInputField(
                textController[SetupTextType.email.index],
                (value) {
                  editUserInfo!.emailNew = textController[SetupTextType.email.index].text;
                  notifyListeners();
                },
                validator: (value) {
                  if (!EmailValidator.validate(value)) return 'Please check email';
                  return null;
                }
              )
            ),
            SizedBox(width: 10.w),
            if (STR(editUserInfo!.emailNew).isNotEmpty &&
              EmailValidator.validate(editUserInfo!.emailNew!) && editUserInfo!.emailNew != editUserInfo!.email)
              RoundedButton.active(
                'CHANGE'.tr,
                fullWidth: false,
                minWidth: 80.w,
                radius: 8.w,
                height: UI_BUTTON_HEIGHT_S.h,
                textColor: Theme.of(context!).colorScheme.inverseSurface,
                backgroundColor: Theme.of(context!).colorScheme.secondary.withOpacity(0.5),
                onPressed: () {
                  editUserInfo!.email = editUserInfo!.emailNew!;
                  AppData.userInfo = editUserInfo!;
                  userRepo.setUserInfoItem(AppData.userInfo, 'email').then((result) {
                    if (result) {
                      isEditMode = false;
                      itemEditFlag[SetupTextType.email.index] = false;
                      ShowToast('Email change success'.tr);
                      notifyListeners();
                    } else {
                      ShowToast('Email change failed'.tr);
                    }
                  });
                },
              ),
          ]
        ),
        SizedBox(height: 10),
        RoundedButton.edit(
          'CANCEL'.tr,
          fullWidth: false,
          minWidth: 80.w,
          radius: 8.w,
          textColor: Theme.of(context!).colorScheme.inverseSurface,
          backgroundColor: Theme.of(context!).colorScheme.secondary.withOpacity(0.5),
          onPressed: () {
            isEditMode = false;
            itemEditFlag[SetupTextType.email.index] = false;
            ShowToast('Email change canceled'.tr);
            notifyListeners();
          },
        ),
      ]
    );
  }


  updateProfile(Function(bool) onEditEnd) {
    if (!isEdited || !AppData.isMainActive) return;
    if (formKey.currentState?.validate() ?? false) {
      showAlertYesNoDialog(context!, 'Profile Update'.tr,
          'Do you want to save the modified profile?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
        if (result == 1) {
          AppData.isMainActive = false;
          setUserData().then((result) {
            if (result) {
              isEdited = false;
              onEditEnd(result);
            }
            AppData.isMainActive = true;
          });
        }
      });
    }
  }

  initPushSetting() {
    pushSettingData = {};
    if (LIST_EMPTY(AppData.userInfo.optionPush)) {
      AppData.userInfo.optionPush = [];
      for (var item in AppData.INFO_PUSH_OPTION.entries) {
        if (item.value.runtimeType != String && item.value.runtimeType != int) {
          pushSettingData[item.key] = item.value;
        }
      }
      userRepo.setUserInfoItem(AppData.userInfo, 'optionPush');
    } else {
      for (var item in AppData.userInfo.optionPush!) {
        LOG('--> initPushSetting : ${item.value.toString()}');
        pushSettingData[item.id] = item.value;
      }
    }
  }

  showPushSetting() {
    return EditSetupWidget(
      'Push notification'.tr,
      pushSettingData,
      AppData.INFO_PUSH_OPTION,
      showAllButton: true,
      onDataChanged: (newOption) {
        AppData.userInfo.optionPush = [];
        for (var item in newOption.entries) {
          if (BOL(item.value)) {
            AppData.userInfo.optionPush!.add(OptionData(id: item.key, value: item.value));
          }
        }
        userRepo.setUserInfoItem(AppData.userInfo, 'optionPush').then((result) {
          if (result) {
            initPushSetting();
          }
        });
      }
    );
  }

  initContentSetting() {
    optionData = {};
    if (LIST_EMPTY(AppData.userInfo.optionData)) {
      AppData.userInfo.optionPush = [];
      for (var item in AppData.INFO_PUSH_OPTION.entries) {
        if (item.value.runtimeType != String && item.value.runtimeType != int) {
          optionData[item.key] = item.value;
        }
      }
      userRepo.setUserInfoItem(AppData.userInfo, 'optionData');
    } else {
      for (var item in AppData.userInfo.optionPush!) {
        optionData[item.id] = item.value;
      }
    }
  }

  showContentSetting() {
    return EditSetupWidget(
      'Content setting'.tr,
      optionData,
      AppData.INFO_PLAY_OPTION,
      showAllButton: true,
      onDataChanged: (newOption) {
        AppData.userInfo.optionData = [];
        for (var item in newOption.entries) {
          if (BOL(item.value)) {
            AppData.userInfo.optionData!.add(OptionData(id: item.key, value: item.value));
          }
        }
        userRepo.setUserInfoItem(AppData.userInfo, 'optionData').then((result) {
          if (result) {
            initContentSetting();
          }
        });
      }
    );
  }

  showThemeSetting() {
    return ThemeSelectWidget(
      AppData.currentThemeMode,
      AppData.currentThemeIndex,
      'Theme setting'.tr,
      (mode, index, color) {
        LOG('--> ThemeSelectWidget onChanged : $mode, $index, $color');
        AppData.currentThemeMode  = mode;
        AppData.currentThemeIndex = index;
        AppData.themeNotifier.setTheme(mode, index);
      }
    );
  }

  onSelect(code) async {
    switch (code) {
      case 'info':
        Get.to(() => SetupProfileScreen())!.then((result) {
          if (onRefresh != null) onRefresh!(result != null && result);
        });
        break;
      case 'contact':
        Get.to(() => SetupContactScreen())!.then((result) {
          if (onRefresh != null) onRefresh!(result != null && result);
        });
        break;
      case 'push':
        Get.to(() => SetupPushScreen())!.then((result) {
          if (onRefresh != null) onRefresh!(result != null && result);
        });
        break;
      case 'playAuto':
        Get.to(() => SetupContentScreen())!.then((result) {
          if (onRefresh != null) onRefresh!(result != null && result);
        });
        break;
      case 'block':
        Get.to(() => SetupBlockScreen())!.then((result) {
          if (onRefresh != null) onRefresh!(result != null && result);
        });
        break;
      case 'service':
        Get.to(() => SetupServiceScreen())!.then((result) {
          if (onRefresh != null) onRefresh!(result != null && result);
        });
        break;
      // case 'promotion':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(PromotionListScreen()));
      //   Get.to(() => SetupServiceScreen())!.then((result) {
      //     if (onRefresh != null) onRefresh!(result != null && result);
      //   });
      //   break;
      case 'notice':
        Get.to(() => SetupNoticeScreen())!.then((result) {
          if (onRefresh != null) onRefresh!(result != null && result);
        });
        break;
      case 'faq':
        Get.to(() => SetupFaqScreen())!.then((result) {
          if (onRefresh != null) onRefresh!(result != null && result);
        });
        break;
      // case 'terms':
      //   Get.to(() => SignUpTermsScreen())!.then((result) {
      //     if (onRefresh != null) onRefresh!(result != null && result);
      //   });
        break;
    }
  }

  withdrawal(code) {

  }

  logOut(code) {
    LOG('---> logout ${AppData.userInfo.loginType} / ${AppData.userInfo.loginId}');
    // switch (AppData.loginType) {
    //   case 'google':
    //     await signOutWithGoogle();
    //     break;
    //   case 'email':
    //     await signOutWithEmail();
    //     break;
    //   // case 'facebook':
    //   //   await signOutWithFacebook();
    //   //   break;
    //   // case 'kakao':
    //   //   await signOutWithKakao();
    //   //   break;
    //   // case 'naver':
    //   //   await signOutWithNaver();
    //   //   break;
    // }

    // AppData.initLoginData();
    // writeLocalInfo();
    // AppData.loginMode = 0;
    // AppData.isLogoutUser = true;
    AppData.appViewModel.signOut();
  }

  late final List<ListItemEx> setupList = [
    // ListItemEx("프로필 편집", code: 0, callback: onSelect),
    ListItemEx('info', "Profile edit".tr, callback: onSelect),
    ListItemEx('contact', "Contact edit".tr, callback: onSelect),
    // ListItemEx('sns', "SNS link edit".tr, callback: onSelect),
    // ListItemEx('creator', 'Creator mode', callback: onSelect),
    ListItemEx('push', "Notification setting".tr, callback: onSelect),
    ListItemEx('playAuto', "Content setting".tr, callback: onSelect),
    ListItemEx('block', "Declare/Report list".tr, callback: onSelect),
    ListItemEx('promotion', "Promotion list".tr, callback: onSelect),
    // ListItemEx('shop', CheckStore() ? "My Shop 설정" : "My Shop 등록", callback: onSelect),
    ListItemEx('notice', "Notice".tr, callback: onSelect),
    ListItemEx('faq', "FAQ".tr, callback: onSelect),
    ListItemEx('service', "Contact us".tr, callback: onSelect),
    // ListItemEx('macro', "메크로 관리", callback: onSelect),
    ListItemEx('terms', "Terms of use".tr, callback: onSelect),
    ListItemEx('logout', "Sign out".tr, titleEx: '[${AppData.userInfo.loginType.toUpperCase()}]', callback: logOut),
    ListItemEx('withdrawal', "Withdrawal".tr, callback: withdrawal),
    // ListItemEx('delete', "Member Secession"),
  ];
}