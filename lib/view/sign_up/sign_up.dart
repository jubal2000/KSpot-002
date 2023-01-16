import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/main_event/main_event.dart';
import 'package:kspot_002/view/main_story/main_story.dart';
import 'package:kspot_002/view_model/signup_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/theme_manager.dart';
import '../../view_model/app_view_model.dart';

class SignUp extends StatelessWidget {
  SignUp({Key? key}) : super(key: key);
  final _viewModel = SignUpViewModel();
  final _height = 40.0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('App exit'.tr),
            content: Text('Are you sure you want to quit the Sign Up?'.tr),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('Cancel'.tr),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Ok'.tr),
              )
            ]
          );
        }
      ),
      child: SafeArea(
        child: ChangeNotifierProvider<SignUpViewModel>.value(
          value: _viewModel,
          child: Consumer<SignUpViewModel>(
            builder: (context, viewModel, _) {
              viewModel.setViewContext(context);
              return Scaffold(
                body: Column(
                  children: [
                    IndexedStack(
                      key: ValueKey(_viewModel.stepIndex),
                      index: _viewModel.stepIndex,
                      children: [
                        viewModel.showAgreeStep(),
                        viewModel.showPhoneStep(),
                        viewModel.showInputStep(),
                      ],
                    ),
                  ],
                )
              );
            }
          ),
        )
      )
    );
  }
}
