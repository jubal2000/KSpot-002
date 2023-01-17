import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/common_colors.dart';
import '../data/common_sizes.dart';
import '../utils/utils.dart';

const Color THEME_KAKAO_TEXT_COLOR = Color(0xFF191919);
const Color THEME_KAKAO_BG_COLOR = Color(0xFFFFE812);

const Color THEME_PHONE_ICON_COLOR = Color(0xFF28272B);
const Color THEME_PHONE_BG_COLOR = Color(0xFF848484);

const Color THEME_PRIMARY_COLOR = NAVY;
const Color THEME_ERROR_COLOR = Color(0xFFFF1111);
const Color THEME_ERROR_BG_COLOR = Color(0x33FF1111);

class RoundedButton extends RoundedButtonNormal {
  const RoundedButton.normal(
  String label,
  {
    Key? key,
    VoidCallback? onPressed,
    Color textColor = Colors.black,
    Color backgroundColor = Colors.white,
    Color borderColor = Colors.transparent,
    bool fullWidth = true,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20),
    double? fontSize = UI_FONT_SIZE_M,
    double height = 48,
    double radius = 48,
    double minWidth = 50,
  }) : super(
      key: key,
      onPressed: onPressed,
      label: label,
      textColor: textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      fullWidth: fullWidth,
      padding: padding,
      fontSize: fontSize,
      height: height,
      radius: radius,
      minWidth: minWidth,
  );

  const RoundedButton.active(
      String label,
      {
        Key? key,
        VoidCallback? onPressed,
        Color textColor = Colors.black,
        Color backgroundColor = Colors.white,
        Color borderColor = Colors.transparent,
        bool fullWidth = true,
        EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20),
        double? fontSize = UI_FONT_SIZE_M,
        double height = 48,
        double radius = 48,
        double minWidth = 50,
      }) : super(
      key: key,
      onPressed: onPressed,
      label: label,
      textColor: textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      fullWidth: fullWidth,
      padding: padding,
      fontSize: fontSize,
      height: height,
      radius: radius,
      minWidth: minWidth,
  );

  const RoundedButton.disable(
  String label,
  {
    Key? key,
    VoidCallback? onPressed,
    Color textColor = Colors.white,
    Color backgroundColor = Colors.black45,
    Color borderColor = Colors.transparent,
    bool fullWidth = true,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20),
    double? fontSize = UI_FONT_SIZE_M,
    double height = 48,
    double radius = 48,
    double minWidth = 50,
  }) : super(
      key: key,
      onPressed: onPressed,
      label: label,
      textColor: textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      fullWidth: fullWidth,
      padding: padding,
      fontSize: fontSize,
      height: height,
      radius: radius,
      minWidth: minWidth,
  );

  const RoundedButton.edit(
      String label,
      {
        Key? key,
        VoidCallback? onPressed,
        Color textColor = Colors.white,
        Color backgroundColor = NAVY,
        Color borderColor = Colors.transparent,
        bool fullWidth = true,
        EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5),
        double? fontSize = UI_FONT_SIZE_S,
        double height = 35,
      }) : super(
      key: key,
      onPressed: onPressed,
      label: label,
      textColor: textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      fullWidth: fullWidth,
      padding: padding,
      fontSize: fontSize,
      height: height
  );

  const RoundedButton.delete(
      String label,
      {
        Key? key,
        VoidCallback? onPressed,
        Color textColor = THEME_ERROR_COLOR,
        Color backgroundColor = THEME_ERROR_BG_COLOR,
        Color borderColor = Colors.transparent,
        bool fullWidth = true,
        EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5),
        double? fontSize = UI_FONT_SIZE_S,
        double height = 35,
      }) : super(
      key: key,
      onPressed: onPressed,
      label: label,
      textColor: textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      fullWidth: fullWidth,
      padding: padding,
      fontSize: fontSize,
      height: height
  );

  RoundedButton.kakao(
      String label,
      {
        Key? key,
        VoidCallback? onPressed,
        Color textColor = THEME_KAKAO_TEXT_COLOR,
        Color backgroundColor = THEME_KAKAO_BG_COLOR,
        Color borderColor = Colors.transparent,
        bool fullWidth = true,
        double? fontSize = UI_FONT_SIZE_S,
        double height = 35
      }) : super(
      key: key,
      onPressed: onPressed,
      label: label,
      textColor: textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      fullWidth: fullWidth,
      padding: EdgeInsets.zero,
      fontSize: fontSize,
      height: height,
      icon: showImage('assets/img/setting/kakao_01.png', Size(20.w, 20.w)),
  );

  RoundedButton.phoneCall(
      String label,
      {
        Key? key,
        VoidCallback? onPressed,
        Color textColor = THEME_PRIMARY_COLOR,
        Color backgroundColor = THEME_PHONE_BG_COLOR,
        Color borderColor = Colors.transparent,
        bool fullWidth = true,
        double? fontSize = UI_FONT_SIZE_S,
        double height = 35
      }) : super(
    key: key,
    onPressed: onPressed,
    label: label,
    textColor: textColor,
    backgroundColor: backgroundColor,
    borderColor: borderColor,
    fullWidth: fullWidth,
    padding: EdgeInsets.zero,
    fontSize: fontSize,
    height: height,
    icon: Icon(Icons.phone, size: 20.w, color: THEME_PHONE_ICON_COLOR),
  );

  RoundedButton.checkOn(
      String label,
      {
        Key? key,
        VoidCallback? onPressed,
      }) : super(
      key: key,
      onPressed: onPressed,
      label: label,
      textColor: Colors.black87,
      backgroundColor: Colors.white,
      borderColor: Colors.transparent,
      fullWidth: false,
      padding: EdgeInsets.symmetric(horizontal: 10),
      fontSize: UI_FONT_SIZE_S,
      height: 24.h,
  );

  RoundedButton.checkOff(
      String label,
      {
        Key? key,
        VoidCallback? onPressed,
      }) : super(
      key: key,
      onPressed: onPressed,
      label: label,
      textColor: THEME_ERROR_COLOR,
      backgroundColor: THEME_ERROR_BG_COLOR,
      borderColor: Colors.transparent,
      fullWidth: false,
      padding: EdgeInsets.symmetric(horizontal: 10),
      fontSize: UI_FONT_SIZE_S,
      height: 24.h,
  );
}

