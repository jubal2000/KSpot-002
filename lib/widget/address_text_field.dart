import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/common_colors.dart';
import '../core/common_sizes.dart';
import '../core/style.dart';

class AddressTextField extends StatefulWidget {
  AddressTextField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.isEmpty,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEmpty;

  @override
  _AddressTextFieldState createState() => _AddressTextFieldState();
}

class _AddressTextFieldState extends State<AddressTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(focusListener);
  }

  void focusListener() {
    if (widget.focusNode.hasFocus == false) {
      setState(() {
        isReadOnly = true;
      });
    }
  }

  bool isReadOnly = true;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: textfield_l_height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(common_m_radius),
                bottomLeft: Radius.circular(common_m_radius),
              ),
              color: NAVY[50],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: common_xxs_gap),
              child: InkWell(
                  onTap: () {
                    callKeyboard();
                  },
                  child: Icon(
                    Icons.keyboard_alt_outlined,
                    color: NAVY,
                  )),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            readOnly: isReadOnly,
            showCursor: true,
            controller: widget.controller,
            focusNode: widget.focusNode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(70),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
            ],
            textAlign: TextAlign.right,
            style: textFieldTextStyle,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: '지갑주소',
              disabledBorder: _outlineInputBorder,
              enabledBorder: _outlineInputBorder,
              focusedBorder: _outlineInputBorder,
            ),
            onChanged: (value) {},
          ),
        ),
        _buildRemoveBtn(controller: widget.controller, visible: !widget.isEmpty)
      ],
    );
  }

  void callKeyboard() {
    setState(() {
      isReadOnly = !isReadOnly;
    });
    widget.focusNode.requestFocus();
  }

  Container _buildRemoveBtn(
      {required TextEditingController controller, required bool visible}) {
    return Container(
      constraints: BoxConstraints(minWidth: 12),
      padding: EdgeInsets.only(right: common_xxxs_gap),
      height: textfield_l_height,
      decoration: BoxDecoration(
        color: NAVY[50],
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(common_m_radius),
          bottomRight: Radius.circular(common_m_radius),
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
