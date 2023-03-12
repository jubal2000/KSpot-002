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
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../view_model/setup_view_model.dart';
import '../../widget/dropdown_widget.dart';

class SetupProfileScreen extends StatelessWidget {
  final _viewModel = SetupViewModel();

  @override
  Widget build(BuildContext context) {
    _viewModel.init(context);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('PROFILE EDIT'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: 50,
        ),
        body: ChangeNotifierProvider.value(
          value: _viewModel,
          child: Consumer<SetupViewModel>(
            builder: (context, viewModel, _) {
              LOG('--> SetupViewModel redraw');
              return Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_L, 0, UI_HORIZONTAL_SPACE_L,
                          viewModel.isEdited ? viewModel.buttonHeight : 0),
                      child: SingleChildScrollView(
                        child: Form(
                          key: viewModel.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: UI_VERTICAL_SPACE),
                              SubTitle(context, 'NICKNAME'.tr),
                              SizedBox(height: 5),
                              viewModel.showTextInputField(viewModel.textController[SetupTextType.nickName.index], (value) {
                                viewModel.editUserInfo!.nickName = value;
                              }, validator: (value) {
                                if (value.length < viewModel.minText) return '${'Please check length'.tr}(${'min'.tr}: ${viewModel.minText})';
                                return null;
                              }, maxLength: NICKNAME_LENGTH),
                              SizedBox(height: 10),
                              viewModel.showDropListSelect('GENDER(or PART)'.tr, viewModel.genderList, viewModel.editUserInfo!.gender, (value) {
                                viewModel.editUserInfo!.gender = value;
                              }),
                              SizedBox(height: 30),
                              viewModel.showDropListSelect('BIRTH YEAR'.tr, viewModel.yearList, viewModel.editUserInfo!.birthYear.toString(), (value) {
                                viewModel.editUserInfo!.birthYear = int.parse(value);
                              }),
                              SizedBox(height: 30),
                              SubTitle(context, 'REFUND ACCOUNT INFO'.tr),
                              SizedBox(height: 10),
                              viewModel.showTextInputField(viewModel.textController[SetupTextType.refundBank.index], (value) {
                                viewModel.editUserInfo!.refundBank ??= BankData.empty();
                                viewModel.editUserInfo!.refundBank!.title = value;
                              }, label: 'Bank title'.tr),
                              SizedBox(height: 15),
                              viewModel.showTextInputField(viewModel.textController[SetupTextType.refundAcc.index], (value) {
                                viewModel.editUserInfo!.refundBank ??= BankData.empty();
                                viewModel.editUserInfo!.refundBank!.account = value;
                              }, label: 'Bank account(number only)'.tr),
                              SizedBox(height: 15),
                              viewModel.showTextInputField(viewModel.textController[SetupTextType.refundAuth.index], (value) {
                                viewModel.editUserInfo!.refundBank ??= BankData.empty();
                                viewModel.editUserInfo!.refundBank!.author = value;
                              }, label: 'Bank Account holder name'.tr),
                              SizedBox(height: 20),
                            ]
                          )
                      )
                    )
                  ),
                  if (viewModel.isEdited)
                    Positioned(
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          LOG('--> onTap : ${AppData.isMainActive}');
                          viewModel.updateProfile((result) {
                            Get.back(result: result);
                          });
                        },
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          width: MediaQuery.of(context).size.width,
                          height: viewModel.buttonHeight,
                          child: Center(
                            child: Text('UPDATE'.tr, style: ItemTitleLargeStyle(context)),
                          )
                        )
                      )
                    )
                  ]
                )
              );
            }
          )
        ),
      )
    );
  }
}
