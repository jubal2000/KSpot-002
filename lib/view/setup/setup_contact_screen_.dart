import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/services/firebase_service.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/user_model.dart';
import '../../repository/user_repository.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/rounded_button.dart';
import '../../widget/verify_phone_widget.dart';

class SetupContactScreen extends StatefulWidget {
  SetupContactScreen({Key? key}) : super(key: key);

  @override
  SetupContactState createState() => SetupContactState();
}

enum textType {
  email,
  mobile,
  mobileCheck,
}

class SetupContactState extends State<SetupContactScreen> {
  final api = Get.find<ApiService>();
  final fire = Get.find<FirebaseService>();
  final userRepo = UserRepository();
  final _textController = List<TextEditingController>.generate(textType.values.length, (index) => TextEditingController());
  final _phoneFormKey   = GlobalKey<FormState>();
  final _emailFormKey   = GlobalKey<FormState>();
  final _buttonHeight = 60.0;

  var   mobileValidate = false;
  var   mobileVerificationId = '';
  var   mobileNew = '';
  int?  mobileToken;
  var   emailCheck    = false;
  var   emailCheck2   = false;
  var   emailValidated = false;

  var   mobileValidated = false;
  var   isEdited = false;

  UserModel? editUserInfo;

  initData() {
    AppData.isMainActive = true;
    editUserInfo = UserModel.fromJson(AppData.userInfo.toJson());

    mobileValidate = editUserInfo!.mobileVerifyTime.isNotEmpty;
    emailValidated = editUserInfo!.emailVerifyTime.isNotEmpty;

    // _email = 'jubal2000@gmail.co';
    // _email = 'jubal2000@hanmail.ne';
    emailCheck  = editUserInfo!.email.isNotEmpty && editUserInfo!.emailVerifyTime.isNotEmpty;

    // set text..
    _textController[textType.email.index].text  = editUserInfo!.email;
    _textController[textType.mobile.index].text = editUserInfo!.mobile;
  }

  sendEmailVerify() async {
    LOG('--> sendEmailVerify');
    var isError = false;
    var user = fire.fireAuth!.currentUser;
    if (user != null) {
      try {
        await user.updateEmail(editUserInfo!.email);
        LOG('--> sendEmailVerification : ${editUserInfo!.email}');
        var codeSettings = ActionCodeSettings(
          url: "https://kspot002.page.link/email_update",
          handleCodeInApp: false,
        );
        user.sendEmailVerification(codeSettings).onError((error, stackTrace) {
          LOG('--> sendEmailVerification onError : ${error.toString()}');
          sendEmailVerifyError(error);
        }).whenComplete(() {
          LOG('--> sendEmailVerification success : $isError');
          if (!isError) {
            setState(() {
              ShowToast('Verification link has been sent'.tr);
              emailCheck2 = true;
            });
          }
        });
      } catch (e) {
        LOG('--> sendEmailVerification error : $e');
        sendEmailVerifyError(e);
      }
    } else {
      startReLogin();
    }
  }

  sendEmailVerifyError(e) {
    var error = e.toString();
    if (error == 'too-many-requests') {
      ShowErrorToast('Too many requests'.tr);
    } else if (error.contains('requires-recent-login') || error.contains('user-token-expired')) {
      startReLogin();
    } else if (error.contains('email-already-in-use')) {
      showAlertDialog(context, 'Email verify'.tr, 'Send email verify error'.tr, 'Email already in use'.tr, 'OK'.tr);
    } else {
      showAlertDialog(context, 'Email verify'.tr, 'Send email verify error'.tr, error, 'OK'.tr);
    }
  }

