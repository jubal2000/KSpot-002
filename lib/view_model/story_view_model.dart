import 'package:flutter/cupertino.dart';
import 'package:kspot_002/models/story_model.dart';

import '../models/event_model.dart';

class StoryViewModel extends ChangeNotifier {
  Map<String, StoryModel>? _mainData;

  addMainData(StoryModel mainItem) {
    _mainData![mainItem.id] = mainItem;
  }

  showMainList(context) {
    return ListView(

    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}