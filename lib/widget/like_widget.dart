
import 'package:flutter/material.dart';
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
      EdgeInsets? padding,
      Function(int)? onChangeCount
    }) {
  var _iconColor0 = Theme.of(context).colorScheme.error;
  var _iconColor1 = Theme.of(context).colorScheme.error.withOpacity(0.85);
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
                    width:  iconSize + 15,
                    color: Colors.transparent,
                    padding: padding,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isShowOutline)
                            ShadowIcon(_isLiked ? Icons.favorite : Icons.favorite_border, iconSize, _isLiked ? _iconColor0 : _iconColor1, x: iconX, y: iconY),
                          if (!isShowOutline)
                            Icon(_isLiked ? Icons.favorite : Icons.favorite_border, size: iconSize, color: _isLiked ? _iconColor0 : _iconColor1),
                          if (showCount)
                            Text('${INT(targetInfo['likeCount'])}', style: ItemDescExStyle(context)),
                          if (title.isNotEmpty)...[
                            Text(title, style: TextStyle(fontSize: 9, color: _isLiked ? _iconColor0 : _iconColor1))
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
