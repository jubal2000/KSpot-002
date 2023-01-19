import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/common_sizes.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';

EditTextField(
    BuildContext context,
    String title,
    String text,
    { int? maxLines = 1,
      var maxLength = 99,
      var keyboardType = TextInputType.text,
      var hint = '',
      var topSpace = 0.0,
      var botSpace = 10.0,
      var isTitleShow = false,
      Function(String)? onChanged
    })
{
  final controller = TextEditingController(text: text);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: topSpace),
      if (isTitleShow)...[
        SubTitle(context, title),
        SizedBox(height: UI_ITEM_SPACE.w),
      ],
      TextFormField(
        controller: controller,
        decoration: inputLabel(context, hint, ''),
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: (value) {
          if (value == null || value.length < 2) return 'Please enter nickname'.tr;
          return null;
        },
        onChanged: onChanged,
      ),
      SizedBox(height: botSpace),
    ],
  );
}
