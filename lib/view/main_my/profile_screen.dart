
import 'package:flutter/material.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({ Key? key }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _viewModel = UserViewModel();

  @override
  void initState() {
    _viewModel.initUserModel(AppData.userInfo);
    _viewModel.initProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.setContext(context);
    return  SafeArea(
      top: false,
      child: ChangeNotifierProvider<UserViewModel>.value(
        value: _viewModel,
        child: Consumer<UserViewModel>(
          builder: (context, viewModel, _) {
            return DefaultTabController(
              length: viewModel.tabList.length,
              child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: UI_APPBAR_TITLE_SPACE,
                  bottom: TabBar(
                    onTap: (index) {
                      viewModel.currentTab = index;
                    },
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    labelColor: Theme.of(context).primaryColor,
                    labelStyle: ItemTitleStyle(context),
                    unselectedLabelColor: Theme.of(context).hintColor,
                    unselectedLabelStyle: ItemTitleStyle(context),
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: List<Widget>.from(viewModel.tabList.map((item) => item.getTab()).toList()),
                  ),
                ),
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: List<Widget>.from(viewModel.tabList),
                ),
              ),
            );
          }
        )
      )
    );
  }
}
