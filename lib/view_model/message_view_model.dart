
import 'package:flutter/material.dart';

class MessageViewModel extends ChangeNotifier {
  // final repo = MessageRepository();
  BuildContext? buildContext;

  init(BuildContext context) {
    buildContext = context;
  }
}