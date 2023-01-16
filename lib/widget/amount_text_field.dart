import 'package:flutter/material.dart';
import '../data/common_colors.dart';
import '../data/common_sizes.dart';
import '../data/style.dart';

class AmountTextField extends StatelessWidget {
  AmountTextField({
    Key? key,
    required this.coinCode,
    required this.controller,
    required this.focusNode,
    required this.isEmpty,
  }) : super(key: key);
  final String coinCode;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEmpty;

  final _buttonHeight  = 45.0;
  final _buttonRadius  = 8.0;
  final _buttonPadding = 10.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: _buttonHeight,
          decoration: BoxDecoration(
            color: NAVY[50],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_buttonRadius),
              bottomLeft: Radius.circular(_buttonRadius),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _buttonPadding),
            child: Center(
                child: Text(
              coinCode,
              style: TextStyle(color: Colors.grey),
            )),
          ),
        ),
        Expanded(
          child: TextField(
            readOnly: true,
            showCursor: true,
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.right,
            style: textFieldTextStyle,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: '수량',
              disabledBorder: _outlineInputBorder,
              enabledBorder: _outlineInputBorder,
              focusedBorder: _outlineInputBorder,
            ),
          ),
        ),
        _buildRemoveBtn(controller: controller, visible: !isEmpty)
      ],
    );
  }

  Container _buildRemoveBtn(
      {required TextEditingController controller, required bool visible}) {
    return Container(
      constraints: BoxConstraints(minWidth: 12),
      padding: EdgeInsets.only(right: _buttonPadding),
      height: _buttonHeight,
      decoration: BoxDecoration(
        color: NAVY[50],
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(_buttonRadius),
          bottomRight: Radius.circular(_buttonRadius),
        ),
      ),
      child: Visibility(
        visible: visible,
        child: InkWell(
          onTap: () {
            controller.text = '';
          },
          child: Icon(
            Icons.cancel,
            size: 18,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }

  final _outlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0)));
}
