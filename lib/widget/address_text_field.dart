import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/common_colors.dart';
import '../data/common_sizes.dart';
import '../data/style.dart';

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
  final _buttonHeight  = 45.0;
  final _buttonRadius  = 8.0;
  final _buttonPadding = 10.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: _buttonHeight,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_buttonRadius),
                bottomLeft: Radius.circular(_buttonRadius),
              ),
              color: NAVY[50],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _buttonPadding),
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
