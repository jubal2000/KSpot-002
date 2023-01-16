import 'package:flutter/material.dart';
import 'package:kspot_002/view_model/event_view_model.dart';
import 'package:provider/provider.dart';

import '../../view_model/story_view_model.dart';

class MainStory extends StatelessWidget {
  MainStory({Key? key}) : super(key: key);
  final _viewModel = StoryViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoryViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
        return Scaffold(
          body: _viewModel.showMainList(),
        );
      }),
    );
  }
}
