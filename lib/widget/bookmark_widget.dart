
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';

Widget BookmarkSmallWidget(BuildContext context, String type, JSON targetInfo,
    {double iconSize = 18, String title = '', Function(JSON)? onChangeCount}) {
  return BookmarkWidget(context, type, targetInfo, iconSize: iconSize, title: title, onChangeCount: onChangeCount);
}

Widget BookmarkWidget(BuildContext context, String type, JSON targetInfo,
    {
      double iconSize = 20,
      String title = '',
      bool isEnabled = true,
      bool isShowOutline = false,
      double iconX = 0,
      double iconY = 0,
      Color? enableColor,
      Color? disableColor,
      EdgeInsets? padding,
      Function(JSON)? onChangeCount
    }) {
  var iconColor0 = enableColor  ?? Theme.of(context).primaryColor;
  var iconColor1 = disableColor ?? Theme.of(context).disabledColor;
  var api = Get.find<ApiService>();

  return FutureBuilder(
      future: api.getBookmarkJsonFromTargetId(AppData.userInfo.id, type, targetInfo['id']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var itemInfo = snapshot.data as JSON;
          var isChecked = JSON_NOT_EMPTY(itemInfo);
          return StatefulBuilder(
            builder: (context, setState) {
              var targetPic = STR(targetInfo['pic']);
              // LOG('--> ShowLikeWidget imageData [$type] : ${targetInfo['picData']}');
              if (targetPic.isEmpty && LIST_NOT_EMPTY(targetInfo['picData'])) {
                targetPic = STR(targetInfo['picData'].first is JSON ? targetInfo['picData'].first['url'] : targetInfo['picData'].first);
              }
              var targetTitle = type == 'story' ? STR(targetInfo['desc']) : type == 'user' ? STR(targetInfo['nickName']) : STR(targetInfo['title']);
              LOG('--> BookmarkWidget isOn [$targetTitle] : $isChecked / ${targetInfo['likeCount']}');
              return GestureDetector(
                child: Container(
                    width:  iconSize + 15,
                    color: Colors.transparent,
                    padding: padding,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isShowOutline)
                            OutlineIcon(isChecked ? Icons.bookmark : Icons.bookmark_border_outlined, iconSize.sp, isChecked ? iconColor0 : iconColor1, x: iconX, y: iconY),
                          if (!isShowOutline)
                            Icon(isChecked ? Icons.bookmark : Icons.bookmark_border_outlined, size: iconSize.sp, color: isChecked ? iconColor0 : iconColor1),
                          if (title.isNotEmpty)...[
                            Text(title, style: ItemDescExStyle(context))
                          ],
                        ]
                    )
                ),
                onTap: () {
                  if (!isEnabled) return;
                  isChecked = !isChecked;
                  api.addBookmarkItem(AppData.USER_ID, type, STR(targetInfo['id']), isChecked ? 1 : 0,
                    targetTitle: targetTitle, targetPic: targetPic).then((result) {
                      LOG('--> addBookmarkItem result [$isChecked] : $result');
                      if (result != null) {
                        setState(() {
                        targetInfo = result;
                        if (onChangeCount != null) onChangeCount(targetInfo);
                        });
                      }
                  });
                },
              );
            }
          );
        } else {
          return SizedBox(
            width: iconSize + 15,
            child: Center(
              child: showLoadingCircleSquare(20),
            )
          );
        }
      }
  );
}
