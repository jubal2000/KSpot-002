
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helpers/helpers.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:kspot_002/services/api_service.dart';
import 'package:kspot_002/services/cache_service.dart';
import 'package:kspot_002/widget/event_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import '../models/chat_model.dart';
import '../models/event_model.dart';
import '../models/message_model.dart';
import '../models/recommend_model.dart';
import '../models/upload_model.dart';
import '../services/local_service.dart';
import '../utils/address_utils.dart';
import '../widget/card_scroll_viewer.dart';
import '../widget/csc_picker/csc_picker.dart';
import '../widget/dropdown_widget.dart';
import '../widget/edit/edit_text_input_widget.dart';
import '../widget/image_scroll_viewer.dart';
import '../widget/vote_widget.dart';
import 'app_data.dart';
import '../utils/utils.dart';
import '../data/style.dart';

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
          title: Text(title, style: dialogTitleTextStyle(context)),
          titlePadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(40),
          actionsPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: DialogBackColor(context),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              alignment: Alignment.center,
              constraints: BoxConstraints(
                  minHeight: 100
              ),
              child: ListBody(
                children: [
                  Text(message1, style: isErrorMode ? dialogDescTextErrorStyle(context) : dialogDescTextStyle(context)),
                  if (message2.isNotEmpty)...[
                    SizedBox(height: 10),
                    Text(message2, style: dialogDescTextExStyle(context)),
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
            title: Text(title, style: dialogTitleTextStyle(context)),
            titlePadding: EdgeInsets.all(20),
            insetPadding: EdgeInsets.all(40),
            actionsPadding: EdgeInsets.all(10),
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: DialogBackColor(context),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                    minHeight: 100
                ),
                child: Center(
                  child: ListBody(
                    children: [
                      Text(message1, style: dialogDescTextStyle(context)),
                      if (message2.isNotEmpty)...[
                        SizedBox(height: 10),
                        Text(message2, style: dialogDescTextExStyle(context)),
                      ],
                    ]
                  )
                )
              ),
            ),
            actions: [
              TextButton(
                child: Text(btnNoStr, style: ItemTitleExStyle(context)),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
              TextButton(
                child: Text(btnYesStr, style: ItemTitleStyle(context)),
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

Future showAlertYesNoCheckDialog(BuildContext context,
    String title,
    String message,
    String checkMessage,
    String btnNoStr,
    String btnYesStr, {bool checkValue = false, bool needCheck = false})
{
  var check = checkValue.obs;
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
          child: Obx(() => AlertDialog(
            title: Text(title, style: dialogTitleTextStyle(context)),
            titlePadding: EdgeInsets.all(20),
            insetPadding: EdgeInsets.all(40),
            actionsPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: DialogBackColor(context),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                    minHeight: 100
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      Text(message, style: dialogDescTextStyle(context)),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(value: check.value, onChanged: (value) {
                            check.value = value ?? false;
                          }),
                          Text(checkMessage, style: dialogDescTextExStyle(context)),
                          SizedBox(width: 10),
                        ]
                      )
                    ]
                  )
                )),
              ),
            actions: [
              TextButton(
                child: Text(btnNoStr, style: ItemTitleExStyle(context)),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
              TextButton(
                child: Text(btnYesStr, style: !needCheck || check.value ? ItemTitleStyle(context) : ItemTitleExStyle(context)),
                onPressed: () {
                  if (needCheck && !check.value) return;
                  Navigator.of(context).pop(check.value ? 2 : 1);
                },
              ),
            ],
          )
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
          title: Text(title, style: dialogTitleTextStyle(context)),
          titlePadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(40),
          actionsPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: DialogBackColor(context),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                  minHeight: 100
              ),
              child: Center(
                child: ListBody(
                  children: [
                    Text(message1, style: dialogDescTextStyle(context)),
                    if (message2.isNotEmpty)...[
                      SizedBox(height: 10),
                      Text(message2, style: dialogDescTextExStyle(context)),
                    ],
                  ]
                )
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
  var currentPage = 0;

  saveImage(String fileUrl) async {
    var response = await Dio().get(fileUrl, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "KSpot-download-${Uuid().v1()}-${DATETIME_UUID_STR(DateTime.now())}");
    LOG('--> saveImage result : $result');
  }

  return await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
            scrollable: true,
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 10),
            actionsPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            backgroundColor: DialogBackColor(context),
            content: Container(
              width: MediaQuery.of(context).size.width,
              child: ImageScrollViewer(
                imageData,
                startIndex: startIndex,
                rowHeight: MediaQuery.of(context).size.width - 30,
                backgroundColor: Colors.transparent,
                imageFit: BoxFit.contain,
                showArrow: true,
                showPage: false,
                autoScroll: false,
                onPageChanged: (index) {
                  currentPage = index;
                }
              ),
            ),
            actions: [
              if (isCanDownload)...[
                IconButton(
                  onPressed: () async {
                    showLoadingDialog(context, 'Image downloading...'.tr);
                    if (currentPage < imageData.length) {
                      var item = imageData[currentPage];
                      await saveImage(item);
                    }
                    hideLoadingDialog();
                    ShowToast('Download complete'.tr);
                  },
                  icon: Column(
                    children: [
                      Icon(Icons.download_outlined, size: 24),
                      Text('Save'.tr, style: TextStyle(fontSize: 10)),
                    ],
                  )
                ),
                IconButton(
                  onPressed: () async {
                    showLoadingDialog(context, 'All image downloading...'.tr);
                    for (var item in imageData) {
                      await saveImage(item);
                    }
                    hideLoadingDialog();
                    ShowToast('Download complete'.tr);
                  },
                  icon: Column(
                    children: [
                      Icon(Icons.download_rounded, size: 24),
                      Text('Save all'.tr, style: TextStyle(fontSize: 10)),
                    ],
                  )
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

Future showFileSlideDialog(BuildContext context, JSON fileData, {bool isCanDownload = false, String? startKey}) async {
  LOG('--> showFileSlideDialog : $fileData');
  var currentPage = 0;
  List<JSON> fileList = [];

  saveImage(String url, [String? fileName]) async {
    var response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: fileName ?? "KSpot-download-${Uuid().v1()}-${DATETIME_UUID_STR(DateTime.now())}");
    LOG('--> saveImage result : $result');
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      LOG('---> downloading : ${(received / total * 100).toStringAsFixed(0)}%');
    }
  }

  saveFile(String url, String savePath) async {
    try {
      var response = await Dio().get(url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      LOG('--> response.headers : ${response.headers}');
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      LOG('--> response error : $e');
    }
  }

  downloadFile(JSON item) async {
    var isFile = item.runtimeType != String && item['extension'] != null && !IS_IMAGE_FILE(item['extension']);
    if (isFile) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage]!.isGranted){
        var tempDir = await getFileSavePath();
        if (tempDir.isNotEmpty) {
          var fullPath = '$tempDir/${item['name']}';
          await saveFile(STR(item['url']), fullPath);
        }
      }
    } else {
      await saveImage(STR(item['url']));
    }
  }

  initData() {
    fileList.clear();
    currentPage = 0;
    var i=0;
    for (var item in fileData.entries) {
      fileList.add(item.value);
      if (startKey == item.key) {
        currentPage = i;
      }
      i++;
    }
  }

  initData();

  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: AlertDialog(
              scrollable: true,
              insetPadding: EdgeInsets.all(10),
              contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              actionsPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              backgroundColor: DialogBackColor(context),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: ImageScrollViewer(
                    fileList,
                    startIndex: currentPage,
                    rowHeight: MediaQuery.of(context).size.width - 30,
                    backgroundColor: Colors.transparent,
                    imageFit: BoxFit.contain,
                    showArrow: true,
                    showPage: false,
                    autoScroll: false,
                    onPageChanged: (index) {
                      currentPage = index;
                    }
                ),
              ),
              actions: [
                if (isCanDownload)...[
                  IconButton(
                      onPressed: () async {
                        showLoadingDialog(context, 'Downloading...'.tr);
                        if (currentPage < fileData.length) {
                          var item = fileData.entries.elementAt(currentPage);
                          await downloadFile(item.value);
                        }
                        hideLoadingDialog();
                        ShowToast('Download complete'.tr);
                      },
                      icon: Column(
                        children: [
                          Icon(Icons.download_outlined, size: 24),
                          Text('Save'.tr, style: TextStyle(fontSize: 10)),
                        ],
                      )
                  ),
                  if (fileData.length > 1)
                    IconButton(
                      onPressed: () async {
                        showLoadingDialog(context, 'Downloading...'.tr);
                        for (var item in fileData.entries) {
                          await downloadFile(item.value);
                        }
                        hideLoadingDialog();
                        ShowToast('Download complete'.tr);
                      },
                      icon: Column(
                        children: [
                          Icon(Icons.download_rounded, size: 24),
                          Text('Save all'.tr, style: TextStyle(fontSize: 10)),
                        ],
                      )
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
                Text(message, style: dialogDescTextExStyle(context), maxLines: 5, softWrap: true),
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
  var countryFlag   = AppData.currentCountryFlag;
  var country       = AppData.currentCountry;
  var countryCode   = AppData.currentCountryCode;
  var countryState  = AppData.currentState;

  for (var i=1; i<countryLogData.length; i++) {
    var item = countryLogData[i];
    _countryList.add(
        GestureDetector(
            onTap: () {
              AppData.currentCountryFlag  = STR(item['countryFlag']);
              AppData.currentCountry      = STR(item['country']);
              AppData.currentState        = STR(item['countryState']);
              AppData.currentCountryCode  = CountryCodeSmall(country);
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
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          actionsPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          backgroundColor: DialogBackColor(context),
          content: Container(
            width: Get.width,
            child: Column(
              children: [
                CSCPicker(
                  showCities: false,
                  layout: Layout.vertical,
                  currentCountry: countryFlag,
                  currentState:   AppData.currentState,
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
                    countryFlag   = value;
                    country       = GET_COUNTRY_EXCEPT_FLAG(value);
                    countryCode   = CountryCodeSmall(value);
                  },
                  onStateChanged:(value) {
                    countryState = value ?? '';
                    if (countryState == 'State') countryState = '';
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
              child: Text('Cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'.tr),
              onPressed: () {
                AppData.currentCountry      = country;
                AppData.currentCountryCode  = countryCode;
                AppData.currentState        = countryState;
                AppData.currentCountryFlag  = countryFlag;
                writeCountryLocal();
                Navigator.of(context).pop(country);
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
                    titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    titleTextStyle: Theme.of(context).textTheme.subtitle1!,
                    insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 120),
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                    actionsPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
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
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      child: Text(STR(AppData.INFO_CUSTOMFIELD[_parentId]['title']), style: ItemTitleBoldStyle(context)),
                                    ),
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

  return showDatetimePickerDialog(context, startDate);
}

Future<DateTime?> showDatetimePickerDialog(BuildContext context, DateTime startDate) async {
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
                  Navigator.of(context).pop(startDate);
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
                view: DateRangePickerView.month,
                selectionMode: DateRangePickerSelectionMode.single,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  startDate = args.value;
                }
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
                                                      style: ElevatedButton.styleFrom(
                                                          elevation: 3,
                                                          primary: Colors.white,
                                                          shadowColor: Colors.grey,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                              side: BorderSide(color: Colors.grey)
                                                          )
                                                      ),
                                                      child: SizedBox(
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

Future<JSON> showTextInputImageDialog(BuildContext context, String title, String message, String text, int lineMax, List<String>? checkList, {JSON? imageInfo, int imageMax = 1}) async {
  return await showTextInputLimitExDialog(context, title, message, text, 1, DESC_LENGTH,
    lineMax, lineMax == 1 ? TextInputType.text : TextInputType.multiline, checkList, '', imageInfo: imageInfo, imageMax: imageMax);
}

Future<String> showTextInputLimitDialog(BuildContext context, String title, String message, String text, int minText, int maxText, int lineMax, List<String>? checkList, {JSON? imageInfo}) async {
  var result = await showTextInputLimitExDialog(context, title, message, text, minText, maxText, lineMax, lineMax == 1 ? TextInputType.text : TextInputType.multiline, checkList, '', imageInfo: imageInfo);
  return result['desc'];
}

Future<JSON> showTextInputLimitExDialog(BuildContext context, String title, String message, String text,
    int minText, int maxText, int lineMax, TextInputType inputType,  List<String>? checkList, String exButtonText, {JSON? imageInfo, int imageMax = 1}) async {

  final titleController = TextEditingController();
  final imageEditKey = GlobalKey();
  var _isChecked = false;
  var _isOverwriteCheck = checkList != null && checkList.isNotEmpty;
  var imageChanged = false;

  titleController.text = text;

  isWillOverwrite(String checkStr) {
    if (!_isOverwriteCheck) return true;
    return checkList.contains(checkStr);
  }

  refreshGallery() {
    var gallery = imageEditKey.currentState as CardScrollViewerState;
    gallery.refresh();
    imageChanged = true;
  }

  picLocalImage() async {
    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: PIC_IMAGE_SIZE_MAX, maxHeight: PIC_IMAGE_SIZE_MAX);
    if (pickImage != null) {
      var imageUrl = await ShowImageCroper(pickImage.path);
      var imageData = await ReadFileByte(imageUrl);
      var key = Uuid().v1();
      imageInfo = {};
      imageInfo![key] = {'id': key, 'data': imageData};
    }
  }

  picLocalImages() async {
    List<XFile>? pickList = await ImagePicker().pickMultiImage(maxWidth: PIC_IMAGE_SIZE_MAX, maxHeight: PIC_IMAGE_SIZE_MAX);
    if (pickList.isNotEmpty) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var imageUrl = await ShowImageCroper(image.path);
        var imageData = await ReadFileByte(imageUrl);
        var key = Uuid().v1();
        imageInfo ??= {};
        imageInfo![key] = {'id': key, 'data': imageData};
      }
    }
  }

  _isChecked = isWillOverwrite(text);
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
              contentPadding: EdgeInsets.all(20),
              insetPadding: EdgeInsets.all(20),
              actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              backgroundColor: DialogBackColor(context),
              content: Container(
                constraints: BoxConstraints(
                  minWidth: 350,
                ),
                child: Column(
                  children: [
                    if (message.isNotEmpty)...[
                      SizedBox(height: 10),
                      Text(message, style: ItemTitleStyle(context), maxLines: 1),
                      SizedBox(height: 10),
                    ],
                    if (imageInfo != null)
                      ImageEditScrollViewer(
                        imageInfo!,
                        key: imageEditKey,
                        title: 'IMAGE EDIT'.tr,
                        isEditable: true,
                        itemWidth: 80,
                        itemHeight: 80,
                        selectText: '',
                        imageMax: 1,
                        onActionCallback: (key, status) {
                          setState(() {
                            switch (status) {
                              case 1: {
                                if (imageMax == 1) {
                                  picLocalImage().then((_) {
                                    setState(() => refreshGallery());
                                  });
                                } else {
                                  picLocalImages().then((_) {
                                    setState(() => refreshGallery());
                                  });
                                }
                                break;
                              }
                              case 2: {
                                setState(() {
                                  imageInfo!.remove(key);
                                  refreshGallery();
                                });
                                break;
                              }
                            }
                          });
                        }
                      ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: titleController,
                      decoration: inputLabel(context, '', ''),
                      keyboardType: inputType,
                      autofocus: exButtonText.isEmpty,
                      maxLines: lineMax,
                      maxLength: maxText,
                      toolbarOptions: ToolbarOptions(
                        paste: true,
                      ),
                      onChanged: (value) {
                      },
                    )
                  ]
                )
              ),
              actions: [
                TextButton(
                  child: Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.getData(Clipboard.kTextPlain).then((result) {
                      if (result != null && result.text != null) {
                        titleController.text = result.text!;
                      }
                    });
                  },
                ),
                if (exButtonText.isNotEmpty)...[
                  TextButton(
                    child: Text(exButtonText),
                    onPressed: () {
                      Navigator.of(context).pop({'desc': titleController.text, 'exButton' : 1});
                    },
                  ),
                  showVerticalDivider(Size(2, 20)),
                ],
                TextButton(
                  child: Text('Cancel'.tr, style: ItemTitleExStyle(context)),
                  onPressed: () {
                    Navigator.of(context).pop({'desc': '', 'result': 'cancel'});
                  },
                ),
                TextButton(
                  child: Text(titleController.text.isNotEmpty && _isOverwriteCheck && _isChecked ? 'Update'.tr : 'OK'.tr,
                      style:TextStyle(fontWeight: FontWeight.w600, color: titleController.text.length >= minText ? Theme.of(context).primaryColor : Colors.grey)),
                  onPressed: () {
                    var textResult = titleController.text;
                    if ((textResult.length >= minText && textResult.length < maxText) || imageChanged) {
                      Navigator.of(context).pop({'desc': textResult, 'imageInfo': imageInfo, 'imageChanged': imageChanged ? '1' : '', 'result': 'ok'});
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
        optionItem['data'] = value;
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

Future<RecommendModel?> showEventRecommendDialog(BuildContext context, EventModel event, int max, String desc, [DateTime? startDate, int credit = 1])
{
  final startTextController = TextEditingController();
  final endTextController   = TextEditingController();
  final descTextController  = TextEditingController();
  var creditCount = credit;
  var creditRemain = max;
  var endDate = DateTime.now();
  var showStatus = 1;
  var descText = desc;

  refreshDateTime() {
    startDate ??= DateTime.now();
    endDate = startDate!.add(Duration(days: creditCount));
    startTextController.text = DATE_STR(startDate!);
    endTextController.text   = DATE_STR(endDate);
    descTextController.text  = descText;
    creditRemain = max - creditCount;
  }

  setDateChange(setState) {
    showDatetimePickerDialog(context, startDate!).then((result) {
      LOG('----> showDatetimePickerDialog startDate result : $result');
      if (result != null) {
        setState(() {
          startDate = result;
          refreshDateTime();
        });
      }
    });
  }

  // setTimeChange(setState) {
  //   showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startDate!)).then((result) {
  //     if (result != null) {
  //       setState(() {
  //         startDate = startDate!.applyTimeOfDay(hour: result.hour, minute: result.minute);
  //         LOG('--> changed time : ${startDate.toString()}');
  //         refreshDateTime();
  //       });
  //     }
  //   });
  // }

  refreshDateTime();

  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          title: Text('Event recommend'.tr, style: dialogTitleTextStyle(context)),
          titlePadding: EdgeInsets.fromLTRB(20, 20, 0, 10),
          insetPadding: EdgeInsets.all(20),
          actionsPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: DialogBackColor(context),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                minHeight: 100
              ),
              child: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return ListBody(
                      children: [
                        Text('Recommend the target event\n(If event is recommended, it may appear first)'.tr, style: DialogDescExStyle(context)),
                        SizedBox(height: 10),
                        EventCardItem(event, itemHeight: 105.0, isShowLike: false),
                        SizedBox(height: 10),
                        SubTitle(context, 'Period'.tr, height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: startTextController,
                                decoration: inputLabel(context, 'Start date'.tr, ''),
                                maxLines: 1,
                                readOnly: true,
                                textAlign: TextAlign.center,
                                onTap: () {
                                  setDateChange(setState);
                                },
                              )
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(' ~ '),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: endTextController,
                                decoration: inputLabel(context, 'End date'.tr, ''),
                                maxLines: 1,
                                readOnly: true,
                                textAlign: TextAlign.center,
                              )
                            ),
                          ]
                        ),
                        SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: timeTextController,
                        //         decoration: inputLabel(context, 'Start time'.tr, ''),
                        //         maxLines: 1,
                        //         readOnly: true,
                        //         textAlign: TextAlign.center,
                        //         onTap: () {
                        //           setTimeChange(setState);
                        //         },
                        //       )
                        //     ),
                        //     Padding(
                        //       padding: EdgeInsets.all(10),
                        //       child: Text('   '),
                        //     ),
                        //     Expanded(
                        //       child: Container()
                        //     ),
                        //   ]
                        // ),
                        // SizedBox(height: 30),
                        Text('${'Holding credits:'.tr} $creditRemain', style: DialogDescBoldStyle(context)),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text('Use credits'.tr, style: DialogDescBoldStyle(context)),
                            SizedBox(width: 10),                            SizedBox(
                              child: NumberInputWidget(creditCount, min: 1, max: max, onChanged: (value) {
                                setState(() {
                                  creditCount = value;
                                  refreshDateTime();
                                });
                              }),
                            ),
                            SizedBox(width: 10),
                            Text('x ${'1day'.tr}', style: DialogDescBoldStyle(context)),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextCheckBox(context,
                          'Show recommend'.tr,
                          showStatus == 1,
                          isExpanded: false,
                          textSpace: 20.0,
                          textColor: Theme.of(context).primaryColor,
                          onChanged: (status) {
                            setState(() {
                              showStatus = status ? 1 : 0;
                            });
                        }),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: descTextController,
                          decoration: inputLabel(context, 'Description'.tr, ''),
                          maxLines: 3,
                          onChanged: (text) {
                            descText = descTextController.text;
                          },
                        ),
                      ],
                    );
                  }
                )
              )
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'.tr, style: ItemTitleExStyle(context)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'.tr, style: ItemTitleStyle(context)),
              onPressed: () {
                startDate = DateTime(startDate!.year, startDate!.month, startDate!.day, 0, 0, 0, 0, 0);
                endDate   = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 0, 0);
                var addItem = RecommendModel.createEvent(
                  event, AppData.userInfo, showStatus, creditCount, startDate!, endDate, descText);
                Navigator.of(context).pop(addItem);
              },
            ),
          ],
        )
      );
    },
  );
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

