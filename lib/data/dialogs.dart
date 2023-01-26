
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:kspot_002/services/api_service.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';

import '../models/message_model.dart';
import '../services/local_service.dart';
import '../utils/address_utils.dart';
import '../widget/card_scroll_viewer.dart';
import '../widget/csc_picker/csc_picker.dart';
import '../widget/dropdown_widget.dart';
import '../widget/edit/edit_text_input_widget.dart';
import '../widget/image_scroll_viewer.dart';
import '../widget/main_list_item.dart';
import '../widget/vote_widget.dart';
import 'app_data.dart';
import 'common_colors.dart';
import '../utils/utils.dart';
import '../data/style.dart';

final dialogBgColor = NAVY.shade50;
BuildContext? dialogContext;

Future showAlertDialog(BuildContext context,
    String title,
    String message1,
    String message2,
    String btnStr,
    [bool isErrorMode = false]
    )
{
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          title: Text(title, style: dialogTitleTextStyle),
          titlePadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: dialogBgColor,
          content: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                alignment: Alignment.center,
                constraints: BoxConstraints(
                    minHeight: 100
                ),
                child: ListBody(
                    children: [
                      Text(message1, style: isErrorMode ? dialogDescTextErrorStyle : dialogDescTextStyle),
                      if (message2.isNotEmpty)...[
                        SizedBox(height: 10),
                        Text(message2, style: dialogDescTextExStyle),
                      ]
                    ]
                )
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(btnStr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future showAlertYesNoDialog(BuildContext context,
    String title,
    String message1,
    String message2,
    String btnNoStr,
    String btnYesStr)
{
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
          child: AlertDialog(
            title: Text(title, style: dialogTitleTextStyle),
            titlePadding: EdgeInsets.all(20),
            insetPadding: EdgeInsets.all(20),
            backgroundColor: dialogBgColor,
            content: SingleChildScrollView(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ListBody(
                      children: [
                        Text(message1, style: dialogDescTextStyle),
                        if (message2.isNotEmpty)...[
                          SizedBox(height: 10),
                          Text(message2, style: dialogDescTextExStyle),
                        ],
                      ]
                  )
              ),
            ),
            actions: [
              TextButton(
                child: Text(btnNoStr),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
              TextButton(
                child: Text(btnYesStr),
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
            ],
          )
      );
    },
  );
}

Future showAlertYesNoExDialog(BuildContext context,
    String title,
    String message1,
    String message2,
    String btn1Str,
    String btn2Str,
    String btn3Str)
{
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          title: Text(title, style: dialogTitleTextStyle),
          titlePadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(20),
          backgroundColor: dialogBgColor,
          content: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListBody(
                    children: [
                      Text(message1, style: dialogDescTextStyle),
                      if (message2.isNotEmpty)...[
                        SizedBox(height: 10),
                        Text(message2, style: dialogDescTextExStyle),
                      ],
                    ]
                )
            ),
          ),
          actions: [
            if (btn1Str.isNotEmpty)...[
              TextButton(
                child: Text(btn1Str),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
              showVerticalDivider(Size(20, 20)),
            ],
            if (btn2Str.isNotEmpty)
              TextButton(
                child: Text(btn2Str),
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
            if (btn3Str.isNotEmpty)
              TextButton(
                child: Text(btn3Str),
                onPressed: () {
                  Navigator.of(context).pop(2);
                },
              ),
          ],
        ),
      );
    },
  );
}

showImageCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.square,
    CropAspectRatioPreset.ratio3x2,
    CropAspectRatioPreset.original,
    CropAspectRatioPreset.ratio4x3,
    CropAspectRatioPreset.ratio16x9
  ];
  return await startImageCroper(imageFilePath, CropStyle.rectangle, preset, CropAspectRatioPreset.original, false);
}

startImageCroper(String imageFilePath, CropStyle cropStyle, List<CropAspectRatioPreset> preset, CropAspectRatioPreset initPreset, bool lockAspectRatio) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    cropStyle: cropStyle,
    sourcePath: imageFilePath,
    aspectRatioPresets: preset,
    maxWidth: 1024,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Image size edit'.tr,
          toolbarColor: Colors.purple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: initPreset,
          lockAspectRatio: lockAspectRatio),
      IOSUiSettings(
        title: 'Image size edit'.tr,
      ),
    ],
  );
  return croppedFile?.path;
}

Future showImageSlideDialog(BuildContext context, List<String> imageData, int startIndex, [bool isCanDownload = false]) async {
  // TextStyle _menuText   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);
  LOG('--> showImageSlideDialog : $imageData / $startIndex');

  _saveImage(String fileUrl) async {
    var response = await Dio().get(fileUrl, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "KSpot-download-${Uuid().v1()}-${DATETIME_FULL_STR(DateTime.now())}");
    LOG('--> _saveImage result : $result');
  }

  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: AlertDialog(
              title: SizedBox(height: 10),
              scrollable: true,
              insetPadding: EdgeInsets.all(15),
              contentPadding: EdgeInsets.zero,
              backgroundColor: DialogBackColor(context),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: ImageScrollViewer(
                  imageData,
                  startIndex: startIndex,
                  rowHeight: MediaQuery.of(context).size.width - 30,
                  imageFit: BoxFit.contain,
                  showArrow: true,
                  showPage: true,
                  autoScroll: false,
                ),
              ),
              actions: [
                if (isCanDownload)...[
                  TextButton(
                      onPressed: () async {
                        showLoadingDialog(context, 'image downloading...'.tr);
                        for (var item in imageData) {
                          await _saveImage(item);
                        }
                        Navigator.of(dialogContext!).pop();
                        ShowToast('Download complete'.tr);
                      },
                      child: Icon(Icons.download, size: 24)
                  )
                ],
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'.tr)
                )
              ]
          ),
        );
      }
  ) ?? '';
}
showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // lock touched close..
    builder: (BuildContext context) {
      dialogContext = context;
      LOG('--> show loading.. : $message');
      return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(message, style: dialogDescTextStyle, maxLines: 5, softWrap: true),
              ],
            ),
          )
      );
    },
  );
}

Future showCountryLogSelectDialog(BuildContext mainContext, String title, List<JSON> countryLogData) {
  List<Widget> _countryList = [];
  BuildContext? _context;

  for (var i=1; i<countryLogData.length; i++) {
    var item = countryLogData[i];
    _countryList.add(
        GestureDetector(
            onTap: () {
              AppData.currentCountryFlag  = STR(item['countryFlag']);
              AppData.currentCountry      = STR(item['country']);
              AppData.currentState        = STR(item['countryState']);
              writeCountryLocal();
              Navigator.of(_context!).pop();
            },
            child: Container(
                height: 30,
                child: Row(
                    children: [
                      Text(STR(item['countryFlag'])),
                      Text(' - '),
                      Text(STR(item['countryState'])),
                    ]
                )
            )
        )
    );
  }

  return showDialog(
    context: mainContext,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      _context = context;
      return PointerInterceptor(
        child: AlertDialog(
          title: Text(title, style: DialogTitleStyle(context)),
          scrollable: true,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.all(20.w),
          backgroundColor: DialogBackColor(context),
          content: Container(
              child: Column(
                  children: [
                    CSCPicker(
                      showCities: false,
                      layout: Layout.vertical,
                      currentCountry: AppData.currentCountryFlag,
                      currentState: AppData.currentState,
                      selectedItemStyle: TextStyle(fontSize: 14.sp),
                      dropdownItemStyle: TextStyle(fontSize: 14.sp),
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2),
                      ),
                      disabledDropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2),
                      ),
                      onCountryChanged: (value) {
                        AppData.currentCountryFlag = value;
                        AppData.currentCountry     = GET_COUNTRY_EXCEPT_FLAG(value);
                        AppData.currentCountryCode = CountryCodeSmall(value);
                      },
                      onStateChanged:(value) {
                        AppData.currentState = value ?? '';
                        if (AppData.currentState == 'State') AppData.currentState = '';
                      },
                      onCityChanged: (value) {
                      },
                    ),
                    if (_countryList.isNotEmpty)...[
                      SubTitle(context, 'SELECT LOG'.tr, height: 40.w, topPadding: 20.w),
                      Column(
                        children: _countryList,
                      ),
                    ]
                  ]
              )
          ),
          actions: [
            TextButton(
              child: Text('DONE'),
              onPressed: () {
                writeCountryLocal();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<String> showCustomFieldSelectDialog(BuildContext context) async {
  TextStyle _titleText        = TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white);
  TextStyle _itemTitleText    = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70);
  var _itemHeight = 40.0;
  var _parentId = '';

  AppData.INFO_CUSTOMFIELD = JSON_INDEX_SORT(AppData.INFO_CUSTOMFIELD);

  return await showDialog(
      context: context,
      builder: (BuildContext _context) {
        return PointerInterceptor(
          child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                    title: Text('Custom field'.tr),
                    titlePadding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                    titleTextStyle: Theme.of(context).textTheme.subtitle1!,
                    insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 120),
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                        constraints: BoxConstraints(
                          minWidth: 400,
                        ),
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_parentId.isNotEmpty)...[
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(STR(AppData.INFO_CUSTOMFIELD[_parentId]['title']), style: ItemTitleStyle(context)),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: AppData.INFO_CUSTOMFIELD.entries.map((item) =>
                                    _parentId == STR(item.value['parentId']) ?
                                    Container(
                                      height: _itemHeight,
                                      width: double.infinity,
                                      margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (BOL(item.value['isParent'])) {
                                            setState(() {
                                              _parentId = item.key;
                                            });
                                          } else {
                                            Navigator.pop(_context, item.key);
                                          }
                                        },
                                        child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(STR(item.value['titleEdit'] ?? item.value['title']), style: ItemTitleStyle(context)),
                                              ),
                                              if (BOL(item.value['isParent']))...[
                                                SizedBox(width: 10),
                                                Icon(Icons.arrow_forward_ios, size: 20, color: Theme.of(context).primaryColor),
                                              ],
                                            ]
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary: Theme.of(context).canvasColor,
                                            minimumSize: Size.zero, // Set this
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5), // and this
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: Colors.grey, width: 2)
                                            )
                                        ),
                                      ),
                                    ) : SizedBox(width: 0, height: 0),
                                    ).toList(),
                                  ),
                                ]
                            )
                        )
                    ),
                    actions: [
                      if (_parentId.isNotEmpty)...[
                        TextButton(
                          child: Text('Back'.tr),
                          onPressed: () {
                            setState(() {
                              _parentId = '';
                            });
                          },
                        ),
                      ],
                      TextButton(
                        child: Text('Exit'.tr),
                        onPressed: () {
                          Navigator.pop(_context, '');
                        },
                      ),
                    ]
                );
              }
          ),
        );
      }
  ) ?? '';
}

