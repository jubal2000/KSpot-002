import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';

class SetupScreen extends StatefulWidget {
  SetupScreen({Key? key, this.moveTo}) : super (key : key);

  String? moveTo;

  @override
  State<StatefulWidget> createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> with AutomaticKeepAliveClientMixin<SetupScreen> {
  final api = Get.find<ApiService>();
  late final List<ListItemEx> _itemList = [
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

  onSelect(code) async {
    switch (code) {
      case 'info':
        // Get.to(() => SetupProfileScreen())!.then((result) {
        //   if (result == 'edited') {
        //   }
        // });
        break;
      // case 'contact':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupContactScreen()));
      //   break;
      // case 'sns':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupSNSScreen())).then((result) {
      //     setState(() {
      //       AppData.isUpdateProfile = true;
      //     });
      //   });
      //   break;
      // case 'creator':
      //   Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupCreatorScreen())).then((result) {
      //     setState(() {
      //       AppData.isUpdateProfile = true;
      //     });
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
    LOG('---> logout');
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
    ShowToast('Sign out done'.tr);
    Navigator.of(context).pop();

    Future.delayed(const Duration(milliseconds: 500), () {
      FirebaseAuth.instance.signOut();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (widget.moveTo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSelect(widget.moveTo ?? '');
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('APP SETTING'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: 50,
        ),
        body: Container(
          // height: MediaQuery.of(context).size.height,
            child: ListView.builder(
             itemCount: _itemList.length,
             itemBuilder: (BuildContext context, int index) {
               return _itemList[index];
             }
            )
          ),
        )
    );
  }
}