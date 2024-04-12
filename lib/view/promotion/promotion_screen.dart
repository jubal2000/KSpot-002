
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view_model/promotion_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/message_view_model.dart';
import '../home/home_top_menu.dart';

class PromotionScreen extends StatelessWidget {
  PromotionScreen({this.isSelect = false, Key? key}) : super(key: key);

  bool isSelect;
  var _viewModel = PromotionViewModel();

  @override
  Widget build(BuildContext context) {
    _viewModel.isSelect = isSelect;
    return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Promotion select'.tr, style: AppBarTitleStyle(context)),
            titleSpacing: 0,
          ),
          body: Container(
            padding: EdgeInsets.only(bottom: UI_BOTTOM_HEIGHT),
            child: ChangeNotifierProvider<PromotionViewModel>.value(
              value: _viewModel,
              child: Consumer<PromotionViewModel>(
                builder: (context, viewModel, _) {
                  return viewModel.showPromotionList();
                }
              )
            )
          ),
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: Theme.of(context).primaryColor,
          //   onPressed: () {
          //   },
          //   child: Icon(Icons.add_comment_outlined, size: 30, color: Colors.white),
          // ),
        )
    );
  }
}