Future? showMultiDatePickerDialog(BuildContext context, List<String> selectedDate) async {
  var result = [];
  List<DateTime> selectList = [];
  for (var item in selectedDate) {
    selectList.add(DateTime.parse(STR(item)));
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    LOG('----> _onSelectionChanged : ${args.value}');
    result = args.value;
    // selectedDate = format.format(args.value);
  }

  return await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SfDateRangePicker(
                    enablePastDates: false,
                    initialSelectedDates: selectList,
                    backgroundColor: DialogBackColor(context),
                    showActionButtons: true,
                    showTodayButton: true,
                    showNavigationArrow: true,
                    cancelText: 'Cancel'.tr,
                    confirmText: 'OK'.tr,
                    onSubmit: (select) {
                      var resultData = [];
                      for (var item in result) {
                        resultData.add(item.toString().split(' ').first);
                      }
                      Navigator.of(context).pop(resultData);
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.multiple,
                    onSelectionChanged: _onSelectionChanged
                ),
              ]
          ),
        );
      }
  );
}

Future showUserAlertDialog(BuildContext context, String message) async {
  return await showAlertDialog(context, 'User error'.tr, 'Can not find user information'.tr, message, 'OK'.tr);
}

Future showDatePickerDialog(BuildContext context, String selectedDate) async {
  var format = DateFormat('yyyy-MM-dd');
  var startDate = DateTime.now();

  try {
    startDate = format.parse(selectedDate);
  } catch (e) {
    LOG('----> format.parse error : $e');
    startDate = DateTime.now();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    selectedDate = format.format(args.value);
  }

  return await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SfDateRangePicker(
                    enablePastDates: false,
                    initialSelectedDate: startDate,
                    backgroundColor: DialogBackColor(context),
                    showActionButtons: true,
                    showTodayButton: true,
                    showNavigationArrow: true,
                    cancelText: 'Cancel'.tr,
                    confirmText: 'OK'.tr,
                    onSubmit: (select) {
                      Navigator.of(context).pop(selectedDate);
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.single,
                    onSelectionChanged: _onSelectionChanged
                ),
              ]
          ),
        );
      }
  );
}

Future<JSON>? showTitleOptionDialog(BuildContext context, JSON optionMain, JSON option) async {
  final _titleText        = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);
  final _descStyle00      = TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16);
  final _descStyle01      = TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 11);
  final _btnTextStyle00   = TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14);
  final _titleController  = TextEditingController();
  var _resultStr = STR(optionMain['title']);
  var _minText = 1;

  _titleController.text = _resultStr;

  if (option.isNotEmpty) {
    LOG('--> option.isNotEmpty');
    for (var item in option.entries) {
      LOG('--> item.key : $optionMain / ${item.key}');
      item.value['value'] = BOL(optionMain[item.key]) ? '1' : '';
    }
  }

  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
            child: StatefulBuilder(
                builder: (context, setState) {
                  // crate option..
                  List<Widget> _optionList = List<Widget>.from(option.entries.map((item) => SwitchListTile(
                    title: Text(STR(item.value['title']), style: _descStyle00),
                    contentPadding: EdgeInsets.all(0),
                    subtitle: Text(STR(item.value['desc']),
                        style: _descStyle01),
                    dense: true,
                    value: BOL(item.value['value']),
                    onChanged: (value) {
                      setState(() {
                        LOG('----> setSwitch result : $value');
                        option[item.key]!['value'] = value ? '1' : '';
                      });
                    },
                  )
                  ));
                  return AlertDialog(
                    scrollable: true,
                    insetPadding: EdgeInsets.all(10),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                        constraints: BoxConstraints(
                          minWidth: 350,
                          minHeight: 120,
                        ),
                        child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                child: Text('옵션 상품', style: _titleText),
                              ),
                              SizedBox(height: 20),
                              SingleChildScrollView(
                                  child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _titleController,
                                          decoration: inputLabel(context, '옵션 이름', ''),
                                          keyboardType: TextInputType.text,
                                          maxLines: 1,
                                          maxLength: 50,
                                          style: _titleText,
                                          onChanged: (value) {
                                            setState(() {
                                              _resultStr = value;
                                            });
                                          },
                                        ),
                                        Column(
                                          children: _optionList,
                                        ),
                                        if (optionMain.isNotEmpty)...[
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Flexible(
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.card_giftcard, size: 24, color: Colors.grey),
                                                            SizedBox(width: 5),
                                                            Expanded(
                                                              child: Text('다른 상품에서 가져오기', style: _btnTextStyle00),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                          elevation: 3,
                                                          primary: Colors.white,
                                                          shadowColor: Colors.grey,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                              side: BorderSide(color: Colors.grey)
                                                          )
                                                      )
                                                  )
                                              ),
                                            ],
                                          ),
                                        ]
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    actions: [
                      if (optionMain.isNotEmpty)...[
                        TextButton(
                          child: Text('삭제', style:TextStyle(color: Colors.red)),
                          onPressed: () {
                            showAlertYesNoDialog(context, '옵션 삭제', '옵션을 삭제하시겠습니까?', '옵션 상품 하위 목록이 삭제됩니다', '아니오', '예').then((value) {
                              if (value == 1) Navigator.of(context).pop({'delete':1});
                            });
                          },
                        ),
                        showVerticalDivider(Size(10, 20)),
                      ],
                      TextButton(
                        child: Text('취소'),
                        onPressed: () {
                          Navigator.of(context).pop({});
                        },
                      ),
                      TextButton(
                        child: Text('확인', style:TextStyle(color: _resultStr.length > _minText ? Colors.blue : Colors.grey)),
                        onPressed: () {
                          if (_resultStr.length <= _minText) return;
                          var result = JSON.from(jsonDecode('{"title": "$_resultStr"}'));
                          result['option'] = option;
                          Navigator.of(context).pop(result);
                        },
                      ),
                    ],
                  );
                }
            )
        );
      }
  ) ?? '';
}

Future<String> showTextInputTypeDialog(BuildContext context, String title, String message, String text, int minText, int lineMax, TextInputType inputType) async {
  var result = await showTextInputLimitExDialog(context, title, message, text, minText, DESC_LENGTH, lineMax, inputType, null, '');
  return result['desc'];
}

Future<JSON> showTextInputCancelDialog(BuildContext context, String title, String message, String text, int minText, int lineMax, TextInputType inputType) async {
  var result = await showTextInputLimitExDialog(context, title, message, text, minText, DESC_LENGTH, lineMax, inputType, null, '');
  return result;
}

Future<String> showTextInputDialog(BuildContext context, String title, String message, String text, int minText, List<String>? checkList) async {
  return await showTextInputLimitDialog(context, title, message, text, minText, DESC_LENGTH, 1, checkList);
}

Future<String> showTextFieldInputDialog(BuildContext context, String title, String message, String text, int lineMax) async {
  return await showTextInputLimitDialog(context, title, message, text, 6, DESC_LENGTH, lineMax, null);
}

Future<String> showTextInputLimitDialog(BuildContext context, String title, String message, String text, int minText, int maxText, int lineMax, List<String>? checkList) async {
  var result = await showTextInputLimitExDialog(context, title, message, text, minText, maxText, lineMax, lineMax == 1 ? TextInputType.text : TextInputType.multiline, checkList, '');
  return result['desc'];
}