class RoundedButtonNormal extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color textColor, backgroundColor, borderColor;
  final bool fullWidth;
  final EdgeInsets padding;
  final double? fontSize;
  final double height;
  final double radius;
  final double minWidth;
  final Widget? icon;
  const RoundedButtonNormal({
    Key? key,
    @required this.onPressed,
    required this.label,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.grey,
    this.borderColor = Colors.grey,
    this.fullWidth = true,
    this.height = 50.0,
    this.radius = 50.0,
    this.minWidth = 50.0,
    this.padding = const EdgeInsets.symmetric(vertical: 9, horizontal: 30),
    this.fontSize,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: fullWidth ? Container(
        width: double.infinity,
        height: height,
        padding: padding,
        alignment: Alignment.center,
        constraints: BoxConstraints(
          minWidth: minWidth,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            width: borderColor == Colors.transparent ? 0 : 2,
            color: borderColor,
          ),
          color: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)...[
              icon!,
              SizedBox(width: 2.w),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: textColor,
                fontSize: fontSize,
              )
            ),
            if (icon != null)...[
              SizedBox(width: 5.w),
            ],
          ]
        ),
      ) : FittedBox(
        fit: BoxFit.fill,
        child: Container(
          height: height,
          padding: padding,
          alignment: Alignment.center,
          constraints: BoxConstraints(
            minWidth: minWidth,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              width: borderColor == Colors.transparent ? 0 : 2,
              color: borderColor,
            ),
            color: backgroundColor,
          ),
          child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: textColor,
                fontSize: fontSize,
              )
          ),
        ),
      )
    );
  }
}
