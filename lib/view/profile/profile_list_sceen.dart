import 'package:flutter/material.dart';

import '../../view_model/user_view_model.dart';
import '../story/story_item.dart';

class ProfileListScreen extends StatefulWidget {
  ProfileListScreen(this.selectedTab, this.title, this.userViewModel,
      {Key? key, this.isSelectable = false})
      : super(key: key);

  ProfileContentTab selectedTab;
  String title;
  UserViewModel userViewModel;
  bool isSelectable;

  @override
  ProfileListState createState() => ProfileListState();
}

class ProfileListState extends State<ProfileListScreen> {

  @override
  void initState() {
    widget.userViewModel.initListTab(widget.userViewModel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}