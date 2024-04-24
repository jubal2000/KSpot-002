import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/event/event_screen.dart';
import 'package:kspot_002/view/story/story_screen.dart';
import 'package:kspot_002/view_model/signup_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../models/user_model.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/dropdown_widget.dart';
import '../../widget/helpers/helpers/widgets/align.dart';
import '../../widget/page_dot_widget.dart';
import '../../widget/verify_phone_widget.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);
  final _viewModel = SignUpViewModel();

  @override
  Widget build(BuildContext context) {
    return  ChangeNotifierProvider<SignUpViewModel>.value(
      value: _viewModel,
      child: Consumer<SignUpViewModel>(
        builder: (context, viewModel, _) {
          viewModel.init();
          return WillPopScope(
            onWillPop: () async {
              viewModel.moveBackStep();
              return false;
            },
            child: SafeArea(
              child:Scaffold(
                body: Container(
                  padding: EdgeInsets.only(top: UI_TOP_SPACE.w),
                  child: Column(
                    children: [
                      PageDotWidget(
                        viewModel.stepIndex,
                        viewModel.stepMax,
                        dotType: PageDotType.line,
                        height: 5.h,
                        activeColor: Theme.of(context).primaryColor,
                        width: Get.width - (UI_HORIZONTAL_SPACE.w * 2),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_L.w, UI_TOP_SPACE.w, UI_HORIZONTAL_SPACE_L.w, 0),
                          child: IndexedStack(
                            key: ValueKey(viewModel.stepIndex),
                            index: viewModel.stepIndex,
                            children: [
                              showAgreeStep(context, viewModel),
                              showPhoneStep(context, viewModel),
                              showInputStep(context, viewModel),
                            ],
                          ),
                        ),
                      ),
                      if (!viewModel.isShowOnly)...[
                        BottomCenterAlign(
                          child: GestureDetector(
                            onTap: () {
                              // if (!viewModel.isNextEnable) return; // disabled for Dev..
                              viewModel.moveNextStep();
                            },
                            child: Container(
                              width: double.infinity,
                              height: UI_BOTTOM_HEIGHT.w,
                              color: viewModel.isNextEnable ? Theme.of(context).primaryColor : Colors.black45,
                              alignment: Alignment.center,
                              child: Text('Next'.tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.inversePrimary)),
                            )
                          )
                        )
                      ]
                    ],
                  )
                )
              )
            )
          );
        }
      )
    );
  }

  showAgreeStep(context, viewModel) {
    var textStyle = Theme.of(context).hintColor;
    return LayoutBuilder(
      builder: (context, layout) {
        return Container(
        height: layout.maxHeight,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'Terms of service'.tr,
                style: DescTitleStyle(context),
              )
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: FutureBuilder(
                    future: loadTerms(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Html(
                            data: snapshot.data,
                            style: {
                              "p" : Style(color: textStyle),
                              "h2": Style(color: textStyle),
                              "h3": Style(color: textStyle),
                              "h4": Style(color: textStyle),
                            }
                        );
                      } else {
                        return Center(
                          child: showLoadingCircleSquare(50),
                        );
                      }
                    }
                  )
                )
              )
            ),
            if (!viewModel.isShowOnly)...[
              SizedBox(height: 3),
              Row(
                children: [
                  Checkbox(
                      value: viewModel.isChecked[0],
                      onChanged: (status) {
                        viewModel.setCheck(0, status ?? false);
                      }
                    ),
                    Text(
                      'I agree to the terms and conditions'.tr,
                      style: ItemTitleStyle(context),
                    )
                  ],
                ),
              ],
              SizedBox(height: viewModel.isShowOnly ? 30.w : 10.w),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Terms of use'.tr,
                  style: DescTitleStyle(context),
                )
              ),
              SizedBox(height: 10.w),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(12.sp)
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: FutureBuilder(
                      future: loadCondition(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return Html(
                            data: snapshot.data,
                            style: {
                              "p" : Style(color: textStyle),
                              "h2": Style(color: textStyle),
                              "h3": Style(color: textStyle),
                              "h4": Style(color: textStyle),
                            }
                          );
                        } else {
                          return Center(
                            child: showLoadingCircleSquare(50),
                          );
                        }
                      }
                    )
                  )
                )
              ),
              if (!viewModel.isShowOnly)...[
                SizedBox(height: 3),
                Row(
                  children: [
                    Checkbox(
                      value: viewModel.isChecked[1],
                      onChanged: (status) {
                        viewModel.setCheck(1, status ?? false);
                      }
                    ),
                    Text(
                      'I agree to the Privacy Policy'.tr,
                      style: ItemTitleStyle(context),
                    )
                  ],
                ),
              ]
            ],
          )
        );
      }
    );
  }

  showPhoneStep(context, viewModel) {
    AppData.isSignUpMode = true;
    return LayoutBuilder(
      builder: (context, layout) {
        return Container(
          height: layout.maxHeight,
          padding: EdgeInsets.only(top: UI_TOP_TEXT_SPACE.w),
          child: ListView(
            children: [
              Text(
                'This is the authentication step'.tr,
                style: AppBarTitleStyle(context),
              ),
              SizedBox(height: UI_ITEM_SPACE_L.w),
              Text(
                'Phone number verification'.tr,
                style: DescTitleStyle(context),
              ),
              Container(
                padding: EdgeInsets.only(top: UI_ITEM_SPACE.w),
                child: VerifyPhoneWidget(
                  '010',
                  onCheckComplete: (intl, number, userValue) async {
                    LOG('--> userValue : $userValue');
                    if (userValue != null && userValue.user != null) {
                      LOG('--> userValue.user!.uid : ${userValue.user!.uid}');
                      AppData.loginInfo.loginId = userValue.user!.uid;
                      AppData.loginInfo.loginType = 'phone';
                      AppData.loginInfo.mobileVerifyTime = CURRENT_SERVER_TIME().toString();
                      viewModel.isMobileVerified = true;
                      viewModel.notifyListeners();
                    }
                  }
                )
              )
            ],
          )
        );
      }
    );
  }

  showInputStep(context, viewModel) {
    final lastYear   = DateTime.now().year - 14;
    final genderN    = {'f': 'Female', 'm': 'Male', 'n': 'No select'};
    final genderList = List.generate(genderN.length, (index) => {'title': genderN[genderN.keys.elementAt(index)], 'key': genderN.keys.elementAt(index)});
    final yearList   = List.generate(100, (index) => {'title': '${lastYear - index}', 'key': '${lastYear - index}'});
    if (AppData.loginInfo.gender.isEmpty) AppData.loginInfo.gender = 'n';
    if (AppData.loginInfo.birthYear == 0) AppData.loginInfo.birthYear = lastYear;

    final controller = viewModel.textEditController[TextInputId.nickname.index];

    return LayoutBuilder(
      builder: (context, layout) {
        return Container(
          height: layout.maxHeight,
          padding: EdgeInsets.only(top: UI_TOP_TEXT_SPACE.w),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: ListView(
              children: [
                Text(
                  'This is the last step'.tr,
                  style: AppBarTitleStyle(context),
                ),
                SizedBox(height: UI_ITEM_SPACE_L.w),
                Text(
                  'NICKNAME'.tr,
                  style: DescTitleStyle(context),
                ),
                SizedBox(height: UI_ITEM_SPACE.w),
                TextFormField(
                  controller: controller,
                  decoration: inputLabel(context, '', ''),
                  keyboardType: TextInputType.name,
                  maxLines: 1,
                  maxLength: NICKNAME_LENGTH,
                  validator: (value) {
                    if (value == null || value.length < 2) return 'Please enter nickname'.tr;
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter(
                      RegExp('[a-z A-Z ㄱ-ㅎ|가-힣|·|：]'),
                      allow: true,
                    )
                  ],
                  onChanged: (value) {
                    AppData.loginInfo.nickName = value;
                    viewModel.setSignUpDone(AppData.loginInfo.nickName.length > 1);
                  },
                ),
                SizedBox(height: UI_ITEM_SPACE_L.w),
                Text(
                  'GENDER(or PART)'.tr,
                  style: DescTitleStyle(context),
                ),
                SizedBox(height: UI_ITEM_SPACE.w),
                DropDownMenuWidget(
                  genderList,
                  selectKey: AppData.loginInfo.gender,
                  onSelected: (key) {
                    LOG('--> gender : $key');
                    AppData.loginInfo.gender = key;
                  },
                ),
                SizedBox(height: UI_ITEM_SPACE_L.w),
                Text(
                  'BIRTH YEAR'.tr,
                  style: DescTitleStyle(context),
                ),
                SizedBox(height: UI_ITEM_SPACE.w),
                DropDownMenuWidget(
                  yearList,
                  selectKey: AppData.loginInfo.birthYear.toString(),
                  onSelected: (key) {
                    LOG('--> gender : $key');
                    try {
                      AppData.loginInfo.birthYear = int.parse(key);
                    } catch (e) {
                      LOG('--> gender error: $e');
                    }
                  },
                ),
              ],
            )
          )
        );
      }
    );
  }
}