Future<JSON?> showEditCommentDialog(BuildContext context, CommentType type, String title,
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
    jsonData['picData'] = _imageData.entries.map((e) => e.value['url']).toList();
  }

  refreshGallery() {
    var gallery = _imageGalleryKey.currentState as CardScrollViewerState;
    gallery.refresh();
    refreshImage();
  }

  picLocalImage() async {
    List<XFile>? pickList = await ImagePicker().pickMultiImage(maxWidth: PIC_IMAGE_SIZE_MAX, maxHeight: PIC_IMAGE_SIZE_MAX);
    if (pickList.isNotEmpty) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var imageUrl = await ShowImageCroper(image.path);
        var imageData = await ReadFileByte(imageUrl);
        var key = Uuid().v1();
        _imageData[key] = {'id': key, 'data': imageData};
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
    if (jsonData['picData'] != null) {
      _imageData = {};
      for (var item in jsonData['picData']) {
        var key = Uuid().v1();
        _imageData[key] = JSON.from(jsonDecode('{"id": "$key", "url": "$item"}'));
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
                      SizedBox(height: 10),
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
                        showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, 'Alert) Recovery is not possible'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
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
                              default:
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
                      Navigator.pop(_context);
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
                              _imageData[item.key]['url'] = result;
                              upCount++;
                            }
                          }
                          LOG('---> upload upCount : $upCount');
                          if (type == CommentType.comment) jsonData['vote'] = _voteNow;
                          jsonData['desc'] = _descText;
                          jsonData['picData'] = [];
                          for (var item in _imageData.entries) {
                            if (item.value['url'] != null) jsonData['picData'].add(item.value['url']);
                          }
                          LOG('---> image upload done : ${jsonData['picData'].length} / ${targetUserInfo['id']}');
                          jsonData = TO_SERVER_DATA(jsonData);
                          LOG('---> jsonData : $jsonData');

                          var targetUserId = STR(targetUserInfo['id']);
                          LOG('---> add data : $type > $targetUserId / $targetUserInfo');
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
                            default:
                          }
                          hideLoadingDialog();
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
    jsonData['picData'] = _imageData.entries.map((e) => e.value['url']).toList();
  }

  refreshGallery() {
    var gallery = _imageGalleryKey.currentState as CardScrollViewerState;
    gallery.refresh();
    refreshImage();
  }

  picLocalImage() async {
    List<XFile>? pickList = await ImagePicker().pickMultiImage(maxWidth: PIC_IMAGE_SIZE_MAX, maxHeight: PIC_IMAGE_SIZE_MAX);
    if (pickList != null) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var imageUrl = await ShowImageCroper(image.path);
        var imageData = await ReadFileByte(imageUrl);
        var key = Uuid().v1();
        _imageData[key] = {'id': key, 'data': imageData};
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
    if (jsonData['picData'] != null) {
      _imageData = {};
      for (var item in jsonData['picData']) {
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
                          showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, 'Alert) Recovery is not possible'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
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
                                default:
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
                                  _imageData[item.key]['url'] = result;
                                  upCount++;
                                }
                              }
                              LOG('---> upload upCount : $upCount');
                              if (type == CommentType.comment) jsonData['vote'] = _voteNow;
                              jsonData['desc'] = _descText;
                              jsonData['picData'] = [];
                              for (var item in _imageData.entries) {
                                if (item.value['url'] != null) jsonData['picData'].add(item.value['url']);
                              }
                              LOG('---> image upload done : ${jsonData['picData'].length} / $upCount');
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
                                  default:
                                }
                              }
                              hideLoadingDialog();
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

