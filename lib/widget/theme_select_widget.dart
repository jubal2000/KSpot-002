import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';

Widget ThemeSelectWidget(bool themeMode, int themeIndex, String title, Function(bool, int, String)? onChanged) {
  var _themeColor = '';
  LOG('--> ThemeSelectWidget : $themeMode, $themeIndex');
  return StatefulBuilder(
    builder: (context, setState) {
      return Theme(
        data: getThemeData(themeMode, themeIndex),
        child: GestureDetector(
          onTap: () {
            showThemeSelectorDialog(context, 'Theme select'.tr, themeMode, themeIndex).then((result) {
              setState(() {
                themeIndex = INT(result['index']);
                _themeColor = STR(result['color']);
                if (onChanged != null) onChanged(themeMode, themeIndex, _themeColor);
              });
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  child: Text(title, style: ItemTitleLargeStyle(context)),
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: getThemeData(themeMode, themeIndex).primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: getThemeData(themeMode, themeIndex).canvasColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Row(
                      children: [
                        Switch(
                            value: themeMode,
                            onChanged: (status) {
                              setState(() {
                                themeMode = !themeMode;
                                if (onChanged != null) onChanged(themeMode, themeIndex, _themeColor);
                              });
                            }
                        ),
                        Text(themeMode ? 'LIGHT'.tr : 'DARK'.tr, style: ItemTitleStyle(context)),
                      ],
                    ),
                    SizedBox(width: 5),
                    Text(schemeTextList[themeIndex].toUpperCase(), style: ItemTitleStyle(context)),
                  ]
                )
              ]
            )
          )
        )
      );
    }
  );
}