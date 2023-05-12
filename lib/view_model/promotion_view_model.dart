
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/utils/utils.dart';

import '../data/app_data.dart';
import '../view/promotion/promotion_item.dart';

class PromotionViewModel extends ChangeNotifier {
  bool isSelect = false;

  onItemSelect(JSON item) {
    LOG('--> promotion item select : ${item['id']}');
  }

  showPromotionList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
      child: ListView(
        shrinkWrap: true,
        children: [
          ...AppData.INFO_PROMOTION.entries.map((e) => PromotionItem(
            e.value,
            onSelect: onItemSelect
          ))
        ],
      )
    );
  }
}