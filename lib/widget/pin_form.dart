import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/common_colors.dart';
import '../core/common_sizes.dart';

typedef PinFormCallback = void Function(String pinNum);

class PinFormController {
  VoidCallback? refreshPin;
  void dispose() {
    refreshPin = null;
  }
}

class PinForm extends StatefulWidget {
  PinForm({
    Key? key,
    required this.callback,
    required this.topText,
    this.controller,
  }) : super(key: key);
  final PinFormCallback callback;
  final String topText;
  final PinFormController? controller;

  @override
  _PinFormState createState() => _PinFormState();
}

class _PinFormState extends State<PinForm> {
  @override
  void initState() {
    super.initState();
    _keys.shuffle();

    if (widget.controller != null) {
      widget.controller!.refreshPin = refreshPin;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ''];
  final Color lightdColor = NAVY[100]!;
  final Color greyColor = Colors.grey[300]!;
  final TextStyle keyboardTextStyle = TextStyle(
      color: Colors.grey[800],
      fontSize: pin_keyboard_font_size,
      fontWeight: FontWeight.w600);
  String pin = '';
  bool isLoading = false;

  void refreshPin() {
    setState(() {
      isLoading = false;
      pin = '';
    });
  }

  void removePin() {
    setState(() {
      if (pin.length > 0) {
        pin = pin.substring(0, pin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
            flex: 5,
            child: Container(
              // height: context.height * 0.45,
              alignment: Alignment.center,
              child: Container(
                height: 60,
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: Text(
                        widget.topText,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final pinLength = pin.length;
                        return Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: context.width * 0.025),
                          // padding: EdgeInsets.all(6),
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color:
                                pinLength < index + 1 ? greyColor : lightdColor,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            )),
        Expanded(
          flex: 4,
          child: !isLoading
              ? _buildButtonColumn(
                  children: _buildButtonColumnChildren,
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  List<Widget> get _buildButtonColumnChildren {
    var children = <Widget>[];
    var i = 0;
    while (i < _keys.length) {
      children.add(_buildButtonRow(
          children: List.generate(3, (index) {
        var child;
        if (i < _keys.length) {
          child = _buildPinButton(_keys[i]);
        } else {
          child = _buildRemoveButton;
        }
        i++;
        return child;
      })));
    }
    return children;
  }

  Widget _buildButtonColumn({required List<Widget> children}) {
    final _addedLine = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i != children.length) {
        _addedLine.add(Container(
          height: 1,
          color: greyColor,
        ));
      }
      _addedLine.add(children[i]);
    }
    return Column(children: _addedLine);
  }

  Widget _buildButtonRow({required List<Widget> children}) {
    final _addedLine = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      _addedLine.add(children[i]);
      if (i + 1 != children.length) {
        _addedLine.add(Container(
          width: 1,
          color: greyColor,
        ));
      }
    }
    return Expanded(
      child: Row(children: _addedLine),
    );
  }

  Widget _buildPinButton(String value) {
    return Expanded(
      child: SizedBox.expand(
        child: Container(
          child: TextButton(
              style: TextButton.styleFrom(
                primary: NAVY,
                textStyle: keyboardTextStyle,
              ),
              onPressed: () {
                if (pin.length < 6) {
                  setState(() {
                    pin += value;
                  });
                  if (pin.length == 6) {
                    setState(() {
                      isLoading = true;
                      widget.callback(pin);
                    });
                  }
                }
              },
              // onPressed: null,
              child: Text('$value', style: keyboardTextStyle)),
        ),
      ),
    );
  }

  Widget get _buildRemoveButton {
    return Expanded(
      child: SizedBox.expand(
        child: Container(
          child: TextButton(
              style: TextButton.styleFrom(
                primary: NAVY,
              ),
              onPressed: () {
                removePin();
              },
              child: Icon(
                Icons.backspace_rounded,
                color: Colors.grey[800],
              )),
        ),
      ),
    );
  }

  Widget get _buildNone {
    return Expanded(
      child: SizedBox.expand(
        child: Container(),
      ),
    );
  }

  Color _buildColorWithIndex(int index) {
    switch (index) {
      case 0:
        return YELLOW;
      case 1:
        return PINK;
      case 2:
        return PINK;
      case 3:
        return CHOCO;
      case 4:
        return NAVY;
      case 5:
        return NAVY;
      default:
        return NAVY;
    }
  }
}