Future<JSON> showTextInputLimitExDialog(BuildContext context, String title, String message, String text,
    int minText, int maxText, int lineMax, TextInputType inputType,  List<String>? checkList, String exButtonText) async {

  final _titleController = TextEditingController();
  var _resultStr = text;
  var _isChecked = false;
  var _isOverwriteCheck = checkList != null && checkList.isNotEmpty;

  _titleController.text = text;

  isWillOverwrite(String checkStr) {
    if (!_isOverwriteCheck) return true;
    return checkList.contains(checkStr);
  }

  _isChecked = isWillOverwrite(_resultStr);
  LOG('--> checkList $_isChecked : $checkList');

  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
            child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text(title, style: DialogTitleStyle(context)),
                    scrollable: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    insetPadding: EdgeInsets.all(10),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                        constraints: BoxConstraints(
                            minWidth: 350
                        ),
                        child: SizedBox(
                            height: lineMax * 50 + (message.isNotEmpty ? 60 : 30),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message.isNotEmpty)...[
                                    SizedBox(height: 10),
                                    Text(message, style: ItemTitleStyle(context), maxLines: 1),
                                    SizedBox(height: 10),
                                  ],
                                  TextFormField(
                                    controller: _titleController,
                                    decoration: inputLabel(context, '', ''),
                                    keyboardType: inputType,
                                    autofocus: exButtonText.isEmpty,
                                    maxLines: lineMax,
                                    maxLength: maxText,
                                    toolbarOptions: ToolbarOptions(
                                      paste: true,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _resultStr = value;
                                        _isChecked = isWillOverwrite(_resultStr);
                                      });
                                    },
                                  )
                                ]
                            )
                        )
                    ),
                    actions: [
                      TextButton(
                        child: Text('Paste'.tr),
                        onPressed: () {
                          Clipboard.getData(Clipboard.kTextPlain).then((result) {
                            if (result != null && result.text != null) {
                              setState(() {
                                _resultStr = result.text!;
                                _titleController.text = _resultStr;
                              });
                            }
                          });
                        },
                      ),
                      showVerticalDivider(Size(40, 12)),
                      if (exButtonText.isNotEmpty)...[
                        TextButton(
                          child: Text(exButtonText),
                          onPressed: () {
                            Navigator.of(context).pop({'desc': _resultStr, 'exButton' : 1});
                          },
                        ),
                        showVerticalDivider(Size(2, 20)),
                      ],
                      TextButton(
                        child: Text('Cancel'.tr),
                        onPressed: () {
                          Navigator.of(context).pop({'desc': '', 'result': 'cancel'});
                        },
                      ),
                      TextButton(
                        child: Text(_resultStr.isNotEmpty && _isOverwriteCheck && _isChecked ? 'Update'.tr : 'OK'.tr,
                            style:TextStyle(fontWeight: FontWeight.w600, color: _resultStr.length >= minText ? Theme.of(context).primaryColor : Colors.grey)),
                        onPressed: () {
                          if (_resultStr.length < minText || _resultStr.length > maxText) return;
                          Navigator.of(context).pop({'desc': _resultStr, 'result': 'ok'});
                        },
                      ),
                    ],
                  );
                }
            )
        );
      }
  );
}

Future<JSON> showDoubleTextInputDialog(BuildContext context, String title, JSON inputInfo, String qHint, String aHint) async {
  final _textController1 = TextEditingController();
  final _textController2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _minText = 1;

  _textController1.text = inputInfo['title'];
  _textController2.text = inputInfo['desc'];

  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
            child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text(title, style: DialogTitleStyle(context)),
                    titleTextStyle: DialogTitleStyle(context),
                    scrollable: true,
                    insetPadding: EdgeInsets.all(20),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                        constraints: BoxConstraints(
                            minWidth: 350
                        ),
                        child: Form(
                            key: _formKey,
                            child: Column(
                                children: [
                                  TextFormField(
                                    controller: _textController1,
                                    decoration: inputLabel(context, qHint, ''),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    maxLength: 50,
                                    style: DialogDescStyle(context),
                                    validator: (value) {
                                      if (value!.length >= _minText) return null;
                                      return '${'Please check text length'.tr} (${'min'.tr}: $_minText)';
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        inputInfo['title'] = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    controller: _textController2,
                                    decoration: inputLabel(context, aHint, ''),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    maxLength: 500,
                                    style: DialogDescStyle(context),
                                    validator: (value) {
                                      if (value!.length >= _minText) return null;
                                      return '${'Please check text length'.tr} (${'min'.tr}: $_minText)';
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        inputInfo['desc'] = value;
                                      });
                                    },
                                  )
                                ]
                            )
                        )
                    ),
                    actions: [
                      TextButton(
                        child: Text('Cancel'.tr),
                        onPressed: () {
                          Navigator.of(context).pop({});
                        },
                      ),
                      TextButton(
                        child: Text('OK'.tr),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop(inputInfo);
                          }
                        },
                      ),
                    ],
                  );
                }
            )
        );
      }
  );
}

Future<String>? showDoubleInputDialog(BuildContext context, String title, String message, double value, int minText, List<String>? checkList) async {
  final _titleText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);
  final _titleController = TextEditingController();
  var _resultStr = value.toString();
  var _isChecked = false;
  var _isOverwriteCheck = checkList != null && checkList.isNotEmpty;

  if (value > 0) _titleController.text = value.toString();

  isWillOverwrite(String checkStr) {
    if (!_isOverwriteCheck) return true;
    return checkList.contains(checkStr);
  }

  _isChecked = isWillOverwrite(_resultStr);
  LOG('--> checkList $_isChecked : $checkList');

  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
            child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    // title: Text(title, style: dialogTitleText1),
                    insetPadding: EdgeInsets.all(20),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                        constraints: BoxConstraints(
                          minWidth: 400, maxHeight: 115,
                        ),
                        child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                child: Text(message, style: _titleText),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _titleController,
                                decoration: inputLabel(context, title, ''),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                autofocus: true,
                                maxLines: 1,
                                maxLength: 50,
                                style: _titleText,
                                onChanged: (value) {
                                  setState(() {
                                    _resultStr = value;
                                    _isChecked = isWillOverwrite(_resultStr);
                                  });
                                },
                              )
                            ]
                        )
                    ),
                    actions: [
                      TextButton(
                        child: Text('Cancel'.tr),
                        onPressed: () {
                          Navigator.of(context).pop('');
                        },
                      ),
                      TextButton(
                        child: Text(_resultStr.isNotEmpty && _isOverwriteCheck && _isChecked ? 'Update'.tr : 'OK'.tr,
                            style:TextStyle(fontWeight: FontWeight.w600, color: _resultStr.length >= minText ? Colors.blueAccent : Colors.grey)),
                        onPressed: () {
                          if (_resultStr.length < minText) return;
                          Navigator.of(context).pop(_resultStr);
                        },
                      ),
                    ],
                  );
                }
            )
        );
      }
  ) ?? '';
}

