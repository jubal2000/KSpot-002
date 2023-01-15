import 'package:flutter/material.dart';

class Radiobox extends StatelessWidget {
  const Radiobox({Key? key, required this.isOn}) : super(key: key);
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return isOn
        ? Icon(Icons.radio_button_checked)
        : Icon(Icons.radio_button_unchecked);
  }
}