  startReLogin() async {
    LOG('--> startReLogin');
    showAlertYesNoDialog(
        context, 'Sign in'.tr, 'Re-login is required'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) async {
      if (result == 1) {
        // Navigator.of(context).push(SecondPageRoute(SignUpPhoneScreen(isReLogin: true))).then((result) {
        //   LOG('--> SignUpTermsScreen result : $result');
        //   if (result) {
        //     setState(() async {
        //       await sendEmailVerify();
        //     });
        //   }
        // });
      }
    });
  }

  @override
  void initState() {
    initData();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (AppData.isEmailVerifyDone) {
    //     AppData.isEmailVerifyDone = false;
    //     showAlertDialog(context, 'Email verify'.tr, 'Email verify done'.tr, _email, 'OK'.tr).then((_) {
    //       setState(() {
    //         _emailValidated = true;
    //       });
    //     });
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle   = ItemTitleNormalStyle(context);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Contact edit'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: 50,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
             child: Container(
                padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_L, 0, UI_HORIZONTAL_SPACE_L, isEdited ? _buttonHeight : 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // email //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                      SizedBox(height: 30),
                      SubTitle(context, 'Email'.tr),
                      SizedBox(height: 5),
                      if (!mobileValidated)...[
                        Text('Need email verify'.tr, style: ItemDescAlertStyle(context)),
                        SizedBox(height: 10),
                      ],
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Form(
                                key: _emailFormKey,
                                child: TextFormField(
                                  controller: _textController[textType.email.index],
                                  decoration: inputLabel(context, '', '', padding: EdgeInsets.all(14)),
                                  keyboardType: TextInputType.emailAddress,
                                  
                                  maxLines: 1,
                                  style: titleStyle,
                                  // enabled: !_emailCheck2,
                                  validator: (value) {
                                    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(value.toString());
                                    if (value.toString().isEmpty || !emailValid) return 'Please check email'.tr;
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      editUserInfo!.email = value;
                                      emailCheck  = _textController[textType.email.index].text.length > 1;
                                      emailCheck2 = false;
                                    });
                                  },
                                )
                              )
                            ),
                            if (emailCheck)...[
                              SizedBox(width: 10),
                              RoundedButton.active(
                                onPressed: () {
                                  if (!_emailFormKey.currentState!.validate()) return;
                                  unFocusAll(context);
                                  editUserInfo!.emailNew = _textController[textType.email.index].text;
                                  api.setUserInfoItem(editUserInfo!.toJson(), 'emailNew').then((result) async {
                                    LOG('--> setUserInfoItem result : $result');
                                    if (result) {
                                      sendEmailVerify();
                                    }
                                  });
                                },
                                'SEND'.tr,
                                fullWidth: false,
                                minWidth: 100,
                                radius: 8,
                                textColor: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.25),
                              ),
                            ],
                            if (!emailCheck)...[
                              SizedBox(width: 10),
                              Icon(
                                emailValidated ? Icons.check : Icons.close,
                                size: 30,
                                color: emailValidated ? Colors.green : Colors.grey,
                              )
                            ]
                          ]
                      ),
                      if (emailCheck2)...[
                        Padding(
                            padding: EdgeInsets.only(left: 10, top: 5),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Waiting for email validate'.tr, style: ItemDescAlertStyle(context)),
                                  Text('(Check your email or spam box)'.tr, style: ItemDescAlertSmallStyle(context)),
                                ]
                            )
                        )
                      ],
                      // phone //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                      SizedBox(height: 20),
                      SubTitle(context, 'Phone'.tr),
                      SizedBox(height: 5),
                      if (!mobileValidated)...[
                        Text('Need Mobile number verify'.tr, style: ItemDescAlertStyle(context)),
                        SizedBox(height: 10),
                      ],
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: VerifyPhoneWidget(
                          editUserInfo!.mobile,
                          phoneIntl: editUserInfo!.mobileIntl,
                          isSignIn: false,
                          isValidated: true,
                          onCheckComplete: (intl, number, _) {
                            // unFocusAll(context);
                            setState(() {
                              mobileValidated = true;
                              editUserInfo!.mobileVerifyTime = CURRENT_LOCAL_DATE();
                              AppData.userInfo = UserModel.fromJson(editUserInfo!.toJson());
                              userRepo.setMyUserInfo();
                              ShowToast('Phone change completed'.tr);
                            });
                          }
                        )
                      ),
                    SizedBox(height: 20),
                  ],
                )
              )
            ),
        ),
      )
    );
  }
}