Future<JSON>? showOptionItemAddDialog(BuildContext context, JSON optionItem, JSON option) async {
  final _titleText        = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);
  final _descStyle00      = TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16);
  final _descStyle01      = TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 11);
  final _descStyle02      = TextStyle(color: Colors.purple, fontWeight: FontWeight.normal, fontSize: 11);

  final _textController   = List<TextEditingController>.generate(10, (index) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  var _minText = 1;
  var _isImageReady = false;

  // optionItem['title'  ] = 'test option item';
  // optionItem['price'  ] = 1000;
  // optionItem['stock'  ] = 9999;
  // optionItem['buyMin' ] = 1;
  // optionItem['buyMax' ] = 9999;

  _textController[0].text = STR(optionItem['title']);
  _textController[1].text = STR(optionItem['desc']);
  _textController[2].text = STR(optionItem['price'], defaultValue: '0');
  _textController[3].text = STR(optionItem['priceTrans'], defaultValue: '0');
  _textController[4].text = STR(optionItem['salePrice'] , defaultValue: '0');
  _textController[5].text = STR(optionItem['saleRatio'] , defaultValue: '0');
  _textController[6].text = STR(optionItem['stock' ], defaultValue: '0');
  _textController[7].text = STR(optionItem['']);
  _textController[8].text = STR(optionItem['buyMin'], defaultValue: '1');
  _textController[9].text = STR(optionItem['buyMax'], defaultValue: '1');

  if (option.isNotEmpty) {
    for (var item in option.entries) {
      item.value['value'] = BOL(optionItem[item.key]) ? '1' : '';
    }
  }

  picLocalImage() async {
    var imageByte = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageByte != null) {
      return imageByte.readAsBytes().then((value) {
        optionItem['image'] = value;
        return imageByte.name;
      });
    } else {
      return null;
    }
  }

  LOG('---> optionItem: $optionItem');
  _isImageReady = optionItem['image'] != null || optionItem['pic'] != null;

  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
            child: StatefulBuilder(
                builder: (context, setState) {
                  // crate option..
                  List<Widget> _optionList = List<Widget>.from(option.entries.map((item) => SwitchListTile(
                    title: Text(STR(item.value['title']), style: _descStyle00),
                    contentPadding: EdgeInsets.all(0),
                    subtitle: Text(STR(item.value['desc']), style: _descStyle01),
                    dense: true,
                    value: BOL(item.value['value']),
                    onChanged: (value) {
                      setState(() {
                        option[item.key]!['value'] = value ? '1' : '';
                      });
                    },
                  )
                  ));

                  return AlertDialog(
                    scrollable: true,
                    // title: Text(title, style: dialogTitleText1),
                    insetPadding: EdgeInsets.all(10),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                        constraints: BoxConstraints(
                          minWidth: 350,
                        ),
                        child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text('옵션 상품 추가', style: _titleText),
                                ],
                              ),
                              SizedBox(height: 20),
                              Form(
                                  key: _formKey,
                                  child: Column(
                                      children: [
                                        SizedBox(height: 5),
                                        Row(
                                            children: [
                                              Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey, width: 2),
                                                    borderRadius: BorderRadius.all(Radius.circular(8))
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    picLocalImage().then((value) {
                                                      setState(() {
                                                        _isImageReady = value != null;
                                                        optionItem['image_name'] = STR(value);
                                                        LOG('---> image_name : ${optionItem['image_name']}');
                                                      });
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      if (optionItem['image'] != null)
                                                        Image.memory(optionItem['image'], fit: BoxFit.fitHeight),
                                                      if (optionItem['image'] == null && optionItem['pic'] != null)
                                                        showImageFit(optionItem['pic']),
                                                      if (!_isImageReady)
                                                        SizedBox(
                                                          width: 45,
                                                          height: 45,
                                                          child:  Icon(Icons.add, size: 26, color: Colors.grey),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              if (!_isImageReady)...[
                                                Text('이미지 선택', style: _descStyle00),
                                              ],
                                              if (_isImageReady)...[
                                                GestureDetector(
                                                  onTap: () {
                                                    picLocalImage().then((value) {
                                                      setState(() {
                                                        optionItem['image_name'] = STR(value);
                                                        _isImageReady = value != null;
                                                        LOG('---> image_name : ${optionItem['image_name']}');
                                                      });
                                                    });
                                                  },
                                                  child: Icon(Icons.settings, color: Colors.grey, size: 24),
                                                ),
                                              ]
                                            ]
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _textController[0],
                                          decoration: inputLabel(context, '옵션 상품 이름', ''),
                                          keyboardType: TextInputType.text,
                                          maxLines: 1,
                                          maxLength: 50,
                                          style: _titleText,
                                          onChanged: (value) {
                                            setState(() {
                                              optionItem['title'] = value;
                                            });
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: _textController[1],
                                          decoration: inputLabel(context, '옵션 상품 내용', ''),
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          maxLength: 200,
                                          style: _titleText,
                                          onChanged: (value) {
                                            setState(() {
                                              optionItem['desc'] = value;
                                            });
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                            children: [
                                              Flexible(
                                                child: TextFormField(
                                                  controller: _textController[2],
                                                  decoration: inputLabelSuffix(context, '판매가격(할인 전 가격)', '', suffix: '원'),
                                                  keyboardType: TextInputType.number,
                                                  maxLines: 1,
                                                  style: _titleText,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      optionItem['price'] = DBL(value);
                                                      // optionItem['saleRatio'] = DBL(optionItem['salePrice']) / DBL(optionItem['price']) * 100;
                                                      // optionItem['salePrice'] = DBL(optionItem['price']) / 100 * DBL(optionItem['saleRatio']);
                                                      // _textController[4].text = STR(DBL(optionItem['salePrice']));
                                                      // _textController[5].text = STR(DBL(optionItem['saleRatio']));
                                                    });
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Flexible(
                                                child: TextFormField(
                                                  controller: _textController[3],
                                                  decoration: inputLabelSuffix(context, '추가 배송비', '', suffix: '원'),
                                                  keyboardType: TextInputType.number,
                                                  maxLines: 1,
                                                  style: _titleText,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      optionItem['priceTrans'] = DBL(value);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ]
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                            children: [
                                              Flexible(
                                                  child: TextFormField(
                                                    controller: _textController[4],
                                                    decoration: inputLabelSuffix(context, '할인 가격', '', suffix: '원', isEnabled: DBL(optionItem['price']) > 0),
                                                    keyboardType: TextInputType.number,
                                                    maxLines: 1,
                                                    style: _titleText,
                                                    enabled: DBL(optionItem['price']) > 0,
                                                    validator: (value) {
                                                      if (DBL(value) <= DBL(optionItem['price'])) return null;
                                                      return '판매 가격보다 큰 금액입니다';
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        optionItem['salePrice'] = DBL(value);
                                                        // optionItem['saleRatio'] = DBL(optionItem['salePrice']) / DBL(optionItem['price']) * 100;
                                                        // _textController[5].text = STR(DBL(optionItem['saleRatio']));
                                                      });
                                                    },
                                                  )
                                              ),
                                              SizedBox(
                                                  width: 20,
                                                  child: Icon(Icons.add, size: 18, color: Colors.grey)
                                              ),
                                              Flexible(
                                                  child: TextFormField(
                                                    controller: _textController[5],
                                                    decoration: inputLabelSuffix(context, '할인 퍼센트', '', suffix: '%', isEnabled: DBL(optionItem['price']) > 0),
                                                    keyboardType: TextInputType.number,
                                                    maxLines: 1,
                                                    enabled: DBL(optionItem['price']) > 0,
                                                    validator: (value) {
                                                      if (INT(value) >= 0 && INT(value) <= 100) return null;
                                                      return '0 ~ 100 사이의 값이 필요합니다';
                                                    },
                                                    style: _titleText,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        optionItem['saleRatio'] = DBL(value);
                                                        // optionItem['salePrice'] = DBL(optionItem['price']) / 100 * DBL(optionItem['saleRatio']);
                                                        // _textController[4].text = STR(DBL(optionItem['salePrice']));
                                                      });
                                                    },
                                                  )
                                              ),
                                            ]
                                        ),
                                        SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 30,
                                          child: Text('할인 가격과 할인 퍼센트는 순차적으로 적용됩니다\n예) 판매가격 - 할인가격 - ((판매가격 - 할인가격) * 할인퍼센트 / 100) = 최종가격',
                                              style: _descStyle02, maxLines: 2, textAlign: TextAlign.left),
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                            children: [
                                              Flexible(
                                                  child: TextFormField(
                                                    controller: _textController[6],
                                                    decoration: inputLabel(context, '보유 재고', ''),
                                                    keyboardType: TextInputType.number,
                                                    maxLines: 1,
                                                    style: _titleText,
                                                    validator: (value) {
                                                      if (INT(value) > 0) return null;
                                                      return '1개 이상의 값이 필요합니다';
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        optionItem['stock'] = INT(value);
                                                      });
                                                    },
                                                  )
                                              ),
                                              SizedBox(width: 20),
                                              Flexible(
                                                  child: Container()
                                                // child: TextFormField(
                                                //   controller: _textController[7],
                                                //   decoration: inputLabel('', ''),
                                                //   keyboardType: TextInputType.number,
                                                //   maxLines: 1,
                                                //   style: _titleText,
                                                //   onChanged: (value) {
                                                //     setState(() {
                                                //       optionItem['salePrice'] = DBL(value);
                                                //     });
                                                //   },
                                                // )
                                              ),
                                            ]
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                            children: [
                                              Flexible(
                                                  child: TextFormField(
                                                    controller: _textController[8],
                                                    decoration: inputLabel(context, '최소 구매갯수', ''),
                                                    keyboardType: TextInputType.number,
                                                    maxLines: 1,
                                                    style: _titleText,
                                                    validator: (value) {
                                                      if (INT(value) > 0) return null;
                                                      return '최소 1개 이상 갯수가 필요합니다';
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        optionItem['buyMin'] = INT(value);
                                                      });
                                                    },
                                                  )
                                              ),
                                              SizedBox(width: 20),
                                              Flexible(
                                                  child: TextFormField(
                                                    controller: _textController[9],
                                                    decoration: inputLabel(context, '최대 구매갯수', ''),
                                                    keyboardType: TextInputType.number,
                                                    maxLines: 1,
                                                    style: _titleText,
                                                    validator: (value) {
                                                      LOG('---> stock : ${INT(value)} <= ${INT(optionItem['stock'])}');
                                                      if (INT(value) <= INT(optionItem['stock'])) return null;
                                                      return '재고 보다 적은 갯수가 필요합니다';
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        optionItem['buyMax'] = DBL(value);
                                                      });
                                                    },
                                                  )
                                              ),
                                            ]
                                        ),
                                        SizedBox(height: 20),
                                        Column(
                                          children: _optionList,
                                        ),
                                        // SizedBox(height: 20),
                                        // Row(
                                        //   children: [
                                        //     Flexible(
                                        //       child: ElevatedButton(
                                        //         onPressed: () {
                                        //           optionItem['select'] = '1';
                                        //           Navigator.of(context).pop(optionItem);
                                        //         },
                                        //         child: Container(
                                        //           height: 40,
                                        //           child: Row(
                                        //             children: [
                                        //               Icon(Icons.card_giftcard, size: 24, color: Colors.grey),
                                        //               SizedBox(width: 5),
                                        //               Expanded(
                                        //                 child: Text('상품목록에서 추가하기', style: _btnTextStyle00),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //         ),
                                        //         style: ElevatedButton.styleFrom(
                                        //           elevation: 3,
                                        //           primary: Colors.white,
                                        //           shadowColor: Colors.grey,
                                        //           shape: RoundedRectangleBorder(
                                        //               borderRadius: BorderRadius.circular(8),
                                        //               side: BorderSide(color: Colors.grey)
                                        //           )
                                        //         )
                                        //       )
                                        //     ),
                                        //   ],
                                        // ),
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    actions: [
                      if (optionItem['id'].isNotEmpty)...[
                        TextButton(
                          child: Text('삭제', style:TextStyle(color: Colors.red)),
                          onPressed: () {
                            showAlertYesNoDialog(context, '옵션 삭제', '옵션상품을 삭제하시겠습니까?', '옵션 상품이 삭제됩니다', '아니오', '예').then((value) {
                              if (value == 1) {
                                optionItem['delete'] = '1';
                                Navigator.of(context).pop(optionItem);
                              }
                            });
                          },
                        ),
                        showVerticalDivider(Size(10, 20)),
                      ],
                      TextButton(
                        child: Text('취소'),
                        onPressed: () {
                          Navigator.of(context).pop({});
                        },
                      ),
                      TextButton(
                        child: Text('확인', style:TextStyle(color: optionItem['title'].length > _minText ? Colors.blue : Colors.grey)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            for (var item in option.entries) {
                              if (BOL(item.value['value']))optionItem[item.key] = '1';
                            }
                            Navigator.of(context).pop(optionItem);
                          }
                        },
                      ),
                    ],
                  );
                }
            )
        );
      }
  ) ?? '';
}

