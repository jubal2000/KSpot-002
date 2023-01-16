import 'package:flutter/material.dart';
import 'package:kspot_002/view_model/event_view_model.dart';
import 'package:provider/provider.dart';

class MainEvent extends StatelessWidget {
  MainEvent({Key? key}) : super(key: key);
  final _viewModel = EventViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EventViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
        return Scaffold(
          body: _viewModel.showMainList(),
        );
      }),
    );
  }
}