ThemeData getThemeData(bool mode, int index) {
  // LOG("--> getThemeData : $mode / $index");
  return mode ? FlexThemeData.light(
    scheme: schemeList[index],
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 20,
    appBarOpacity: 0.95,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      blendOnColors: false,
    ),
    keyColors: const FlexKeyColors(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.notoSans().fontFamily,
    textTheme: GoogleFonts.notoSansTextTheme(),
  ) : FlexThemeData.dark(
    scheme: schemeList[index],
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 15,
    appBarStyle: FlexAppBarStyle.surface,
    appBarOpacity: 0.90,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 30,
    ),
    keyColors: const FlexKeyColors(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.notoSans().fontFamily,
    textTheme: GoogleFonts.notoSansTextTheme(),
  );
}

showThemeSelectorDialog(BuildContext context, String title, bool themeMode, int themeIndex) async {
  var _themeColor = '';
  return await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: DialogTitleStyle(context)),
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          insetPadding: EdgeInsets.all(10),
          backgroundColor: DialogBackColor(context),
          content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: Get.width * 0.85,
                  height: Get.width,
                  child: GridView.builder(
                      itemCount: schemeList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6, //1 개의 행에 보여줄 item 개수
                        mainAxisSpacing: 2, //수평 Padding
                        crossAxisSpacing: 2, //수직 Padding
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var _theme = getThemeData(themeMode, index);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              themeIndex = index;
                              _themeColor = COL2STR(_theme.primaryColor);
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                  color: themeIndex == index ? Theme.of(context).colorScheme.inverseSurface : Colors.transparent,
                                  width: 4.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Container(
                                                color: _theme.colorScheme.primary,
                                              )
                                          ),
                                          Expanded(
                                              child: Container(
                                                color: _theme.colorScheme.primaryContainer,
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Container(
                                                color: _theme.colorScheme.secondary,
                                              )
                                          ),
                                          Expanded(
                                              child: Container(
                                                color: _theme.cardColor,
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  Expanded(
                                      child: Text(schemeShotTextList[index], style: ItemDescExStyle(context), maxLines: 1)
                                  )
                                ],
                              )
                          ),
                        );
                      }
                  ),
                );
              }
          ),
          actions: [
            TextButton(
              child: Text('Done'.tr),
              onPressed: () {
                Navigator.of(context).pop({'color': _themeColor, 'index': themeIndex});
              },
            ),
          ],
        );
      }
  );
}

