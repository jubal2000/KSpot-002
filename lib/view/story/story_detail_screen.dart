
import 'package:flutter/material.dart';
import 'package:kspot_002/view/story/story_item.dart';

import '../../data/theme_manager.dart';
import '../../models/story_model.dart';
import '../../utils/utils.dart';


class StoryDetailScreen extends StatefulWidget {
  StoryDetailScreen(this.itemInfo, {Key? key, this.topTitle = '', this.onUpdate}) : super(key: key);

  StoryModel itemInfo;
  String topTitle;
  Function(JSON)? onUpdate;

  @override
  StoryDetailState createState() => StoryDetailState();
}

class StoryDetailState extends State<StoryDetailScreen> {
  final _topHeight = 50.0;
  final _itemKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topTitle, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: _topHeight,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - _topHeight,
          child: Stack(
            children: [
              ListView(
                children: [
                  SizedBox(height: 15),
                  MainStoryItem(widget.itemInfo, key: _itemKey,
                      itemHeight: MediaQuery.of(context).size.width, bottomSpace: 0, isFullScreen: true)
                ]
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  height: _topHeight,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: showCommentMenu(context, widget.itemInfo.toJson(), false, 20, (uploadData) {
                      var state = _itemKey.currentState as MainStoryItemState;
                      state.refreshData(uploadData);
                    },
                        onUpdate: widget.onUpdate
                    )
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}
