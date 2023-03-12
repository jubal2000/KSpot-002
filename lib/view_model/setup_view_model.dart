
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/widget/rounded_button.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/etc_model.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../view/setup/setup_contact_screen.dart';
import '../view/setup/setup_profile_screen.dart';
import '../widget/dropdown_widget.dart';
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

  late final genderList   = List.generate(genderN.length, (index) => {'title': genderN[genderN.keys.elementAt(index)], 'key': genderN.keys.elementAt(index)});
  late final yearList     = List.generate(100, (index) => {'title': '${startYear - index}', 'key': '${startYear - index}'});
  var isEditMode        = List.generate(SetupTextType.values.length, (index) => false);

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

  showTextInputField(TextEditingController controller, Function(String)? onChanged, {
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
      decoration: inputLabel(context!, label ?? '', ''),
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      style: ItemTitleNormalStyle(context!),
      validator: validator,
      onChanged: (value) {
        if (onChanged != null) onChanged(controller.text);
        isEdited = true;
        notifyListeners();
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
      String btnTitle   = 'CHANGE',
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
            RoundedButton.active(
            btnTitle.tr,
            fullWidth: false,
            minWidth: UI_BUTTON_WIDTH,
            radius: 8,
            height: 40,
            textColor: Theme.of(context!).colorScheme.inversePrimary,
            backgroundColor: Theme.of(context!).primaryColor,
            onPressed: () {
              isEditMode[type.index] = !isEditMode[type.index];
              if (onPressed != null) onPressed();
              notifyListeners();
            }),
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
    return VerifyPhoneWidget(
      editUserInfo!.mobile,
      phoneIntl: editUserInfo!.mobileIntl,
      isSignIn: false,
      isValidated: true,
      onCheckComplete: (intl, number, _) {
        isEditMode[SetupTextType.mobile.index] = false;
        ShowToast('Mobile change completed'.tr);
        refreshData();
        notifyListeners();
      }
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
      // case 'contact':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupContactScreen()));
      //   break;
      // case 'sns':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupSNSScreen())).then((result) {
      //     AppData.isUpdateProfile = true;
      //   });
      //   break;
      // case 'creator':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupCreatorScreen())).then((result) {
      //     AppData.isUpdateProfile = true;
      //   });
      //   break;
      // case 'push':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupPushScreen(
      //     onChanged: (jsonData) {
      //       AppData.userInfo['optionPush'] = {};
      //       for (var item in jsonData.entries) {
      //         AppData.userInfo['optionPush'][item.key] = item.value;
      //       }
      //     },
      //   )));
      //   break;
      // case 'playAuto':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupPlayScreen()));
      //   break;
      // case 'block':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupBlockScreen()));
      //   break;
      // case 'shop':
      //   if (!AppData.isStoreInfoReady) {
      //     var result = await api.getStoreInfoFromUserId(AppData.USER_ID);
      //     AppData.storeInfo = result;
      //     AppData.isStoreInfoReady = true;
      //   }
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupMyShopScreen()));
      //   break;
      // case 'service':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupServiceScreen()));
      //   break;
      // case 'promotion':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(PromotionListScreen()));
      //   break;
      // case 'notice':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupNoticeScreen()));
      //   break;
      // case 'faq':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupFaqScreen()));
      //   break;
      // case 'terms':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SignUpTermsScreen(isShowOnly: true)));
      //   break;
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
    ListItemEx('sns', "SNS link edit".tr, callback: onSelect),
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