Future showButtonListDialog(BuildContext context, List<Widget> buttonList)
{
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(40, 30, 40, 0),
          actionsPadding: EdgeInsets.fromLTRB(30, 0, 30, 10),
          backgroundColor: DialogBackColor(context),
          content: SingleChildScrollView(
            child: Container(
              color: Colors.transparent,
              constraints: BoxConstraints(
                maxWidth: 200,
              ),
              child: Column(
                children: [
                  ...buttonList
                ]
              )
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'.tr),
              onPressed: () {
                Navigator.pop(context, {});
              },
            ),
          ],
        ),
      );
    },
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
          title: Text(title, style: dialogTitleTextStyle(context)),
          titlePadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(10),
          backgroundColor: DialogBackColor(context),
          content: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListBody(
                    children: [
                      Text(message1, style: dialogDescTextStyle(context)),
                      if (message2.isNotEmpty)...[
                        SizedBox(height: 10),
                        Text(message2, style: dialogDescTextExStyle(context)),
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

Future<JSON?> showJsonMultiSelectDialog(BuildContext context, String title, JSON jsonData, [String okStr = 'OK']) async {
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
              title: Text(title, style: DialogTitleStyle(context)),
              insetPadding: EdgeInsets.all(10),
              contentPadding: EdgeInsets.all(20),
              actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 5),
              backgroundColor: DialogBackColor(context),
              content: Container(
                constraints: BoxConstraints(
                  minWidth: 300,
                  maxHeight: Get.height * 0.6
                ),
                child: SingleChildScrollView(
                  child: ListBody(
                    children: jsonData.entries.map((item) => Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: Theme.of(context).canvasColor.withOpacity(0.5),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.value['title'], style: DialogDescStyle(context), maxLines: 1),
                                  if (item.value['desc'] != null)...[
                                    SizedBox(height: 2),
                                    Text(item.value['desc'], style: DialogDescExStyle(context), maxLines: 1),
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
                        child: Text('Cancel'.tr, style: ItemTitleExStyle(context)),
                        onPressed: () {
                          Navigator.pop(_context);
                        },
                      ),
                      TextButton(
                        child: Text(okStr.tr, style: ItemTitleAlertStyle(context)),
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
  );
}

enum ReportType {
  normal,
  report,
  ownership,
}

showReportDialog(BuildContext context, ReportType type, String title, String targetType,
    JSON targetData, {JSON jsonOrgData = const {}, String subTitle = ''}) async {
  final api   = Get.find<ApiService>();
  final cache = Get.find<CacheService>();

  final _editController   = TextEditingController();
  final _editControllerEx = TextEditingController();
  final _imageGalleryKey = GlobalKey();

  JSON _imageData = {};
  JSON _jsonData = {};
  var _descText = '';
  var _isChanged = false;
  var isBlockUser = true;

  refreshImage() {
    _jsonData['imageData'] = _imageData.entries.map((e) => e.value['url']).toList();
  }

  refreshGallery() {
    var gallery = _imageGalleryKey.currentState as CardScrollViewerState;
    gallery.refresh();
    refreshImage();
  }

  picLocalImage() async {
    List<XFile>? pickList = await ImagePicker().pickMultiImage(maxWidth: PIC_IMAGE_SIZE_MAX, maxHeight: PIC_IMAGE_SIZE_MAX);
    if (pickList.isNotEmpty) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var imageUrl = await ShowImageCroper(image.path);
        var imageData = await ReadFileByte(imageUrl);
        var key = Uuid().v1();
        _imageData[key] = {'id': key, 'data': imageData};
      }
      refreshGallery();
    }
  }

  initData() {
    if (_jsonData['imageData'] != null) {
      _imageData = {};
      for (var item in _jsonData['imageData']) {
        var key = Uuid().v1();
        _imageData[key] = JSON.from(jsonDecode('{"id": "$key", "url": "$item"}'));
      }
    }
    _editController.text    = STR(_jsonData['desc']);
    _editControllerEx.text  = STR(_jsonData['descOrg']);
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
                  title: Text(title.tr, style: DialogTitleStyle(context)),
                  // titleTextStyle: type == CommentType.message ? _titleText2 : _titleText,
                  insetPadding: EdgeInsets.all(15),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  // backgroundColor: Colors.white,
                  backgroundColor: DialogBackColor(context),
                  content: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageEditScrollViewer(
                              _imageData,
                              key: _imageGalleryKey,
                              title: 'IMAGE SELECT'.tr,
                              isEditable: true,
                              itemWidth: 80,
                              itemHeight: 80,
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
                          SizedBox(height: 10),
                          if (STR(_jsonData['descOrg']).isNotEmpty)...[
                            TextFormField(
                              controller: _editControllerEx,
                              decoration: inputLabel(context, '', ''),
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              maxLength: COMMENT_LENGTH,
                              enabled: false,
                              // style: _editText,
                              onChanged: (value) {
                                setState(() {
                                  _descText = value;
                                  _isChanged = true;
                                });
                              },
                            ),
                            SizedBox(height: 10),
                          ],
                          if (subTitle.isNotEmpty)...[
                            SubTitle(context, subTitle),
                            SizedBox(height: 5),
                          ],
                          TextFormField(
                            controller: _editController,
                            decoration: inputLabel(context, 'Description'.tr, ''),
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            maxLength: COMMENT_LENGTH,
                            // style: _editText,
                            onChanged: (value) {
                              setState(() {
                                _descText = value;
                                _isChanged = true;
                              });
                            },
                          ),
                          if (targetType == 'user')...[
                            Row(
                              children: [
                                Checkbox(value: isBlockUser, onChanged: (value) {
                                  setState(() {
                                    isBlockUser = value ?? false;
                                  });
                                }),
                                Text('To black'.tr, style: ItemTitleAlertStyle(context)),
                              ],
                            )
                          ]
                        ],
                      )
                  ),
                  actions: [
                    TextButton(
                      child: Text('Cancel'.tr, style: ItemTitleExStyle(context)),
                      onPressed: () {
                        Navigator.pop(_context, {});
                      },
                    ),
                    TextButton(
                        child: Text('OK'.tr, style: ItemTitleStyle(context)),
                        onPressed: () {
                          if (type == ReportType.ownership && _imageData.isEmpty) {
                            showAlertDialog(context, 'Error'.tr, 'Please select one or more images'.tr, '', 'OK'.tr);
                            return;
                          }
                          showAlertYesNoDialog(context, 'Report'.tr, 'Would you like to send a report?'.tr,
                              '', 'Cancel'.tr, 'OK'.tr).then((value) {
                            if (value == 0) return;
                            int upCount = 0;
                            showLoadingDialog(context, 'uploading now...'.tr);
                            Future.delayed(Duration(milliseconds: 200), () async {
                              for (var item in _imageData.entries) {
                                var result = await api.uploadImageData(item.value as JSON, 'report_img');
                                if (result != null) {
                                  _imageData[item.key]['url'] = result;
                                  upCount++;
                                }
                              }
                              LOG('---> upload upCount : $upCount');
                              _jsonData['userId'      ] = AppData.USER_ID;
                              _jsonData['type'        ] = type == ReportType.report ? 'report' : 'owner';
                              _jsonData['targetType'  ] = targetType;
                              _jsonData['targetId'    ] = STR(targetData['id']);
                              _jsonData['targetTitle' ] = STR(targetData['title'] ?? targetData['desc'] ?? targetData['nickName']);
                              _jsonData['desc'        ] = _descText;
                              _jsonData['replayType'  ] = 'ready';
                              _jsonData['replayName'  ] = '';
                              _jsonData['replayDesc'  ] = '';
                              _jsonData['replayTime'  ] = '';
                              _jsonData['imageData'   ] = [];
                              _jsonData['pic'         ] = '';
                              for (var item in _imageData.entries) {
                                if (item.value['url'] != null) {
                                  _jsonData['imageData'].add(item.value['url']);
                                  if (STR(_jsonData['pic']).isEmpty) _jsonData['pic'] = item.value['url'];
                                }
                              }
                              var result = await api.addReportItemEx(_jsonData);
                              if (isBlockUser && result != null) {
                                result['blockUser'] = true;
                              }
                              hideLoadingDialog();
                              Future.delayed(Duration(milliseconds: 200), () async {
                                Navigator.pop(_context, result);
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

showNoticeEditDialog(BuildContext context, String title, JSON noticeData) async {
  final _editController  = TextEditingController();
  final fileSelectKey = GlobalKey();
  JSON fileData = {};
  var isFirst = false;
  var descStr = '';

  initData() {
    fileData = {};
    if (noticeData['fileData'] != null) {
      for (var item in noticeData['fileData']) {
        fileData[item['id']] = item;
      }
    }
    descStr = STR(noticeData['desc']);
    _editController.text = descStr;
  }

  refreshGallery() {
    var gallery = fileSelectKey.currentState as CardScrollViewerState;
    gallery.refresh();
  }

  picLocalFiles() async {
    if (!AppData.isMainActive) return false;
    AppData.isMainActive = false;
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      try {
        for (var item in result.files) {
          var createItem = UploadFileModel(
            id: Uuid().v4(),
            status: 1,
            name: item.name,
            size: item.size,
            extension: item.extension ?? '',
            thumb: '',
            url: '',
            path: item.path,
          );
          var addItem = createItem.toJson();
          if (IS_IMAGE_FILE(createItem.extension) && item.path != null) {
            var data = await ReadFileByte(item.path!);
            if (data != null) {
              var thumbData = await resizeImage(data, 128) as Uint8List;
              addItem['data'] = data;
              addItem['thumbData'] = thumbData;
              addItem['upStatue'] = 1;
            }
          } else {
            addItem['url'] = FILE_ICON(createItem.extension);
            addItem['thumb'] = addItem['url'];
            addItem['upStatue'] = 1;
          }
          fileData[createItem.id] = addItem;
          // LOG('--> uploadFileData addItem : ${addItem.toString()}');
        }
      } catch (e) {
        LOG('--> uploadFileData error : $e');
      }
    }
    AppData.isMainActive = true;
    return true;
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
                title: Text(title.tr, style: DialogTitleStyle(context)),
                insetPadding: EdgeInsets.symmetric(horizontal: 15),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                actionsPadding: EdgeInsets.fromLTRB(15, 0, 15, 5),
                backgroundColor: DialogBackColor(context),
                content: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ImageEditScrollViewer(
                        fileData,
                        key: fileSelectKey,
                        title: 'File Select'.tr,
                        isEditable: true,
                        itemWidth: 60,
                        itemHeight: 60,
                        onActionCallback: (key, status) {
                          switch (status) {
                            case 1: {
                              picLocalFiles().then((_) {
                                setState(() {});
                              });
                              break;
                            }
                            case 2: {
                              setState(() {
                                fileData.remove(key);
                                refreshGallery();
                              });
                              break;
                            }
                          }
                        }
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _editController,
                        decoration: inputLabel(context, 'Description'.tr, ''),
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        maxLength: COMMENT_LENGTH,
                        style: TextStyle(fontSize: 14),
                        onChanged: (value) {
                          descStr = value;
                          LOG('--> desc : $value');
                        },
                      ),
                      Row(
                        children: [
                          Checkbox(value: isFirst, onChanged: (value) {
                            setState(() {
                              isFirst = !isFirst;
                            });
                          }),
                          Text('Display this notice at the top'.tr)
                        ],
                      )
                    ],
                  )
              ),
              actions: [
                if (STR(noticeData['id']).isNotEmpty)
                  TextButton(
                    child: Text('Delete'.tr, style: ItemTitleExStyle(context)),
                    onPressed: () {
                      noticeData['status'] = 0;
                      Navigator.pop(_context, noticeData);
                    },
                  ),
                TextButton(
                  child: Text('Cancel'.tr, style: ItemTitleExStyle(context)),
                  onPressed: () {
                    Navigator.pop(_context);
                  },
                ),
                TextButton(
                  child: Text('OK'.tr, style: ItemTitleStyle(context)),
                  onPressed: () {
                    if (descStr.isEmpty) return;
                    noticeData['desc'     ] = descStr;
                    noticeData['isFirst'  ] = isFirst;
                    noticeData['fileData' ] = fileData.entries.map((e) => e.value).toList();
                    Navigator.pop(_context, noticeData);
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

showReportMenu(BuildContext context, JSON targetInfo, String type, {List<JSON> menuList = const [
  {'id':'report', 'title':'Report content'},
  {'id':'ownership', 'title':'Change to Ownership'},
]}) {
  final cache = Get.find<CacheService>();
  
  showJsonButtonSelectDialog(context, 'Report type'.tr, menuList).then((result) {
    var targetId = STR(targetInfo['id']);
    switch (result) {
      case 'report':
        if (JSON_NOT_EMPTY(cache.reportData['report']) && cache.reportData['report'].containsKey(targetId)) {
          showAlertDialog(context, TR(menuList[0]['title']), 'Already reported'.tr, '', 'OK'.tr);
        } else {
          showReportDialog(context, ReportType.report,
              TR(menuList[0]['title']), type, targetInfo, subTitle: 'Please write what you want to report'.tr).then((result) async {
            if (result.isNotEmpty) {
              showAlertDialog(context, TR(menuList[0]['title']), 'Report has been completed'.tr, '', 'OK'.tr);
            }
          });
        }
        break;
      case 'ownership':
        if (JSON_NOT_EMPTY(cache.reportData['owner']) && cache.reportData['owner'].containsKey(targetId)) {
          showAlertDialog(context, TR(menuList[1]['title']), 'Already reported'.tr, '', 'OK'.tr);
        } else {
          showReportDialog(context, ReportType.ownership,
              TR(menuList[1]['title']), type, targetInfo, subTitle: 'Please add supporting documents'.tr).then((result) async {
            if (result.isNotEmpty) {
              showAlertDialog(context, TR(menuList[1]['title']), 'Report has been completed'.tr, '', 'OK'.tr);
            }
          });
        }
        break;
    }
  });
}

showChattingMenu(BuildContext context, {List<JSON> menuList = const [
  {'id':'public'  , 'title':'Public chat', 'desc': '',},
  {'id':'private' , 'title':'Private chat'},
  {'id':'message' , 'title':'1:1 Message send'},
]}) async {
  return await showJsonButtonSelectExDialog(context, 'Chatting type'.tr, menuList, null, itemHeight: 60.0);
}

Future<String> showJsonButtonSelectDialog(BuildContext context, String title, List<JSON> jsonData) async {
  return await showJsonButtonSelectExDialog(context, title, jsonData, null);
}

Future<String> showJsonButtonSelectExDialog(BuildContext context, String title, List<JSON> jsonData, List<JSON>? exButton, {var itemHeight = 70.0}) async {
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
                        maxHeight: jsonData.length * (itemHeight + 10) + 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: jsonData.map((item) =>
                            Container(
                              height: itemHeight,
                              width: double.infinity,
                              margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!BOL(item['disabled'])) {
                                    Navigator.pop(_context, item['id']);
                                  }
                                },
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
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (item['icon'] != null)...[
                                        if (item['icon'] == 'video')
                                          Icon(Icons.movie_creation_outlined, size: itemHeight * 0.5, color: Theme.of(context).primaryColor),
                                        if (item['icon'] == 'image')
                                          Icon(Icons.photo_size_select_actual_outlined, size: itemHeight * 0.5, color: Theme.of(context).primaryColor),
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
                          Navigator.pop(_context);
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

showLoadingToast(BuildContext context) {
  dialogContext = context;
  showCupertinoDialog(context: dialogContext!,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 60.w,
          height: 60.w,
          child: showLoadingCircleSquare(30.sp),
        ),
      );
    }
  );
}