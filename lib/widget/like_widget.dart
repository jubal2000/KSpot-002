
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';

Widget LikeSmallWidget(BuildContext context, String type, JSON targetInfo,
    {double iconSize = 18, String title = '', Function(int)? onChangeCount}) {
  return LikeWidget(context, type, targetInfo, iconSize: iconSize, title: title, showCount: false, onChangeCount: onChangeCount);
}

Widget LikeWidget(BuildContext context, String type, JSON targetInfo,
    {
      double iconSize = 24,
      String title = '',
      bool showCount = false,
      bool isEnabled = true,
      bool isShowOutline = false,
      double iconX = 0,
      double iconY = 0,
      Color? enableColor,
      Color? disableColor,
      EdgeInsets? padding,
      Function(int)? onChangeCount
    }) {
  var iconColor0 = enableColor ?? Theme.of(context).colorScheme.error;
  var iconColor1 = disableColor ?? Theme.of(context).colorScheme.error;
  var api = Get.find<ApiService>();

  return FutureBuilder(
      future: api.getLikeJsonFromTargetId(AppData.userInfo.id, type, targetInfo['id']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var likeInfo = snapshot.data as JSON;
          var _isLiked = JSON_NOT_EMPTY(likeInfo);
          return StatefulBuilder(
            builder: (context, setState) {
              var _pic = STR(targetInfo['pic']);
              // LOG('--> ShowLikeWidget imageData [$type] : ${targetInfo['picData']}');
              if (_pic.isEmpty && LIST_NOT_EMPTY(targetInfo['picData'])) {
                _pic = STR(targetInfo['picData'].first is JSON ? targetInfo['picData'].first['url'] : targetInfo['picData'].first);
              }
              var _title = type == 'story' ? STR(targetInfo['desc']) : type == 'user' ? STR(targetInfo['nickName']) : STR(targetInfo['title']);
              LOG('--> ShowLikeWidget isOn [$_title] : $_isLiked / ${targetInfo['likeCount']}');
              return GestureDetector(
                child: Container(
                    width:  iconSize.sp + 15,
                    color: Colors.transparent,
                    padding: padding,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isShowOutline)
                            OutlineIcon(_isLiked ? Icons.favorite : Icons.favorite_border, iconSize.sp, _isLiked ? iconColor0 : iconColor1, x: iconX, y: iconY),
                          if (!isShowOutline)
                            Icon(_isLiked ? Icons.favorite : Icons.favorite_border, size: iconSize.sp, color: _isLiked ? iconColor0 : iconColor1),
                          if (showCount)
                            Text('${INT(targetInfo['likeCount'])}', style: ItemDescExStyle(context)),
                          if (title.isNotEmpty)...[
                            Text(title, style: ItemDescExStyle(context))
                          ],
                        ]
                    )
                ),
                onTap: () {
                  if (!isEnabled) return;
                  _isLiked = !_isLiked;
                  api.addLikeCount(AppData.userInfo.toJson(), type, targetInfo['id'], _isLiked ? 1 : 0, targetTitle: _title, targetPic: _pic).then((result) {
                    setState(() {
                      LOG('--> ShowLikeWidget result [$_isLiked] : $result');
                      if (result != null) {
                        targetInfo = result;
                        if (onChangeCount != null) onChangeCount(INT(result['likeCount']));
                      }
                    });
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
