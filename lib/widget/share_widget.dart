
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../data/theme_manager.dart';
import '../services/firebase_service.dart';
import '../utils/utils.dart';

Widget ShareSmallWidget(BuildContext context, String type, JSON targetInfo,
    {double iconSize = 20, String title = 'SHARE', Function(int)? onChangeCount}) {
  return ShareWidget(context, type, targetInfo, iconSize: iconSize, title: title, showTitle: false);
}

Widget ShareWidget(BuildContext context, String type, JSON targetInfo,
    {double iconSize = 24, String title = 'SHARE', bool showTitle = false, Function(int)? onChangeCount}) {
  var _iconColor0 = Theme.of(context).primaryColor;
  return StatefulBuilder(
      builder: (context, setState) {
        return Center(
            child:  GestureDetector(
              onTap: () {
                createShareContentDynamicLink(type, targetInfo['id']).then((result) {
                  var targetTitle = type == 'story' ? STR(targetInfo['desc']) : STR(targetInfo['title']);
                  Share.share(result, subject: 'KSpot - $targetTitle');
                  // addShareCount(type, STR(targetInfo['id']), 1, targetTitle: targetTitle, targetPic: '').then((result) async {
                  //   setState(() {
                  //     LOG('--> ShowShareWidget result : $result');
                  //     targetInfo = result;
                  //     if (onChangeCount != null) onChangeCount(INT(result['bookmarks']));
                  //   });
                  // });
                });
              },
              child: Container(
                width:  40,
                height: 40,
                color: Colors.transparent,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.share, color: _iconColor0 , size: iconSize),
                      // if (showCount)
                      //   Text(' ', style: ItemDescExStyle(context)),
                      if (title.isNotEmpty && showTitle)
                        Text(title.tr, style: ItemDescExStyle(context)),
                      // Text('${INT(targetInfo['shares'])}', style: ItemDescExStyle(context)),
                    ]
                ),
              ),
            )
        );
      }
  );
}