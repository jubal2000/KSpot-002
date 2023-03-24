
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';

Widget CreditWidget(BuildContext context, JSON userInfo,
    {
      double iconSize = 24,
      String title = '',
      bool isEnabled = true,
      bool isShowOutline = false,
      double iconX = 0,
      double iconY = 0,
      Color? enableColor,
      Color? disableColor,
      EdgeInsets? padding,
      Function(JSON)? onChanged
    }) {
  var iconColor0 = enableColor ?? Theme.of(context).primaryColor;
  var api = Get.find<ApiService>();

  return GestureDetector(
    child: Container(
      width:  iconSize + 15,
      color: Colors.transparent,
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isShowOutline)
            ShadowIcon(Icons.recommend_outlined, iconSize, iconColor0, x: iconX, y: iconY),
          if (!isShowOutline)
            Icon(Icons.recommend_outlined, size: iconSize, color: iconColor0),
          if (title.isEmpty)...[
            Text('${INT(userInfo['creditCount'])}', style: ItemDescExStyle(context))
          ],
          if (title.isNotEmpty)...[
            Text(title, style: ItemDescExStyle(context))
          ],
        ]
      )
    ),
    onTap: () {
    }
  );
}
