import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/app_data.dart';
import '../core/dialogs.dart';
import '../core/style.dart';
import '../core/utils.dart';

class ImageListViewer extends StatefulWidget {
  ImageListViewer(this.itemList,
      {Key? key,
        this.title = '',
        this.textHeight = 30.0,
        this.itemWidth = 125,
        this.itemHeight = 250,
        this.itemRound = 8.0,
        this.sidePadding = 0,
        this.subOutlineWidth = 2,
        this.imageMax = 9,
        this.backFit = BoxFit.fitHeight,
        this.backgroundPadding = EdgeInsets.zero,
        this.backColor = Colors.grey,
        this.isEditable = false,
        this.isShowMenu = false,
        this.isVerticalScroll = false,
        this.isImageExView = false,
        this.isAddButtonShow = false,
        this.isThumbShow = true,
        this.isCanDownload = false,
        this.selectTextStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        this.onActionCallback
      }) : super(key: key);

  List<String> itemList;
  String title;
  double sidePadding;
  double textHeight;
  double itemWidth;
  double itemHeight;
  double itemRound;
  int    subOutlineWidth;
  int    imageMax;
  BoxFit backFit;
  EdgeInsets backgroundPadding;
  Color  backColor;

  TextStyle selectTextStyle;

  bool   isEditable;
  bool   isAddButtonShow;
  bool   isShowMenu;
  bool   isVerticalScroll;
  bool   isImageExView;
  bool   isThumbShow;
  bool   isCanDownload;

  Function(int, int)? onActionCallback; // key, status - 0: select, 1: add,  2: delete

  @override
  ImageListViewerState createState() => ImageListViewerState();
}

class ImageListViewerState extends State<ImageListViewer> {
  final PageController _controller = PageController(
      viewportFraction: 1, keepPage: true);

  List<Widget> _cardList = [];

  moveBack() {
    _controller.animateToPage(_controller.page!.toInt() - 1,
        duration: Duration(milliseconds: SCROLL_SPEED),
        curve: Curves.easeInQuad);
  }

  moveNext() {
    _controller.animateToPage(_controller.page!.toInt() + 1,
        duration: Duration(milliseconds: SCROLL_SPEED),
        curve: Curves.easeInQuad);
  }

  onSelected(int key, int status) {
    if (widget.onActionCallback != null) {
      widget.onActionCallback!(key, status);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  refresh() {
    setState(() {
      _cardList = widget.itemList.map((item) =>
          Container(
            color: widget.backColor,
              child: GestureDetector(
                  onLongPress: () {
                    if (!widget.isShowMenu) {
                      showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
                        if (result == 1) {
                          onSelected(-99, 2);
                        }
                      });
                    }
                  },
                  onTap: () {
                    // log('---> select image item.key: $index -> ${item.key} / ${widget.itemList}');
                    onSelected(widget.itemList.indexOf(item), 1);
                  },
                  child: Stack(
                      children: [
                        Container(
                          width: widget.itemWidth,
                          padding: EdgeInsets.symmetric(horizontal: widget.isVerticalScroll ? 0 : 2.5, vertical: widget.isVerticalScroll ? 5 : 0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: widget.itemWidth,
                                height: widget.itemHeight,
                                child:  showImageWidget(item, widget.backFit),
                              ),
                            ]
                          )
                        ),
                        if (widget.isShowMenu)
                          Positioned(
                            bottom: widget.isVerticalScroll ? 10 : 5,
                            right: 5,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                customButton: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.settings_sharp, color: Colors.black.withOpacity(0.5), size: 28),
                                      Icon(Icons.settings_sharp, color: Colors.white, size: 24),
                                    ]
                                ),
                                buttonPadding: EdgeInsets.zero,
                                dropdownPadding: EdgeInsets.zero,
                                items: [
                                  ...DropdownItems.bannerEditItems.map(
                                        (item) =>
                                        DropdownMenuItem<DropdownItem>(
                                          value: item,
                                          child: DropdownItems.buildItem(context, item),
                                        ),
                                  ),
                                ],
                                // customItemsHeights: const [3],
                                onChanged: (value) {
                                  var selected = value as DropdownItem;
                                  LOG("--> selected.index : $item / ${selected.type}");
                                  switch (selected.type) {
                                    default:
                                      onSelected(widget.itemList.indexOf(item), 2);
                                  }
                                },
                                itemHeight: 45,
                                dropdownWidth: 140,
                                buttonHeight: 30,
                                buttonWidth: 30,
                                itemPadding: const EdgeInsets.only(left: 16, right: 16),
                                offset: const Offset(0, 8),
                              ),
                            ),
                          ),
                        ]
                  )
              )
          )
      ).toList();

      if (widget.isEditable && widget.isAddButtonShow && widget.itemList.length < widget.imageMax) {
        _cardList.add(Container(
            width: widget.itemWidth,
            height: widget.isVerticalScroll ? widget.itemHeight * 0.5 : widget.itemHeight,
            margin: EdgeInsets.symmetric(horizontal: widget.isVerticalScroll ? 0 : 2.5, vertical: widget.isVerticalScroll ? 5 : 0),
            child: ElevatedButton(
              onPressed: () {
                onSelected(-1, 1);
              },
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor.withOpacity(0.25),
                  minimumSize: Size.zero, // Set this
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_outlined, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                  SizedBox(height: 5),
                  Text('Add'.tr, style: itemTitleStyle)
                ],
              ),
            )
        )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    refresh();
    if (widget.isVerticalScroll) {
      return Container(
          padding: widget.backgroundPadding,
          child: Column(
            children: [
              if (widget.title.isNotEmpty)
                Container(
                  height: widget.textHeight,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: widget.sidePadding),
                  child: Text(
                      widget.title,
                      style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.5), fontWeight: FontWeight.w800)
                  ),
                ),
              Container(
                alignment: Alignment.center,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: widget.sidePadding),
                    child: Column(
                      children: _cardList,
                    )
                ),
              )
            ],
          )
      );
    } else {
      return Container(
          padding: widget.backgroundPadding,
          child: Column(
            children: [
              if (widget.title.isNotEmpty)
                Container(
                  height: widget.textHeight,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: widget.sidePadding),
                  child: Text(
                      widget.title,
                      style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.5), fontWeight: FontWeight.w800)
                  ),
                ),
              Container(
                  height: widget.itemHeight,
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: widget.sidePadding),
                        child: Row(
                          children: _cardList,
                        )
                    ),
                  )
              ),
            ],
          )
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}