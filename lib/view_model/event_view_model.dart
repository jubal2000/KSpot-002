import 'package:flutter/cupertino.dart';

import '../models/event_model.dart';

class EventViewModel extends ChangeNotifier {
  Map<String, EventModel>? _mainData;

  addMainData(EventModel mainItem) {
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