Future showImageDialog(BuildContext context, String imagePath) async {
  TextStyle _menuText   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);
  LOG('--> showImageDialog : $imagePath');
  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: Container(
            width: double.infinity,
            child: SimpleDialog(
              contentPadding: EdgeInsets.all(20),
              children: [
                showImageFit(imagePath),
                SizedBox(height: 15),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Exit'.tr, style: _menuText)
                )
              ],
            ),
          ),
        );
      }
  ) ?? '';
}

Future<JSON> showPriceInputDialog(BuildContext context, String title, String message, JSON priceData) async {
  final _textController = TextEditingController();
  String _resultStr = STR(priceData['price']);

  if (!AppData.INFO_CURRENCY.containsKey(AppData.currentCurrency)) AppData.currentCurrency = AppData.INFO_CURRENCY.entries.first.key;
  String _currencyKey = STR(priceData['currency'] ?? AppData.currentCurrency);
  LOG('--> showPriceInputDialog : $_resultStr / $_currencyKey (${AppData.currentCurrency})');

  _textController.text = _resultStr;
  List<JSON> _currencyList = List<JSON>.from(AppData.INFO_CURRENCY.entries.map((item) => {'key': item.key, 'title': '${item.key} ${item.value['currency']}'}).toList());

  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
            child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text(title, style: DialogTitleStyle(context)),
                    titleTextStyle: ItemTitleLargeStyle(context),
                    scrollable: true,
                    insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                        constraints: BoxConstraints(
                            minWidth: 400
                        ),
                        child: Column(
                            children: [
                              SizedBox(
                                  height: 60,
                                  child: Row(
                                      children: [
                                        Expanded(
                                            child: TextFormField(
                                              controller: _textController,
                                              decoration: inputLabel(context, '', ''),
                                              keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                                              autofocus: true,
                                              maxLines: 1,
                                              style: ItemTitleLargeStyle(context),
                                              onChanged: (value) {
                                                _resultStr = value;
                                              },
                                            )
                                        ),
                                        SizedBox(width: 20),
                                        SizedBox(
                                          width: 100,
                                          child: DropDownMenuWidget(_currencyList, selectKey: _currencyKey, onSelected: (key) {
                                            _currencyKey = key;
                                          }),
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    actions: [
                      TextButton(
                        child: Text('Cancel'.tr),
                        onPressed: () {
                          Navigator.of(context).pop('');
                        },
                      ),
                      TextButton(
                        child: Text('OK'.tr,
                            style:TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                        onPressed: () {
                          LOG('--> price result : $_resultStr / $_currencyKey');
                          priceData['desc'] = '${PRICE_STR(_resultStr)} ${AppData.INFO_CURRENCY[_currencyKey]['currency']}';
                          priceData['price'] = _resultStr;
                          priceData['currency'] = _currencyKey;
                          Navigator.of(context).pop(priceData);
                        },
                      ),
                    ],
                  );
                }
            )
        );
      }
  );
}

enum ReserveTextType {
  title,
  desc,
  price,
  date,
  people,
}

Future<JSON> showReserveEditDialog(BuildContext context, String title, String message, JSON jsonData) async {
  final _formKey         = GlobalKey<FormState>();
  final _textController  = List.generate(ReserveTextType.values.length, (index) => TextEditingController());
  String _priceStr  = STR(jsonData['price']);
  String _titleStr  = STR(jsonData['title']);
  String _descStr   = STR(jsonData['desc']);
  String _dateStr   = INT(jsonData['startDay'], defaultValue: 30).toString();
  String _peopleStr = INT(jsonData['people']).toString();

  if (!AppData.INFO_CURRENCY.containsKey(AppData.currentCurrency)) AppData.currentCurrency = AppData.INFO_CURRENCY.entries.first.key;
  String _currencyKey = STR(jsonData['currency'] ?? AppData.currentCurrency);
  LOG('--> showPriceInputDialog : $_priceStr / $_currencyKey (${AppData.currentCurrency})');

  _textController[ReserveTextType.price.index].text   = _priceStr;
  _textController[ReserveTextType.title.index].text   = _titleStr;
  _textController[ReserveTextType.desc.index].text    = _descStr;
  _textController[ReserveTextType.date.index].text    = _dateStr;
  _textController[ReserveTextType.people.index].text  = _peopleStr;
  List<JSON> _currencyList = List<JSON>.from(AppData.INFO_CURRENCY.entries.map((item) => {'key': item.key, 'title': '${item.key} ${item.value['currency']}'}).toList());

  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
            child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text(title, style: DialogTitleStyle(context)),
                    titleTextStyle: ItemTitleLargeStyle(context),
                    scrollable: true,
                    insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                        constraints: BoxConstraints(
                            minWidth: 400
                        ),
                        child: Form(
                            key: _formKey,
                            child: Column(
                                children: [
                                  TextFormField(
                                    controller: _textController[ReserveTextType.title.index],
                                    decoration: inputLabel(context, 'Title *'.tr, ''),
                                    keyboardType: TextInputType.text,
                                    autofocus: true,
                                    maxLines: 1,
                                    style: ItemTitleLargeStyle(context),
                                    validator: (value) {
                                      if (value!.isNotEmpty) return null;
                                      return 'Please enter the title'.tr;
                                    },
                                    onChanged: (value) {
                                      _titleStr = value;
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  SubTitle(context, 'RESERVATION AMOUNT'.tr),
                                  Row(
                                      children: [
                                        SizedBox(
                                            width: 120,
                                            child: TextFormField(
                                              controller: _textController[ReserveTextType.price.index],
                                              decoration: inputLabel(context, 'Amount', ''),
                                              keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                                              maxLines: 1,
                                              style: ItemTitleLargeStyle(context),
                                              onChanged: (value) {
                                                _priceStr = value;
                                              },
                                            )
                                        ),
                                        SizedBox(width: 20),
                                        SizedBox(
                                          width: 100,
                                          child: DropDownMenuWidget(_currencyList, selectKey: _currencyKey, onSelected: (key) {
                                            _currencyKey = key;
                                          }),
                                        )
                                      ]
                                  ),
                                  TextInputWidget('RESERVE START DAY'.tr,
                                    _dateStr,
                                    onChanged: (result) {
                                      LOG('--> RESERVE START DAY : $result');
                                      _dateStr = result;
                                    },
                                    inputType: TextInputType.number,
                                    tailText: 'Days Before',
                                  ),
                                  TextInputWidget('NUMBER OF RESERVATIONS'.tr,
                                    _peopleStr,
                                    onChanged: (result) {
                                      LOG('--> NUMBER OF RESERVATIONS : $result');
                                      _peopleStr = result;
                                    },
                                    inputType: TextInputType.number,
                                    tailText: '${'People'.tr}\n(0 = ${'unlimited'.tr})',
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _textController[ReserveTextType.desc.index],
                                    decoration: inputLabel(context, 'Description'.tr, ''),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 2,
                                    style: ItemTitleLargeStyle(context),
                                    onChanged: (value) {
                                      _descStr = value;
                                    },
                                  ),
                                ]
                            )
                        )
                    ),
                    actions: [
                      TextButton(
                        child: Text('Cancel'.tr),
                        onPressed: () {
                          Navigator.of(context).pop('');
                        },
                      ),
                      TextButton(
                        child: Text('OK'.tr,
                            style:TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                        onPressed: () {
                          LOG('--> price result : $_priceStr / $_currencyKey');
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          jsonData['title']     = _titleStr;
                          jsonData['price']     = _priceStr;
                          jsonData['currency']  = _currencyKey;
                          jsonData['startDay']  = int.parse(_dateStr);
                          jsonData['people']    = int.parse(_peopleStr);
                          jsonData['desc']      = _descStr;
                          jsonData['descEx']    = '$_titleStr : $_dateStr days before / ${PRICE_STR(_priceStr)} ${AppData.INFO_CURRENCY[_currencyKey]['currency']}';
                          Navigator.of(context).pop(jsonData);
                        },
                      ),
                    ],
                  );
                }
            )
        );
      }
  );
}

