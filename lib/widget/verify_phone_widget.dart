import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:get/get.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../services/api_service.dart';
import '../utils/address_utils.dart';
import '../utils/local_utils.dart';
import '../utils/utils.dart';

enum SignUpPhoneText {
  phone,
  phoneCheck,
}

class VerifyPhoneWidget extends StatefulWidget {
  VerifyPhoneWidget(this.phoneNumber, this.isSignIn, {Key? key, this.onCheckComplete}) : super(key: key);

  String phoneNumber;
  bool isSignIn;
  Function(UserCredential?)? onCheckComplete;

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhoneWidget> {
  final api = ApiService();
  final _textController   = List<TextEditingController>.generate(SignUpPhoneText.values.length, (index) => TextEditingController());
  final _verifyFocusNode  = FocusScopeNode();
  final _phoneFormKey     = GlobalKey<FormState>();

  String _phone       = '';
  String _phoneIntl   = '';
  String _phoneOrg    = '';
  String _phoneCode   = '';
  String _verificationId = '';
  int?   _resendToken;

  bool _phoneCheck      = false;
  bool _phoneCheck2     = false;
  bool _phoneValidated  = AppData.userInfo.mobileVerified;
  bool _phoneCodeReady  = false;
  bool _hasError = false;

  String phoneVerify  = '';

  refreshData() {
    _phone = widget.phoneNumber;
    _phoneCheck = widget.isSignIn;
    _textController[SignUpPhoneText.phone.index].text = widget.phoneNumber;
    _textController[SignUpPhoneText.phoneCheck.index].text = '';
  }

  sendPhoneVerifyError(e) {
    setState(() {
      var error = e.toString();
      if (error == 'too-many-requests') {
        ShowErrorToast('Too many requests'.tr);
      } else if (error.contains('phone-already-in-use')) {
        showAlertDialog(context, 'Phone verify'.tr, 'Phone verify error'.tr, 'Phone number already in use'.tr, 'OK'.tr);
      } else if (error.contains('invalid-phone-number')) {
        showAlertDialog(context, 'Phone verify'.tr, 'Phone verify error'.tr, 'The format of the phone number provided is incorrect'.tr, 'OK'.tr);
      } else if (error.contains('invalid-verification-code')) {
        showAlertDialog(context, 'Phone verify'.tr, 'Phone verify error'.tr,
            'Auth credential is invalid'.tr, 'OK'.tr).then((_) {
          setState(() {
            _phoneCode = '';
            _textController[SignUpPhoneText.phoneCheck.index].text = '';
          });
        });
      } else {
        showAlertDialog(context, 'Phone verify'.tr, 'Phone verify error'.tr, error, 'OK'.tr);
      }
    });
  }

  initData() {
    _phoneCheck  = false;
    _phoneCheck2 = false;
    phoneVerify  = '';
    AppData.loginInfo.mobile = _phone;
    AppData.loginInfo.mobileIntl = _phoneIntl;
  }

  writeLocalData() {
    AppData.localInfo['phone'     ] = AppData.loginInfo.mobile;
    AppData.localInfo['phoneIntl' ] = AppData.loginInfo.mobileIntl;
    AppData.localInfo['loginType' ] = AppData.loginInfo.loginType;
    writeLocalInfo();
  }

  @override
  void initState() {
    refreshData();
    if (CountryCodes[AppData.currentCountry] != null) {
      var countryList = countries
          .where((country) => CountryCodes[AppData.currentCountry]!.contains(country.code))
          .toList();
      _phoneIntl = '+${countryList.first.dialCode}';
    } else {
      AppData.currentCountry = 'Korea South';
      _phoneIntl = '+82';
    }
    LOG('--> countryList : ${AppData.currentCountry} -> $_phoneIntl');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _titleStyle = ItemTitleNormalStyle(context);
    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: 70,
                child: Form(
                  key: _phoneFormKey,
                  child: IntlPhoneField(
                    controller: _textController[SignUpPhoneText.phone.index],
                    decoration: inputLabel(context, '', ''),
                    initialCountryCode: CountryCodes[AppData.currentCountry] ?? 'KR',
                    style: _titleStyle,
                    onChanged: (value) {
                      setState(() {
                        _phone        = value.number;
                        _phoneIntl    = value.completeNumber.replaceAll(value.number, '');
                        _phoneCheck   = true;
                        // _phoneCheck   = _phoneOrg != _phone;
                        _phoneCheck2  = false;
                        _resendToken  = null;
                        LOG('--> _phone completeNumber : $_phone / $_phoneIntl / ${CountryCodes[AppData.currentCountry]}');
                      });
                    },
                  )
                )
              )
            ),
            if (_phoneCheck)...[
              SizedBox(width: 20),
              RoundRectButtonEx(
                context,
                'SEND',
                height: 44,
                isEnabled: !_phoneCheck2,
                onPressed: () {
                  if (!_phoneFormKey.currentState!.validate()) return;
                  var sendNumber = '$_phoneIntl$_phone';
                  LOG('--> verifyPhoneNumber : $sendNumber');
                  _phoneCodeReady = true;
                  showLoadingDialog(context, 'Waiting send verification code...');
                  try {
                    FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: sendNumber,
                      forceResendingToken: _resendToken,
                      verificationCompleted: (PhoneAuthCredential credential) {
                        LOG('--> onVerificationCompleted: $credential');
                      },
                      verificationFailed: (FirebaseAuthException e) {
                        LOG('--> verificationFailed: ${e.toString()}');
                        hideLoadingDialog();
                        if (e.code.contains('invalid-phone-number')) {
                          showAlertDialog(context, 'Phone verify'.tr, 'Verify code send failed'.tr, 'Phone number is not valid'.tr, 'OK'.tr, true);
                        } else {
                          showAlertDialog(context, 'Phone verify'.tr, 'Verify code send failed'.tr, e.code, 'OK'.tr, true);
                        }
                        _phoneCodeReady = false;
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        setState(() {
                          LOG('--> codeSent: $verificationId / $resendToken');
                          hideLoadingDialog();
                          ShowToast('Verify code sent'.tr);
                          _phoneCheck2 = true;
                          _phoneCodeReady = false;
                          _textController[SignUpPhoneText.phoneCheck.index].text = '';
                          _verificationId = verificationId;
                          _resendToken = resendToken ?? -1;
                          // FocusScope.of(context).requestFocus(_verifyFocusNode);
                          FocusScope.of(context).nextFocus();
                        });
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {
                        // if (_phoneCodeReady) {
                        //   showAlertDialog(context, 'Phone verify'.tr, 'Verify code send failed'.tr, 'Time out'.tr, 'OK'.tr);
                        // }
                      },
                    );
                  } on FirebaseAuthException catch  (e) {
                    LOG('--> Failed with error code: ${e.code} / ${e.message}');
                  }
                }
              ),
            ],
            if (!_phoneCheck)...[
              SizedBox(width: 10),
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(
                    _phoneValidated ? Icons.check : Icons.close,
                    size: 30,
                    color: _phoneValidated ? Colors.green : Colors.grey,
                  )
              )
            ]
          ]
        ),
        if (_phoneCheck2)...[
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PinCodeTextField(
                  appContext: context,
                  // focusNode: _verifyFocusNode,
                  length: 6,
                  obscureText: false,
                  showCursor: false,
                  backgroundColor: Colors.transparent,
                  animationType: AnimationType.slide,
                  animationDuration: Duration(milliseconds: 200),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 40,
                    fieldWidth: 35,
                    borderWidth: 2,
                    // fieldOuterPadding: EdgeInsets.only(right: 2),
                    activeColor: Theme.of(context).hintColor.withOpacity(0.25),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context).hintColor.withOpacity(0.25)
                  ),
                  onChanged: (value) {
                    _phoneCode = value;
                  },
                )
              ),
              SizedBox(width: 20),
              RoundRectButtonEx(
                context,
                'CHECK',
                onPressed: () {
                  AppData.loginInfo.loginId = 'phone';
                  try {
                    var credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: _phoneCode);
                    if (widget.isSignIn) {
                      FirebaseAuth.instance.signInWithCredential(credential).then((value) {
                        LOG('--> signInWithCredential result : ${credential.token} / $value / $_phoneCode}');
                        setState(() {
                          initData();
                          writeLocalData();
                          _phoneValidated = true;
                          if (widget.onCheckComplete != null) widget.onCheckComplete!(value);
                        });
                      }).onError((error, stackTrace) {
                        LOG('--> FirebaseAuthException onError : $error');
                        _hasError = true;
                        sendPhoneVerifyError(error);
                      });
                    } else {
                      FirebaseAuth.instance.currentUser!.updatePhoneNumber(credential).then((value) {
                        LOG('--> updatePhoneNumber done : $_phone');
                        AppData.userInfo.mobile = _phone;
                        AppData.userInfo.mobileIntl = _phoneIntl;
                        AppData.userInfo.mobileVerified = true;
                        AppData.userInfo.mobileVerifyTime = CURRENT_SERVER_TIME();
                        // api.setUserInfo(AppData.userInfo).then((result) {
                        //   setState(() {
                        //     initData();
                        //     writeLocalData();
                        //     _phoneValidated = true;
                        //     AppData.userInfo = FROM_SERVER_DATA(AppData.userInfo);
                        //     if (widget.onCheckComplete != null) widget.onCheckComplete!(null);
                        //   });
                        // });
                      }).onError((error, stackTrace) {
                        LOG('--> updatePhoneNumber error : $error');
                        _hasError = true;
                        sendPhoneVerifyError(error);
                      });
                    }
                  } on FirebaseException catch (e) {
                    LOG('--> updatePhoneNumber catch error : $e');
                    sendPhoneVerifyError(e);
                  }
                }
              )
            ]
          ),
        ],
      ]
    );
  }
}
