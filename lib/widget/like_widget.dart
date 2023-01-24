
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';

Widget LikeSmallWidget(BuildContext context, String type, JSON targetInfo,
    {double iconSize = 20, String title = '', Function(int)? onChangeCount}) {
  return LikeWidget(context, type, targetInfo, iconSize: iconSize, title: title, showCount: false, onChangeCount: onChangeCount);
}

Widget LikeWidget(BuildContext context, String type, JSON targetInfo,
    {
      double iconSize = 24,
      String title = '',
      bool showCount = false,
      bool isEnabled = true,
      Function(int)? onChangeCount
    }) {
  var _iconColor0 = Theme.of(context).primaryColor;
  var _iconColor1 = Theme.of(context).primaryColor.withOpacity(0.85);
  var api = Get.find<ApiService>();

  return FutureBuilder(
      future: api.getLikeFromTargetId(AppData.userInfo.toJson(), type, targetInfo['id']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var _isLiked = snapshot.data as bool;
          return StatefulBuilder(
              builder: (context, setState) {
                var _pic = STR(targetInfo['pic']);
                // LOG('--> ShowLikeWidget imageData [$type] : ${targetInfo['imageData']}');
                if (type == 'story' && LIST_NOT_EMPTY(targetInfo['imageData'])) {
                  _pic = STR(targetInfo['imageData'].first is JSON ? targetInfo['imageData'].first['backPic'] : targetInfo['imageData'].first);
                }
                var _title = type == 'story' ? STR(targetInfo['desc']) : type == 'user' ? STR(targetInfo['nickName']) : STR(targetInfo['title']);
                // LOG('--> ShowLikeWidget isOn [$_title] : $_isLiked');
                return GestureDetector(
                  child: Container(
                      width:  35,
                      color: Colors.transparent,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? _iconColor0 : _iconColor1, size: iconSize),
                            if (showCount)
                              Text('${INT(targetInfo['likes'])}', style: ItemDescExStyle(context)),
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
                        // targetInfo = result;
                        // if (onChangeCount != null) onChangeCount(INT(result['likes']));
                      });
                    });
                  },
                );
              }
          );
        } else {
          return showLoadingImageSquare(20);
        }
      }
  );
}