Future<JSON> showEditCommentDialog(BuildContext context, CommentType type, String title,
    JSON jsonData, JSON targetUserInfo, bool isCanDelete, bool isShowVote, bool isHidden,
    {String subTitle = '', String targetId = '', var isSelectImage = true}) async {

  final _editController   = TextEditingController();
  final _editControllerEx = TextEditingController();
  final _imageGalleryKey = GlobalKey();
  final api = Get.find<ApiService>();

  JSON _imageData = {};
  var _voteNow    = INT(jsonData['vote'], defaultValue: 5);
  var _descText   = STR(jsonData['desc']);
  var _isChanged  = false;

  refreshImage() {
    jsonData['imageData'] = _imageData.entries.map((e) => e.value['backPic']).toList();
  }

  refreshGallery() {
    var gallery = _imageGalleryKey.currentState as CardScrollViewerState;
    gallery.refresh();
    refreshImage();
  }

  picLocalImage() async {
    List<XFile>? pickList = await ImagePicker().pickMultiImage();
    if (pickList != null) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var imageUrl = await ShowImageCroper(image.path);
        var imageData = await ReadFileByte(imageUrl);
        var key = Uuid().v1();
        _imageData[key] = {'id': key, 'image': imageData};
      }
      refreshGallery();
    }
  }

  onDeleteResult(_context, result) {
    if (result) {
      showAlertDialog(context, 'Delete'.tr, 'Delete has been completed'.tr, '', 'OK'.tr).then((_) {
        Navigator.pop(_context, {"delete":1});
      });
    } else {
      showAlertDialog(context, 'Delete'.tr, 'Delete has been failed'.tr, '', 'OK'.tr);
    }
  }

  initData() {
    if (jsonData['imageData'] != null) {
      _imageData = {};
      for (var item in jsonData['imageData']) {
        var key = Uuid().v1();
        _imageData[key] = JSON.from(jsonDecode('{"id": "$key", "backPic": "$item"}'));
      }
    }
    _editController.text    = STR(jsonData['desc']);
    _editControllerEx.text  = STR(jsonData['descOrg']);
    jsonData['tagData'] ??= [];
  }

  initData();

  return await showDialog(
      context: context,
      builder: (BuildContext _context) {
        return PointerInterceptor(
          child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  scrollable: true,
                  title: Text(title, style: DialogTitleStyle(context)),
                  titlePadding: EdgeInsets.all(20),
                  insetPadding: EdgeInsets.symmetric(horizontal: 10),
                  contentPadding: EdgeInsets.zero,
                  backgroundColor: DialogBackColor(context),
                  content: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (jsonData['descOrg'] != null)...[
                            TextFormField(
                              controller: _editControllerEx,
                              enableSuggestions: false,
                              maxLines: null,
                              readOnly: true,
                              // style: _editText,
                            ),
                            SizedBox(height: 5),
                          ],
                          if (subTitle.isNotEmpty)...[
                            Text(subTitle, style: ItemTitleStyle(context)),
                          ],
                          if (isSelectImage)
                            ImageEditScrollViewer(
                                _imageData,
                                key: _imageGalleryKey,
                                title: 'IMAGE SELECT *'.tr,
                                isEditable: true,
                                itemWidth: 80,
                                itemHeight: 80,
                                selectText: '',
                                onActionCallback: (key, status) {
                                  setState(() {
                                    switch (status) {
                                      case 1: {
                                        picLocalImage();
                                        break;
                                      }
                                      case 2: {
                                        _imageData.remove(key);
                                        refreshGallery();
                                        break;
                                      }
                                    }
                                  });
                                }
                            ),
                          SizedBox(height: 5),
                          if (type == CommentType.comment && isShowVote)...[
                            Text('Vote'.tr),
                            SizedBox(height: 5),
                            VoteWidget(_voteNow, iconSize: 28, onChanged: (value) {
                              setState(() {
                                LOG('--> VoteWidget value : $value');
                                _voteNow = value;
                              });
                            }),
                            SizedBox(height: 10),
                          ],
                          if (isHidden)...[
                            Row(
                              children: [
                                Checkbox(
                                    value: BOL(jsonData['isHidden']),
                                    onChanged: (status) {
                                      setState(() {
                                        jsonData['isHidden'] = status! ? '1' : '';
                                      });
                                    }
                                ),
                                Text('This is a secret...'.tr, style: DialogDescExStyle(context)),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                          // if (type == CommentType.story && STR(jsonData['descOrg']).isEmpty)...[
                          //   SubTitle(context, 'TAG'.tr),
                          //   TagTextField(List<String>.from(jsonData['tagData']), (value) {
                          //     jsonData['tagData'] = value;
                          //   }),
                          //   SizedBox(height: 10),
                          // ],
                          TextFormField(
                            controller: _editController,
                            decoration: inputLabel(context, 'Description'.tr, ''),
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            maxLength: COMMENT_LENGTH,
                            style: DialogDescExStyle(context),
                            onChanged: (value) {
                              setState(() {
                                _descText = value;
                                _isChanged = true;
                              });
                            },
                          ),
                        ],
                      )
                  ),
                  actions: [
                    if (isCanDelete)...[
                      TextButton(
                        child: Text('Delete'.tr),
                        onPressed: () {
                          showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((value) {
                            if (value == 1) {
                              switch(type) {
                                case CommentType.message:
                                  api.setMessageStatus(jsonData['id'], 0).then((result) {
                                    onDeleteResult(_context, result);
                                  });
                                  break;
                                case CommentType.comment:
                                  api.setCommentStatus(jsonData['id'], 0).then((result) {
                                    onDeleteResult(_context, result);
                                  });
                                  break;
                                case CommentType.qna:
                                  api.setQnAStatus(jsonData['id'], 0).then((result) {
                                    onDeleteResult(_context, result);
                                  });
                                  break;
                                case CommentType.serviceQnA:
                                  api.setServiceQnAStatus(jsonData['id'], 0).then((result) {
                                    onDeleteResult(_context, result);
                                  });
                                  break;
                              }
                            }
                          });
                        },
                      ),
                      showVerticalDivider(Size(10, 20)),
                    ],
                    TextButton(
                      child: Text('Cancel'.tr),
                      onPressed: () {
                        Navigator.pop(_context, {});
                      },
                    ),
                    TextButton(
                        child: Text('OK'.tr),
                        onPressed: () {
                          // if (type == CommentType.story && _imageData.isEmpty) {
                          //   showAlertDialog(context, 'Story'.tr, 'Please select one or more images'.tr, '', 'OK'.tr);
                          //   return;
                          // }
                          showAlertYesNoDialog(context,
                              type == CommentType.message ? 'Message'.tr : 'Save'.tr,
                              type == CommentType.message ? 'Would you like to send a message?'.tr : 'Would you like to save?'.tr,
                              '', 'Cancel'.tr, 'OK'.tr).then((value) {
                            if (value == 0) return;
                            int upCount = 0;
                            showLoadingDialog(context, 'uploading now...'.tr);
                            Future.delayed(Duration(milliseconds: 200), () async {
                              for (var item in _imageData.entries) {
                                var result = await api.uploadImageData(item.value as JSON, 'comment_img');
                                if (result != null) {
                                  _imageData[item.key]['backPic'] = result;
                                  upCount++;
                                }
                              }
                              LOG('---> upload upCount : $upCount');
                              if (type == CommentType.comment) jsonData['vote'] = _voteNow;
                              jsonData['desc'] = _descText;
                              jsonData['imageData'] = [];
                              for (var item in _imageData.entries) {
                                if (item.value['backPic'] != null) jsonData['imageData'].add(item.value['backPic']);
                              }
                              LOG('---> image upload done : ${jsonData['imageData'].length} / ${targetUserInfo['id']}');
                              jsonData = TO_SERVER_DATA(jsonData);
                              LOG('---> jsonData : $jsonData');

                              var targetUserId = STR(targetUserInfo['id']);
                              LOG('---> add data : $targetUserId / $targetUserInfo');
                              JSON? upResult;
                              switch(type) {
                                case CommentType.message:
                                  upResult = await api.addMessageItem(jsonData, targetUserInfo);
                                  AppData.messageData[targetUserId] = MessageModel.fromJson(FROM_SERVER_DATA(jsonData));
                                  break;
                                case CommentType.comment:
                                  upResult = await api.addCommentItem(jsonData, targetUserInfo);
                                  break;
                                case CommentType.qna:
                                  upResult = await api.addQnAItem(jsonData, targetUserInfo);
                                  break;
                                case CommentType.serviceQnA:
                                  upResult = await api.addServiceQnAItem(jsonData);
                                  AppData.serviceQnAData[jsonData['id']] = jsonData;
                                  break;
                                case CommentType.story:
                                  upResult = await api.addStoryItem(jsonData);
                                  break;
                              }
                              Navigator.of(dialogContext!).pop();
                              Future.delayed(Duration(milliseconds: 200), () async {
                                Navigator.pop(_context, upResult);
                              });
                            });
                          });
                        }
                    )
                  ],
                );
              }
          ),
        );
      }
  );
}

