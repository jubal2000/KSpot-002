import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';
import '../widget/verify_phone_widget.dart';

class SignUpViewModel extends ChangeNotifier {
  var stepIndex = 0;
  var isShowOnly = false;
  var isChecked = [false, false];

  BuildContext? viewContext;
  Future<String>? _termInit0;
  Future<String>? _termInit1;

  Future<String> loadTerms() async {
    return await rootBundle.loadString('assets/html/terms_0.html');
  }

  Future<String> loadCondition() async {
    return await rootBundle.loadString('assets/html/terms_1.html');
  }

  setViewContext(context) {
    viewContext = context;
  }

  showAgreeStep() {
    var textStyle = Theme.of(viewContext!).hintColor;
    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 20),
        child: ListView(
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: Get.size.height - 210.6,
                  child: Column(
                    children: [
                      SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Terms of service'.tr,
                            style: DescTitleLargeStyle(viewContext!),
                          )
                      ),
                      SizedBox(height: 10),
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(viewContext!).canvasColor,
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: FutureBuilder(
                                      future: _termInit0,
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
                                          return showLoadingImageSize(Size(double.infinity, MediaQuery.of(context).size.height * 0.28));
                                        }
                                      }
                                  )
                              )
                          )
                      ),
                      if (!isShowOnly)...[
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Checkbox(
                                value: isChecked[0],
                                onChanged: (status) {
                                  isChecked[0] = status!;
                                }
                            ),
                            Text(
                              'I agree to the terms and conditions'.tr,
                              style: ItemTitleStyle(viewContext!),
                            )
                          ],
                        ),
                      ],
                      SizedBox(height: isShowOnly ? 30 : 10),
                      SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Terms of use'.tr,
                            style: DescTitleLargeStyle(viewContext!),
                          )
                      ),
                      SizedBox(height: 10),
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(viewContext!).canvasColor,
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: FutureBuilder(
                                      future: _termInit1,
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
                                          return showLoadingImageSize(Size(double.infinity, MediaQuery.of(context).size.height * 0.28));
                                        }
                                      }
                                  )
                              )
                          )
                      ),
                      if (!isShowOnly)...[
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Checkbox(
                                value: isChecked[1],
                                onChanged: (status) {
                                  isChecked[1] = status!;
                                }
                            ),
                            Text(
                              'I agree to the Privacy Policy'.tr,
                              style: ItemTitleStyle(viewContext!),
                            )
                          ],
                        ),
                      ]
                    ],
                  )
              ),
              if (!isShowOnly)...[
                GestureDetector(
                    onTap: () {
                      // // if (widget.isChecked[0] && widget.isChecked[1]) {
                      // Navigator.push(viewContext!, MaterialPageRoute(
                      //     builder: (context) => SignUpPhoneScreen()))
                      //     .then((value) {
                      //   Navigator.of(viewContext!).pop(value ?? false);
                      //   // var loginResult = await getStartUserInfo(AppData.loginID);
                      //   // if (loginResult['error'] == null) {
                      //   //   Navigator.of(context).pop(true);
                      //   // } else {
                      //   //   showAlertDialog(context, 'Sign in', 'Sign in failed', STR(loginResult['error']), 'OK');
                      //   // }
                      // });
                      // }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      color: Theme.of(viewContext!).primaryColor,
                      alignment: Alignment.center,
                      child: Text('Next'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(viewContext!).colorScheme.inversePrimary)),
                    )
                )
              ]
            ]
        )
    );
  }

  showPhoneStep() {
    _termInit0 = loadTerms();
    _termInit1 = loadCondition();
    return Container(
      child: Column(
        children: [
          Container(
            child: VerifyPhoneWidget(
              AppData.loginInfo.mobile,
              true,
              onCheckComplete: (userValue) async {
                Get.back;
              }
            )
          )
        ],
      )
    );
  }

  showInputStep() {
    return Container(

    );
  }
}