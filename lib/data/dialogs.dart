
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../widget/image_scroll_viewer.dart';
import '../widget/main_list_item.dart';
import 'app_data.dart';
import 'common_colors.dart';
import 'utils.dart';
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

Future showImageSlideDialog(BuildContext context, List<String> imageData, int startIndex) async {
  // TextStyle _menuText   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);
  LOG('--> showImageSlideDialog : $imageData / $startIndex');

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
