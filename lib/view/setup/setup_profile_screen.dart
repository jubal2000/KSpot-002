import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/etc_model.dart';
import 'package:kspot_002/models/user_model.dart';
import 'package:kspot_002/repository/user_repository.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/dropdown_widget.dart';

class SetupProfileScreen extends StatefulWidget {
  SetupProfileScreen({Key? key}) : super(key: key);

  @override
  SetupProfileState createState() => SetupProfileState();
}

enum textType {
  nickName,
  realName,
  email,
  refundBank,
  refundAcc,
  refundAuth,
}

class SetupProfileState extends State<SetupProfileScreen> {
  final api = Get.find<ApiService>();
  final userRepo = UserRepository();

  final _textController = List<TextEditingController>.generate(textType.values.length, (index) => TextEditingController());
  final _formKey        = GlobalKey<FormState>();
  final _minText    = 2;
  final _buttonHeight = 60.0;

  UserModel? editUserInfo;
  bool _isEdited = false;

  final _genderN = {'f': 'Female', 'm': 'Male', 'n': 'No select'};

  initData() {
    AppData.isMainActive = true;

    // copy user for edit..
    editUserInfo = UserModel.fromJson(AppData.userInfo.toJson());
    editUserInfo!.refundBank ??= BankData.empty;

    // set text..
    _textController[textType.nickName.index].text   = editUserInfo!.nickName;
    _textController[textType.realName.index].text       = editUserInfo!.realName;
    _textController[textType.refundBank.index].text = editUserInfo!.refundBank!.name;
    _textController[textType.refundAcc.index].text  = editUserInfo!.refundBank!.account;
    _textController[textType.refundAuth.index].text = editUserInfo!.refundBank!.author;
  }

  setUserData() async {
    if (editUserInfo == null) return false;
    showLoadingDialog(context, 'updating now...'.tr);
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

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _titleStyle   = ItemTitleNormalStyle(context);
    final _buttonStyle  = ItemButtonStyle(context);
    final _startYear    = DateTime.now().year - 12;
    final _genderList   = List.generate(_genderN.length, (index) => {'title': _genderN[_genderN.keys.elementAt(index)], 'key': _genderN.keys.elementAt(index)});
    final _yearList     = List.generate(100, (index) => {'title': '${_startYear - index}', 'key': '${_startYear - index}'});

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('PROFILE EDIT'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: 50,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_L, 0, UI_HORIZONTAL_SPACE_L, _isEdited ? _buttonHeight : 0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        SubTitle(context, 'NICKNAME'.tr),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: _textController[textType.nickName.index],
                          decoration: inputLabel(context, '', ''),
                          keyboardType: TextInputType.name,
                          maxLines: 1,
                          maxLength: NICKNAME_LENGTH,
                          style: _titleStyle,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter nickname'.tr;
                            if (value.length < _minText) return '${'Please check length'.tr}(${'min'.tr}: $_minText)';
                            if (value.length > NICKNAME_LENGTH) return '${'Please check length'.tr}(${'max'.tr}: $NICKNAME_LENGTH)';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              editUserInfo!.nickName = _textController[textType.nickName.index].text;
                              _isEdited = true;
                            });
                          },
                        ),
                        // SizedBox(height: 20),
                        // SubTitle(context, 'REAL NAME'.tr, height: 20),
                        // SubTitleSmall(context, 'Real name is never disclosed'.tr),
                        // SizedBox(height: 5),
                        // TextFormField(
                        //   controller: _textController[textType.realName.index],
                        //   decoration: inputLabel(context, '', ''),
                        //   keyboardType: TextInputType.name,
                        //   maxLines: 1,
                        //   maxLength: NICKNAME_LENGTH,
                        //   style: _titleStyle,
                        //   validator: (value) {
                        //     if (value != null && value.length > NICKNAME_LENGTH) return '${'Please check length'.tr}(${'max'.tr}: $NICKNAME_LENGTH)';
                        //     return null;
                        //   },
                        //   onChanged: (value) {
                        //     setState(() {
                        //       editUserInfo!.realName = _textController[textType.realName.index].text;
                        //       _isEdited = true;
                        //     });
                        //   },
                        // ),
                        SizedBox(height: 10),
                        DropDownMenuWidget(
                          _genderList,
                          title: 'GENDER(or PART)'.tr,
                          selectKey: editUserInfo!.gender,
                          onSelected: (key) {
                            setState(() {
                              editUserInfo!.gender = key;
                              _isEdited = true;
                            });
                          },
                        ),
                        SizedBox(height: 30),
                        DropDownMenuWidget(
                          _yearList,
                          title: 'BIRTH YEAR'.tr,
                          selectKey: editUserInfo!.birthYear.toString(),
                          onSelected: (key) {
                            setState(() {
                              editUserInfo!.birthYear = int.parse(key);
                              _isEdited = true;
                            });
                          },
                        ),
                        SizedBox(height: 30),
                        SubTitle(context, 'REFUND ACCOUNT INFO'.tr),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _textController[textType.refundBank.index],
                          decoration: inputLabel(context, 'Bank title'.tr, ''),
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          style: _titleStyle,
                          onChanged: (value) {
                            setState(() {
                              editUserInfo!.refundBank ??= BankData.empty;
                              editUserInfo!.refundBank!.name = value;
                              _isEdited = true;
                            });
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _textController[textType.refundAcc.index],
                          decoration: inputLabel(context, 'Bank account(number only)'.tr, ''),
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          style: _titleStyle,
                          onChanged: (value) {
                            setState(() {
                              editUserInfo!.refundBank ??= BankData.empty;
                              editUserInfo!.refundBank!.account = value;
                              _isEdited = true;
                            });
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _textController[textType.refundAuth.index],
                          decoration: inputLabel(context, 'Bank Account holder name'.tr, ''),
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          style: _titleStyle,
                          onChanged: (value) {
                            setState(() {
                              editUserInfo!.refundBank ??= BankData.empty;
                              editUserInfo!.refundBank!.author = value;
                              _isEdited = true;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                      ]
                    )
                  )
                )
              ),
              if (_isEdited)
                Positioned(
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                    LOG('--> onTap : $_isEdited / ${AppData.isMainActive}');
                    if (!_isEdited || !AppData.isMainActive) return;
                    unFocusAll(context);
                    showAlertYesNoDialog(context, 'Profile Update'.tr,
                        'Do you want to save the modified profile?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
                      if (result == 1) {
                        AppData.isMainActive = false;
                        setUserData().then((result) {
                          setState(() {
                            if (result) {
                              _isEdited = false;
                            }
                            AppData.isMainActive = true;
                            Get.back(result: result);
                          });
                        });
                      }
                    });
                  },
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width,
                    height: _buttonHeight,
                      child: Center(
                        child: Text('UPDATE'.tr, style: _buttonStyle),
                      )
                    )
                  )
                )
            ]
          )
        ),
      )
    );
  }
}