Future<JSON> showEditCommentMultiSendDialog(BuildContext context, CommentType type, String title, JSON jsonData, List<String> targetUserList, bool isCanDelete, bool isShowVote, bool isHidden) async {
  // final _titleText    = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);
  // final _titleText2   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.purple);
  // final _editText     = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black);
  // final _voteStyle    = TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  final _editController   = TextEditingController();
  final _editControllerEx = TextEditingController();
  final _imageGalleryKey = GlobalKey();
  final api = Get.find<ApiService>();

  JSON _imageData = {};
  var _voteNow    = INT(jsonData['vote'], defaultValue: 5);
  var _descText   = STR(jsonData['desc']);
  var _isChanged  = false;

  refreshImage() {
    jsonData['imageData'] = _imageData.entries.map((e) => e.value['backPic']).toList();
  }

  refreshGallery() {
    var gallery = _imageGalleryKey.currentState as CardScrollViewerState;
    gallery.refresh();
    refreshImage();
  }

  picLocalImage() async {
    List<XFile>? pickList = await ImagePicker().pickMultiImage();
    if (pickList != null) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var imageUrl = await ShowImageCroper(image.path);
        var imageData = await ReadFileByte(imageUrl);
        var key = Uuid().v1();
        _imageData[key] = {'id': key, 'image': imageData};
      }
      refreshGallery();
    }
  }

  onDeleteResult(_context, result) {
    if (result) {
      showAlertDialog(context, 'Delete'.tr, 'Delete has been completed'.tr, '', 'OK'.tr).then((_) {
        Navigator.pop(_context, {"delete":1});
      });
    } else {
      showAlertDialog(context, 'Delete'.tr, 'Delete has been failed'.tr, '', 'OK'.tr);
    }
  }

  initData() {
    if (jsonData['imageData'] != null) {
      _imageData = {};
      for (var item in jsonData['imageData']) {
        var key = Uuid().v1();
        _imageData[key] = JSON.from(jsonDecode('{"id": "$key", "backPic": "$item"}'));
      }
    }
    _editController.text    = STR(jsonData['desc']);
    _editControllerEx.text  = STR(jsonData['descOrg']);
  }

  initData();

  return await showDialog(
      context: context,
      builder: (BuildContext _context) {
        return PointerInterceptor(
          child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  scrollable: true,
                  title: Text(title),
                  // titleTextStyle: type == CommentType.message ? _titleText2 : _titleText,
                  // insetPadding: EdgeInsets.all(10),
                  contentPadding: EdgeInsets.zero,
                  // backgroundColor: Colors.white,
                  content: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          showHorizontalDivider(Size(double.infinity, 20)),
                          if (jsonData['descOrg'] != null)...[
                            TextFormField(
                              controller: _editControllerEx,
                              enableSuggestions: false,
                              maxLines: null,
                              readOnly: true,
                              // style: _editText,
                            ),
                            SizedBox(height: 5),
                          ],
                          ImageEditScrollViewer(
                              _imageData,
                              key: _imageGalleryKey,
                              title: 'IMAGE SELECT'.tr,
                              isEditable: true,
                              itemWidth: 60,
                              itemHeight: 60,
                              onActionCallback: (key, status) {
                                setState(() {
                                  switch (status) {
                                    case 1: {
                                      picLocalImage();
                                      break;
                                    }
                                    case 2: {
                                      _imageData.remove(key);
                                      refreshGallery();
                                      break;
                                    }
                                  }
                                });
                              }
                          ),
                          SizedBox(height: 5),
                          if (type == CommentType.comment && isShowVote)...[
                            Text('Vote'.tr),
                            SizedBox(height: 5),
                            VoteWidget(_voteNow, iconSize: 28, onChanged: (value) {
                              setState(() {
                                LOG('--> VoteWidget value : $value');
                                _voteNow = value;
                              });
                            }),
                            SizedBox(height: 10),
                          ],
                          if (isHidden)...[
                            Row(
                              children: [
                                Checkbox(
                                    value: BOL(jsonData['isHidden']),
                                    onChanged: (status) {
                                      setState(() {
                                        jsonData['isHidden'] = status! ? '1' : '';
                                      });
                                    }
                                ),
                                Text('This is a secret...'.tr, style: DialogDescExStyle(context)),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                          TextFormField(
                            controller: _editController,
                            decoration: inputLabel(context, 'Description'.tr, ''),
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            maxLength: COMMENT_LENGTH,
                            // style: _editText,
                            onChanged: (value) {
                              setState(() {
                                _descText = value;
                                _isChanged = true;
                              });
                            },
                          ),
                        ],
                      )
                  ),
                  actions: [
                    if (isCanDelete)...[
                      TextButton(
                        child: Text('Delete'.tr),
                        onPressed: () {
                          showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((value) {
                            if (value == 1) {
                              switch(type) {
                                case CommentType.message:
                                  api.setMessageStatus(jsonData['id'], 0).then((result) {
                                    onDeleteResult(_context, result);
                                  });
                                  break;
                                case CommentType.comment:
                                  api.setCommentStatus(jsonData['id'], 0).then((result) {
                                    onDeleteResult(_context, result);
                                  });
                                  break;
                                case CommentType.qna:
                                  api.setQnAStatus(jsonData['id'], 0).then((result) {
                                    onDeleteResult(_context, result);
                                  });
                                  break;
                                case CommentType.serviceQnA:
                                  api.setServiceQnAStatus(jsonData['id'], 0).then((result) {
                                    onDeleteResult(_context, result);
                                  });
                                  break;
                              }
                            }
                          });
                        },
                      ),
                      showVerticalDivider(Size(10, 20)),
                    ],
                    TextButton(
                      child: Text('Cancel'.tr),
                      onPressed: () {
                        Navigator.pop(_context, {});
                      },
                    ),
                    TextButton(
                        child: Text('OK'.tr),
                        onPressed: () {
                          showAlertYesNoDialog(context,
                              type == CommentType.message ? 'Message'.tr : 'Save'.tr,
                              type == CommentType.message ? 'Would you like to send a message?'.tr : 'Would you like to save?'.tr,
                              '', 'Cancel'.tr, 'OK'.tr).then((value) {
                            if (value == 0) return;
                            int upCount = 0;
                            showLoadingDialog(context, 'uploading now...'.tr);
                            Future.delayed(Duration(milliseconds: 200), () async {
                              for (var item in _imageData.entries) {
                                var result = await api.uploadImageData(item.value as JSON, 'comment_img');
                                if (result != null) {
                                  _imageData[item.key]['backPic'] = result;
                                  upCount++;
                                }
                              }
                              LOG('---> upload upCount : $upCount');
                              if (type == CommentType.comment) jsonData['vote'] = _voteNow;
                              jsonData['desc'] = _descText;
                              jsonData['imageData'] = [];
                              for (var item in _imageData.entries) {
                                if (item.value['backPic'] != null) jsonData['imageData'].add(item.value['backPic']);
                              }
                              LOG('---> image upload done : ${jsonData['imageData'].length} / $upCount');
                              JSON? upResult;
                              for (var item in targetUserList) {
                                var targetUserInfo = await api.getUserInfoFromId(item);
                                LOG('---> add data : $item / $targetUserInfo');
                                switch (type) {
                                  case CommentType.message:
                                    upResult = await api.addMessageItem(jsonData, targetUserInfo!);
                                    AppData.messageData[upResult['id']] = FROM_SERVER_DATA(jsonData);
                                    LOG('---> addMessageItem done : ${upResult['id']} / ${AppData.messageData.length}');
                                    break;
                                  case CommentType.comment:
                                    upResult = await api.addCommentItem(jsonData, targetUserInfo!);
                                    LOG('---> addCommentItem done : ${upResult['id']}');
                                    break;
                                  case CommentType.qna:
                                    upResult = await api.addQnAItem(jsonData, targetUserInfo!);
                                    LOG('---> addQnAItem done : ${upResult!['id']}');
                                    break;
                                  case CommentType.serviceQnA:
                                    LOG('---> addQnAItem done : ${upResult!['id']}');
                                    upResult = await api.addServiceQnAItem(jsonData);
                                    AppData.serviceQnAData[jsonData['id']] = jsonData;
                                    break;
                                }
                              }
                              Navigator.of(dialogContext!).pop();
                              Future.delayed(Duration(milliseconds: 200), () async {
                                Navigator.pop(_context, upResult);
                              });
                            });
                          });
                        }
                    )
                  ],
                );
              }
          ),
        );
      }
  ) ?? '';
}

Future showBackAgreeDialog(BuildContext context) async {
  return await showAlertYesNoDialog(context, 'Back'.tr, 'Are you sure you want to undo the modifications?'.tr, '', 'Cancel'.tr, 'OK'.tr);
}

