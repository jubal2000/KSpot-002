import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:kspot_002/view/profile/profile_tab_screen.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../view_model/user_view_model.dart';
import '../../widget/user_item_widget.dart';

// ignore: must_be_immutable
class ProfileTargetScreen extends StatefulWidget {
  ProfileTargetScreen(this.userInfo, {Key? key}) : super(key: key);

  UserModel userInfo;

  @override
  ProfileTargetState createState() => ProfileTargetState();
}

class ProfileTargetState extends State<ProfileTargetScreen> {
  final repo = UserRepository();
  final userVewModel = UserViewModel();
  var _followType = 0;

  onFollowButton() {
    if (!AppData.isMainActive || _followType == 2) return;
    AppData.isMainActive = false;
    var target = 'Target'.tr;
    showAlertYesNoDialog(context, 'Follow'.tr, 'Would you like to follow?'.tr, '$target: ${widget.userInfo.nickName}', 'Cancel'.tr, 'OK'.tr).then((result) async {
      if (result == 1) {
        var addItem = await repo.addFollowTarget(widget.userInfo.toJson());
        if (addItem != null) {
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
    _followType = CheckFollowUser(widget.userInfo.id);
    userVewModel.initUserModel(widget.userInfo);
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
              UserFollowWidget(widget.userInfo.toJson(), fontSize: 16),
              // Text(_followType == 3 || _followType == 2 ? 'Following' : 'Follow+',
              //     style: _followType == 3 || _followType == 2 ? _followTitle1 : _followTitle0),
            ]
          ),
          toolbarHeight: 50,
          titleSpacing: 0,
        ),
        body: MainMyTab(ProfileMainTab.profile, '', userVewModel),
        )
    );
  }
}
