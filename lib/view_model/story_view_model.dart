import 'package:flutter/cupertino.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/models/story_model.dart';

import '../data/common_sizes.dart';
import '../models/event_model.dart';
import '../view/home/app_top_menu.dart';
import 'app_view_model.dart';

class StoryViewModel extends ChangeNotifier {
  Map<String, StoryModel>? _mainData;

  addMainData(StoryModel mainItem) {
    _mainData![mainItem.id] = mainItem;
  }

  showMainList(context) {
    return Stack(
      children: [
        TopCenterAlign(
            child: SizedBox(
              height: UI_TOP_MENU_HEIGHT * 1.7,
              child: AppTopMenuBar(MainMenuID.story, isShowDatePick: false, height: UI_TOP_MENU_HEIGHT),
            )
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}