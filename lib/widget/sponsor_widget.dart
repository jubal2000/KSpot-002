
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';

Widget SponsorSmallWidget(BuildContext context, String type, JSON targetInfo,
    {double iconSize = 18, String title = '', Function(int)? onChangeCount}) {
  return SponsorWidget(context, type, targetInfo, iconSize: iconSize, title: title, showCount: false, onChangeCount: onChangeCount);
}

Widget SponsorWidget(BuildContext context, String type, JSON targetInfo,
    {
      double iconSize = 26,
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
  var iconColor0 = enableColor ?? Colors.yellow;
  var iconColor1 = disableColor ?? Theme.of(context).disabledColor;
  var api = Get.find<ApiService>();
  var eventDate = '${AppData.currentDate.year}-${AppData.currentDate.month}-${AppData.currentDate.day}';
  var sponCount = JSON_NOT_EMPTY(targetInfo['sponsorCount']) ? targetInfo['sponsorCount'][eventDate] : 0;

  return GestureDetector(
    child: Container(
        width:  iconSize.sp + 15,
        color: Colors.transparent,
        padding: padding,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isShowOutline)
                OutlineIcon(sponCount > 0 ? Icons.star : Icons.star_outline_rounded, iconSize.sp, sponCount > 0 ? iconColor0 : iconColor1, x: iconX, y: iconY),
              if (!isShowOutline)
                Icon(sponCount > 0 ? Icons.star : Icons.star_outline_rounded, size: iconSize.sp, color: sponCount > 0 ? iconColor0 : iconColor1),
              if (showCount)
                Text('$sponCount', style: ItemDescExStyle(context)),
              if (title.isNotEmpty)...[
                Text(title, style: ItemDescExStyle(context))
              ],
            ]
        )
    ),
    onTap: () {
      if (!isEnabled) return;

    },
  );
}
