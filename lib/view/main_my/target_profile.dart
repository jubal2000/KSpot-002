import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kspot001/app_data.dart';
import 'package:kspot001/main_my/main_myprofile.dart';
import 'package:get/get.dart';

import '../service/api_service.dart';
import '../utils/dialog_utils.dart';
import '../utils/theme_manager.dart';
import '../utils/utils.dart';
import '../widgets/follow_widget.dart';

// ignore: must_be_immutable
class TargetProfileScreen extends StatefulWidget {
  TargetProfileScreen(this.userInfo, {Key? key}) : super(key: key);

  JSON userInfo;

  @override
  TargetProfileState createState() => TargetProfileState();
}

class TargetProfileState extends State<TargetProfileScreen> {
  final api = Get.find<ApiService>();
  var _followType = 0;

  onFollowButton() {
    if (!AppData.isMainActive || _followType == 2) return;
    AppData.isMainActive = false;
    var target = 'Target'.tr;
    showAlertYesNoDialog(context, 'Follow'.tr, 'Would you like to follow?'.tr, '$target: ${widget.userInfo['nickName']}', 'Cancel'.tr, 'OK'.tr).then((result) async {
      if (result == 1) {
        var addItem = await api.addFollowTarget(widget.userInfo);
        if (addItem.isNotEmpty) {
          setState(() {
            _followType = 2;
          });
          AppData.isMainActive = true;
        }
      } else {
        AppData.isMainActive = true;
      }
    });
  }

  @override
  void initState() {
    _followType = CheckFollowUser(widget.userInfo['id']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _followTitle0 = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800);
    final _followTitle1 = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.inverseSurface);
    return SafeArea(
      top: false,
        child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text('PROFILE'.tr, style: AppBarTitleStyle(context)),
              SizedBox(width: 10),
              showVerticalDivider(Size(5, 12)),
              SizedBox(width: 10),
              UserFollowWidget(widget.userInfo, fontSize: 16),
              // Text(_followType == 3 || _followType == 2 ? 'Following' : 'Follow+',
              //     style: _followType == 3 || _followType == 2 ? _followTitle1 : _followTitle0),
            ]
          ),
          toolbarHeight: 50,
          titleSpacing: 0,
        ),
        body: MainMyTab(ProfilMainTab.profile, '', widget.userInfo),
        )
    );
  }
}

// ignore: must_be_immutable
class TargetGoodsScreen extends StatelessWidget {
  TargetGoodsScreen(this.userInfo, {Key? key}) : super(key: key);

  JSON userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        primary: false,
        titleSpacing: 0,
        elevation: 1,
        title: Text('GOODS LIST'.tr, style: AppBarTitleStyle(context)),
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey,
      ),
      body: MyProfileTab(ProfileContentTab.goods, '', userInfo, isSelectable: true),
    );
  }
}