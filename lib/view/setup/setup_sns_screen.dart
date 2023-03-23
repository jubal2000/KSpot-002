import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get/get.dart';
import 'package:kspot_002/repository/user_repository.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/edit/edit_list_widget.dart';


class SetupSNSScreen extends StatefulWidget {
  SetupSNSScreen({Key? key}) : super(key: key);

  @override
  SetupSNSState createState() => SetupSNSState();
}

enum textType {
  etc,
}

final List<JSON> snsLinkInfo = [
  {'id': 'youtube', 'title': 'YOUTUBE', 'icon':'assets/ui/sns_logo_00.png', 'desc': ''},
  {'id': 'instagram', 'title': 'INSTAGRAM', 'icon':'assets/ui/sns_logo_01.png', 'desc': ''},
  {'id': 'facebook', 'title': 'FACEBOOK', 'icon':'assets/ui/sns_logo_02.png', 'desc': ''},
  {'id': 'twitter', 'title': 'TWITTER', 'icon':'assets/ui/sns_logo_03.png', 'desc': ''},
];

class SetupSNSState extends State<SetupSNSScreen> {
  final userRepo = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _buttonHeight = 60.0;
  JSON addInfo = {};
  JSON _snsLinkData = {};

  initData() {
    AppData.isMainActive = true;
    _snsLinkData = AppData.userInfo.snsDataMap;
  }

  createUploadData() {
    addInfo = {};
    addInfo['snsData'   ] = _snsLinkData;
    addInfo['updateTime'] = CURRENT_SERVER_TIME();
  }

  refreshLinkInfo() {
    for (var item in snsLinkInfo) {
      item['disabled'] = _snsLinkData.containsKey(item['id']) ? '1' : '';
    }
  }

  setUserInfoData() {
    AppData.userInfo.setSnsData(_snsLinkData);
    AppData.userInfo.updateTime = FROM_SERVER_DATA(addInfo['updateTime']);
  }

  updateUserData() {
    unFocusAll(context);
    AppData.isMainActive = false;
    showLoadingDialog(context, 'SNS updating..');
    createUploadData();
    setUserInfoData();
    userRepo.setUserInfo(AppData.userInfo).then((result) {
      hideLoadingDialog();
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('SNS link edit'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditListWidget(_snsLinkData, EditListType.sns,
                          (type, data) {
                            // add SNS..
                            refreshLinkInfo();
                            showJsonButtonSelectDialog(context, 'SNS Link add'.tr, snsLinkInfo).then((key) {
                              if (key.isNotEmpty) {
                                for (var item in snsLinkInfo) {
                                  if (item['id'] == key) {
                                    _snsLinkData[key] = {'id': key, 'icon':item['icon'], 'link': ''};
                                    showTextInputDialog(context, 'SNS Link add'.tr, '${item['title']}', _snsLinkData[key]['link'], 1, null).then((result2) {
                                      setState(() {
                                        if (result2.isNotEmpty) {
                                          _snsLinkData[key]['link'] = result2;
                                          updateUserData();
                                        } else {
                                          _snsLinkData.remove(key);
                                        }
                                        LOG('--> _snsLinkData result [$key] : $_snsLinkData');
                                      });
                                    });
                                    break;
                                  }
                                }
                              }
                            });
                          },
                          (type, key, action) {
                            if (action == 1) {
                              // delete SNS..
                              showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, 'Alert) Recovery is not possible'.tr, 'Cancel'.tr, 'OK'.tr).then((result2) {
                                if (result2 == 1) {
                                  setState(() {
                                    _snsLinkData.remove(key);
                                    refreshLinkInfo();
                                    updateUserData();
                                  });
                                }
                              });
                            } else {
                              // edit SNS..
                              for (var item in snsLinkInfo) {
                                if (item['id'] == key) {
                                  showTextInputDialog(context, 'Edit'.tr, '${item['title']} Link', _snsLinkData[key]['link'], 1, null).then((result2) {
                                    setState(() {
                                      if (result2.isNotEmpty) {
                                        _snsLinkData[key]['link'] = result2;
                                        updateUserData();
                                      }
                                    });
                                  });
                                  break;
                                }
                              }
                            }
                          },
                        ),
                        SizedBox(height: 30),
                      ],
                    )
                  )
                )
              ),
            ]
          )
        ),
      )
    );
  }
}
