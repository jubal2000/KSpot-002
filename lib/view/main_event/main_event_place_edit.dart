
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view_model/place_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/place_model.dart';
import '../app/app_top_menu.dart';

class MainEventPlaceEdit extends StatelessWidget {
  MainEventPlaceEdit({Key? key, this.placeData}) : super(key: key);
  var isEdited = false;
  PlaceModel? placeData;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlaceViewModel>.value(
      value: PlaceViewModel(),
      child: Consumer<PlaceViewModel>(builder: (context, viewModel, _) {
        return WillPopScope(
          onWillPop: () async {
            if (isEdited) {
              var result = await showBackAgreeDialog(context);
              switch (result) {
                case 1:
                  break;
                default:
                  return false;
              }
            }
            return true;
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                title: Text(placeData == null ? 'PLACE ADD'.tr : 'PLACE EDIT'.tr, style: AppBarTitleStyle(context)),
                titleSpacing: 0,
                toolbarHeight: 50.w,
              ),
              body: Container(),
            )
          )
        );
      }),
    );
  }
}
