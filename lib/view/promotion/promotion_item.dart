import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:kspot_002/models/promotion_model.dart';

import '../../data/style.dart';
import '../../utils/utils.dart';

Widget PromotionItem(JSON itemInfo,
  {
    itemHeight = 100.0,
    Function(JSON)? onSelect
  }) {
  LOG('--> promotion item : $itemInfo');
  return GestureDetector(
      onTap: () {
        if (onSelect != null) onSelect(itemInfo);
      },
      child: Container(
        height: itemHeight,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).cardColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (STR(itemInfo['pic']).isNotEmpty)...[
              showImageFit('assets/ui/${STR(itemInfo['pic'])}'),
              SizedBox(width: 10),
            ],
            Expanded(
             child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Get.locale.toString() == 'ko_KR')...[
                    Row(
                      children: [
                        Text(STR(itemInfo['titleKr']), style: ItemTitleStyle(Get.context!)),
                        SizedBox(width: 5),
                        Text('${INT(itemInfo['dayRange'])} ${'days'.tr}', style: ItemDescColorStyle(Get.context!, Colors.blueGrey)),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(DESC(itemInfo['descKr']), style: ItemDescStyle(Get.context!), maxLines: 3),
                  ],
                  if (Get.locale.toString() != 'ko_KR')...[
                    Text(STR(itemInfo['title']), style: ItemTitleStyle(Get.context!)),
                    SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(DESC(itemInfo['desc']), style: ItemDescStyle(Get.context!), maxLines: 3),
                    ),
                  ],
                  SizedBox(height: 5),
                  PriceRow(itemInfo['priceData']),
                ]
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 24),
          ],
        ),
      )
  );
}