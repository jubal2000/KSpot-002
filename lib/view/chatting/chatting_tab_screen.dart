
import 'package:flutter/material.dart';
import 'package:kspot_002/view_model/app_view_model.dart';

import '../../view_model/chat_view_model.dart';

class ChatTabScreen extends StatefulWidget {
  ChatTabScreen(
      this.selectedTab,
      this.title,
      { Key? key }) : super(key: key);

  ChatType selectedTab;
  String title;

  Widget getTab() {
    return Tab(text: title, height: 40);
  }

  @override
  ChatTabScreenState createState() => ChatTabScreenState();
}

class ChatTabScreenState extends State<ChatTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
