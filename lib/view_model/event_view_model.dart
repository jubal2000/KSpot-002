import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/style.dart';
import '../data/theme_manager.dart';
import '../models/etc_model.dart';
import '../models/event_group_model.dart';
import '../models/event_model.dart';
import '../models/place_model.dart';
import '../utils/utils.dart';
import '../widget/event_time_edit_widget.dart';
import '../widget/card_scroll_viewer.dart';
import '../widget/edit/edit_list_widget.dart';
import '../widget/event_group_dialog.dart';

class EventViewModel extends ChangeNotifier {
  Map<String, EventModel>? eventList;
  BuildContext? buildContext;

  // for Edit..
  final _imageGalleryKey  = GlobalKey();
  final JSON imageList = {};

  init(BuildContext context) {
    buildContext = context;
  }

  addMainData(EventModel mainItem) {
    eventList ??= {};
    eventList![mainItem.id] = mainItem;
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