const List<Color> colorSelectLists = [
  Colors.white,
  Colors.purple,
  Colors.purpleAccent,
  Colors.deepPurple,
  Colors.deepPurpleAccent,
  Colors.indigo,
  Colors.indigoAccent,
  Colors.blue,
  Colors.blueAccent,
  Colors.lightBlue,
  Colors.lightBlueAccent,
  Colors.cyan,
  Colors.cyanAccent,
  Colors.teal,
  Colors.tealAccent,
  Colors.green,
  Colors.greenAccent,
  Colors.lightGreen,
  Colors.lightGreenAccent,
  Colors.lime,
  Colors.limeAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.amber,
  Colors.amberAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.deepOrangeAccent,
  Colors.deepOrange,
  Colors.red,
  Colors.redAccent,
  Colors.pink,
  Colors.pinkAccent,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
];

int _portraitCrossAxisCount = 5;
int _landscapeCrossAxisCount = 6;
double _borderRadius = 8;
double _blurRadius = 5;
double _iconSize = 24;

Widget pickerLayoutBuilder(BuildContext context, List<Color> colors, PickerItem child) {
  Orientation orientation = MediaQuery.of(context).orientation;

  return SizedBox(
    width: 400,
    height: orientation == Orientation.portrait ? 460 : 340,
    child: GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? _portraitCrossAxisCount : _landscapeCrossAxisCount,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      children: [for (Color color in colors) child(color)],
    ),
  );
}

Widget pickerItemBuilder(Color color, bool isCurrentColor, void Function() changeColor) {
  return Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
      color: color,
      border: Border.all(
        color: Colors.black26
      ),
      boxShadow: [BoxShadow(color: color.withOpacity(0.8), offset: const Offset(1, 2), blurRadius: _blurRadius)],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: changeColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isCurrentColor ? 1 : 0,
          child: Icon(
            Icons.done,
            size: _iconSize,
            color: useWhiteForeground(color) ? Colors.white : Colors.black,
          ),
        ),
      ),
    ),
  );
}

showColorSelectorDialog(BuildContext context, String title, Color selectColor) async {
  return await showDialog(
    context: context,
    barrierColor: Colors.black38,
    builder: (BuildContext context) {
      return PointerInterceptor(
          child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selectColor,
                  onColorChanged: (color) {
                    Navigator.of(context).pop(color);
                  },
                  availableColors: colorSelectLists,
                  layoutBuilder: pickerLayoutBuilder,
                  itemBuilder: pickerItemBuilder,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Exit'.tr),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        ),
      );
    }
  );
}

Future showButtonDialog(BuildContext context,
    String title,
    String message1,
    String message2,
    List<Widget> actionList)
{
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          title: Text(title, style: dialogTitleTextStyle),
          titlePadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(20),
          backgroundColor: dialogBgColor,
          content: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListBody(
                    children: [
                      Text(message1, style: dialogDescTextStyle),
                      if (message2.isNotEmpty)...[
                        SizedBox(height: 10),
                        Text(message2, style: dialogDescTextExStyle),
                      ],
                    ]
                )
            ),
          ),
          actions: actionList,
        ),
      );
    },
  );
}

Future<JSON> showJsonMultiSelectDialog(BuildContext context, String title, JSON jsonData) async {
  TextStyle _titleText      = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);
  TextStyle _itemTitleText  = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black);
  TextStyle _itemDescText   = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey);
  var _editMode = false;
  var _selectCount = 0;
  var _itemHeight = 50.0;

  refreshCount() {
    _selectCount = 0;
    jsonData.forEach((key, value) {
      if (BOL(value['check'])) _selectCount++;
    });
  }

  initSelect() {
    _selectCount = 0;
    jsonData.forEach((key, value) {
      value['check'] = '';
    });
  }

  return await showDialog(
      context: context,
      builder: (BuildContext _context) {
        return PointerInterceptor(
          child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                    title: Text(title, style: _titleText),
                    // insetPadding: EdgeInsets.all(10),
                    contentPadding: EdgeInsets.only(top: 20),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                      constraints: BoxConstraints(
                        minWidth: 300,
                        maxHeight: jsonData.entries.length * _itemHeight + 30,
                      ),
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: jsonData.entries.map((item) => Container(
                              width: double.infinity,
                              height: _itemHeight,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.value['title'], style: _itemTitleText, maxLines: 1),
                                            if (item.value['desc'] != null)...[
                                              SizedBox(height: 2),
                                              Text(item.value['desc'], style: _itemDescText, maxLines: 1),
                                            ]
                                          ]
                                      ),
                                    ),
                                    if (!BOL(jsonData[item.key]['disable']))
                                      Checkbox(value: BOL(jsonData[item.key]['check']),
                                          onChanged: (value) {
                                            setState(() {
                                              jsonData[item.key]['check'] = BOL(jsonData[item.key]['check']) ? '' : '1';
                                              refreshCount();
                                              LOG( '--> jsonData[${item.key}] : $_selectCount / $value / ${jsonData[item.key]}');
                                            });
                                          }
                                      ),
                                    if (BOL(jsonData[item.key]['disable']))...[
                                      Icon(Icons.check, color: Colors.green, size: 22),
                                      SizedBox(width: 5),
                                    ],
                                  ]
                              )
                          )
                          ).toList(),
                        ),
                      ),
                    ),
                    actions: [
                      SizedBox(
                          child: Row(
                            children: [
                              if (_selectCount > 0)...[
                                TextButton(
                                  child: Text('Deselect'.tr),
                                  onPressed: () {
                                    setState(() {
                                      initSelect();
                                    });
                                  },
                                ),
                              ],
                              Expanded(child: SizedBox(height: 1)),
                              TextButton(
                                child: Text('Cancel'.tr),
                                onPressed: () {
                                  Navigator.pop(_context, {});
                                },
                              ),
                              TextButton(
                                child: Text('OK'.tr),
                                onPressed: () {
                                  Navigator.pop(_context, jsonData);
                                },
                              ),
                            ],
                          )
                      )
                    ]
                );
              }
          ),
        );
      }
  ) ?? '';
}

Future<String> showJsonButtonSelectDialog(BuildContext context, String title, List<JSON> jsonData) async {
  return await showJsonButtonSelectExDialog(context, title, jsonData, null);
}

Future<String> showJsonButtonSelectExDialog(BuildContext context, String title, List<JSON> jsonData, List<JSON>? exButton) async {
  TextStyle _titleText        = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black);
  TextStyle _itemTitleText    = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black);
  TextStyle _itemTitleText2   = TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black);
  TextStyle _itemDescText     = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey);
  TextStyle _itemDisableText  = TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.purple);
  var _itemHeight = 70.0;
  return await showDialog(
      context: context,
      builder: (BuildContext _context) {
        return PointerInterceptor(
          child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                    title: Text(title, style: DialogTitleStyle(context)),
                    insetPadding: EdgeInsets.all(20),
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                    backgroundColor: DialogBackColor(context),
                    content: Container(
                      constraints: BoxConstraints(
                        minWidth: 400,
                        maxHeight: jsonData.length * (_itemHeight + 10) + 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: jsonData.map((item) =>
                            Container(
                              height: _itemHeight,
                              width: double.infinity,
                              margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!BOL(item['disabled'])) {
                                    Navigator.pop(_context, item['id']);
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (item['icon'] != null)...[
                                        if (item['icon'] == 'video')
                                          Icon(Icons.movie_creation_outlined, size: _itemHeight * 0.5, color: Theme.of(context).primaryColor),
                                        if (item['icon'] == 'image')
                                          Icon(Icons.photo_size_select_actual_outlined, size: _itemHeight * 0.5, color: Theme.of(context).primaryColor),
                                        if (item['icon'] != 'video' && item['icon'] != 'image')
                                          showImage(item['icon'], Size(30,30)),
                                        SizedBox(width: 10),
                                      ],
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                              children: [
                                                Text(STR(item['title']).toString().tr, style: Theme.of(context).textTheme.subtitle1),
                                                if (BOL(item['disabled']))...[
                                                  SizedBox(width: 10),
                                                  Text('[${'Added'.tr}]', style: ItemDescAlertStyle(context)),
                                                ],
                                              ]
                                          ),
                                          if (STR(item['desc']).isNotEmpty)...[
                                            SizedBox(height: 5),
                                            Text(DESC(item['desc']), style: Theme.of(context).textTheme.bodySmall),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                    minimumSize: Size.zero, // Set this
                                    padding: EdgeInsets.all(15), // and this
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2)
                                    )
                                ),
                              ),
                            )
                        ).toList(),
                      ),
                    ),
                    actions: [
                      if (exButton != null)...[
                        for (var item in exButton)
                          TextButton(
                            child: Text(item['title']),
                            onPressed: () {
                              setState(() async {
                                if (item['id'] == 'copy') {
                                  item['desc'] = await Clipboard.getData(Clipboard.kTextPlain);
                                }
                              });
                            },
                          ),
                        SizedBox(width: 10),
                      ],
                      TextButton(
                        child: Text('닫기'),
                        onPressed: () {
                          Navigator.pop(_context, '');
                        },
                      ),
                    ]
                );
              }
          ),
        );
      }
  ) ?? '';
}

hideLoadingDialog() {
  if (dialogContext == null) return;
  Navigator.of(dialogContext!).pop();
  dialogContext = null;
}
