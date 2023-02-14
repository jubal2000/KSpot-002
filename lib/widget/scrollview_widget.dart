import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class FileScrollViewer extends StatelessWidget {
  FileScrollViewer(
      this.itemList,
      {Key? key,
        this.title = '',
        this.textHeight = 55.0,
        this.itemWidth = 80.0,
        this.itemHeight = 170.0,
        this.sidePadding = 15.0,
        this.subOutlineWidth = 0,
        this.backFit = BoxFit.fitHeight,
        this.onActionCallback,
      });

  List<JSON> itemList;
  String title;
  double sidePadding;
  double textHeight;
  double itemWidth;
  double itemHeight;
  int    subOutlineWidth;
  BoxFit backFit;
  Function(String, int)? onActionCallback; // key, status - 0: select, 1: add,  2: delete

  @override
  Widget build(BuildContext context) {
    JSON itemJson = {};
    for (var i=0; i<itemList.length; i++) {
      var title = STR(itemList[i]['title']);
      itemJson['$i'] = {'id': i, 'title': title, "backPic":GetIconFromFileName(title)};
    }

    return CardScrollViewer(itemJson,
      title: title,
      sidePadding: sidePadding,
      textHeight: textHeight,
      itemWidth: itemWidth,
      itemHeight: itemHeight,
      subOutlineWidth: subOutlineWidth,
      backFit: backFit,
      isImageExView: true,
      onActionCallback: onActionCallback,
    );
  }
}

const ViewSupportFiles = ["docx","doc","xlsx","xls","pptx","ppt","pdf","txt"];

// ignore: non_constant_identifier_names
GetIconFromFileName(String filename) {
  var extName = filename.split('.').last;
  if (ViewSupportFiles.contains(extName)) {
    return 'assets/file_icons/icon_$extName.png';
  }
  return 'assets/file_icons/icon_none.png';
}

class CommentImageScrollViewer extends RowScrollViewer {
  CommentImageScrollViewer(
      List<dynamic> itemList,
      {Key? key,
        title = '',
        textHeight = 0.0,
        itemWidth  = 80.0,
        itemHeight = 80.0,
        sidePadding = 0.0,
        subOutlineWidth = 0,
        backFit = BoxFit.fill,
        onActionCallback,
      })
      : super(itemList,
        key: key,
        title: title,
        textHeight: textHeight,
        itemWidth: itemWidth,
        itemHeight: itemHeight,
        sidePadding: sidePadding,
        subOutlineWidth: subOutlineWidth,
        backFit: backFit,
        onActionCallback: onActionCallback,
  );
}

class RowScrollViewer extends StatelessWidget {
  RowScrollViewer(
      this.itemList,
      {Key? key,
        this.title = '',
        this.textHeight = 30.0,
        this.itemWidth = 125.0,
        this.itemHeight = 250.0,
        this.sidePadding = 15.0,
        this.subOutlineWidth = 0,
        this.backFit = BoxFit.fill,
        onActionCallback,
      });

  List<dynamic> itemList;
  String title;
  double sidePadding;
  double textHeight;
  double itemWidth;
  double itemHeight;
  int    subOutlineWidth;
  BoxFit backFit;
  Function(String, int)? onActionCallback; // key, status - 0: select, 1: add,  2: delete

  @override
  Widget build(BuildContext context) {
    JSON itemJson = {};
    for (var i=0; i<itemList.length; i++) {
      itemJson['$i'] = {'id': i,
        "url": STR(itemList[i]).contains('url') ? itemList[i]['url'] : itemList[i]};
    }

    return CardScrollViewer(itemJson,
        title: title,
        sidePadding: sidePadding,
        textHeight: textHeight,
        itemWidth: itemWidth,
        itemHeight: itemHeight,
        subOutlineWidth: subOutlineWidth,
        backFit: backFit,
        onActionCallback: onActionCallback,
    );
  }
}

class ImageEditScrollViewer extends CardScrollViewer {
  ImageEditScrollViewer(
      JSON itemList,
      {Key? key,
        String title = '',
        double textHeight = 30.0,
        double itemWidth  = 80.0,
        double itemHeight = 80.0,
        double sidePadding = 0.0,
        int subOutlineWidth = 0,
        int imageMax = 9,
        backFit = BoxFit.fill,
        isEditable = true,
        isShowMenu = false,
        isVerticalScroll = false,
        selectedId = '',
        selectText = '',
        selectTextStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        onActionCallback,
      })
      : super(itemList,
      key: key,
      title: title,
      textHeight: textHeight,
      itemWidth: itemWidth,
      itemHeight: itemHeight,
      sidePadding: sidePadding,
      subOutlineWidth: subOutlineWidth,
      imageMax: imageMax,
      backFit: backFit,
      isEditable: isEditable,
      isShowMenu: isShowMenu,
      isVerticalScroll: isVerticalScroll,
      selectedId: selectedId,
      selectText: selectText,
      selectTextStyle: selectTextStyle,
      onActionCallback: onActionCallback,
    );
}

class CardScrollViewer extends StatefulWidget {
  CardScrollViewer(this.itemList,
      {Key? key,
        this.title = '',
        this.textHeight = 30.0,
        this.itemWidth = 125,
        this.itemHeight = 250,
        this.itemRound = 8.0,
        this.sidePadding = 15,
        this.subOutlineWidth = 2,
        this.imageMax = 9,
        this.backFit = BoxFit.fitHeight,
        this.backgroundPadding = const EdgeInsets.fromLTRB(0, 10, 0, 10),
        this.isEditable = false,
        this.isShowMenu = false,
        this.isVerticalScroll = false,
        this.isImageExView = false,
        this.isAddButtonShow = true,
        this.isThumbShow = true,
        this.isCanDownload = true,
        this.selectText = '',
        this.selectedId = '',
        this.selectTextStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        this.onActionCallback
      }) : super(key: key);

  JSON   itemList;
  String title;
  String selectText;
  String selectedId;
  double sidePadding;
  double textHeight;
  double itemWidth;
  double itemHeight;
  double itemRound;
  int    subOutlineWidth;
  int    imageMax;
  BoxFit backFit;
  EdgeInsets backgroundPadding;

  TextStyle selectTextStyle;

  bool   isEditable;
  bool   isAddButtonShow;
  bool   isShowMenu;
  bool   isVerticalScroll;
  bool   isImageExView;
  bool   isThumbShow;
  bool   isCanDownload;

  Function(String, int)? onActionCallback; // key, status - 0: select, 1: add,  2: delete

  @override
  CardScrollViewerState createState() => CardScrollViewerState();
}

class CardScrollViewerState extends State<CardScrollViewer> {
  final PageController _controller = PageController(
      viewportFraction: 1, keepPage: true);

  List<Widget> _cardList = [];
  // final _titleStyle = TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
  // final _linkTextStype = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white,
  //   shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.black.withOpacity(0.1)),
  // );
  // final _subTitleStyle = TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold);

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

  onSelected(String key, int status) {
    if (widget.onActionCallback != null) {
      widget.onActionCallback!(key, status);
    }
  }

  initCardData() {
    // LOG('--> initCardData : ${widget.itemList}');
    if (widget.selectText.isNotEmpty && widget.itemList.isNotEmpty && widget.selectedId.isEmpty) {
      widget.selectedId = widget.itemList.entries.first.key.toString();
    }
  }

  @override
  void initState() {
    initCardData();
    super.initState();
  }

  refresh() {
    setState(() {
      // log('---> widget.itemList: ${widget.itemList}');
      int index = 0;
      // if (widget.itemList.isNotEmpty && widget.selectText.isNotEmpty) {
      //   widget.itemList.entries.map((item) {
      //     if (widget.selectedId.isEmpty) widget.selectedId = item.key;
      //   });
      // }
      // for (var item in widget.itemList.entries) {
      //   LOG('--> CardScrollViewerState item.value : ${item.value} / ${item.value['url'] is String}');
      // }
      _cardList = widget.itemList.entries.map((item) =>
          Container(
            child: GestureDetector(
                onLongPress: () {
                  if (!widget.isShowMenu) {
                    if (widget.selectedId == item.key) {
                      showAlertDialog(context, 'Delete'.tr, 'Representative images cannot be deleted'.tr, '', 'OK'.tr);
                    // } else if (widget.imageMax < 2) {
                    //   showAlertDialog(context, '이미지 삭제', '대표이미지는 삭제할 수 없습니다.', '', '확인');
                    } else {
                      showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
                        if (result == 1) {
                          onSelected(item.key, 2);
                        }
                      });
                    }
                  }
                },
                onTap: () {
                  // log('---> select image item.key: $index -> ${item.key} / ${widget.itemList}');
                  if (widget.selectText.isNotEmpty) {
                    setState(() {
                      widget.selectedId = item.key;
                      onSelected('${item.key}', 0);
                    });
                  } else if (widget.isImageExView) {
                    onSelected('${item.key}', 0);
                  } else if (!widget.isEditable) {
                    var keyList = widget.itemList.keys.toList();
                    int index = keyList.indexOf(item.key);
                    showImageSlideDialog(context,
                        List<String>.from(widget.itemList.entries.map((item) => item.value['linkPic'] ?? item.value['url'] ?? item.value['image']).toList()),
                        index, widget.isCanDownload);
                    // showImageDialog(context, widget.itemList[item.key]['url'] ?? widget.itemList[item.key]['image']);
                  } else if (widget.imageMax == 1) {
                    onSelected('', 1);
                  }
                },
                child: Stack(
                    children: [
                      Container(
                        width: widget.itemWidth,
                        padding: EdgeInsets.symmetric(horizontal: widget.isVerticalScroll ? 0 : 2.5, vertical: widget.isVerticalScroll ? 5 : 0),
                        child: Column(
                          children: [
                            if (item.value['image'] != null || (widget.isThumbShow && item.value['thumb'] != null) || item.value['url'] != null)
                              SizedBox(
                                width: widget.itemWidth,
                                height: widget.itemHeight,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(widget.itemRound),
                                  child: widget.isThumbShow && item.value['thumb'] != null
                                      ? Image.memory(item.value['thumb'], fit: widget.backFit) :
                                      item.value['image'] != null
                                      ? Image.memory(item.value['image'], fit: widget.backFit)
                                    //: showImageWidget(
                                    //     item.value['url'] != null ? (STR(item.value['url']).contains('url') ?
                                    //     JSON.from(jsonDecode(STR(item.value['url'])))['url'] : item.value['url']) : item.value['pic'], widget.backFit)
                                    : showImageWidget(item.value['url'], widget.backFit),
                                ),
                              ),
                            if (item.value['title'] != null)
                              Container(
                                height: widget.textHeight,
                                padding: EdgeInsets.only(top: 5),
                                child: Text(STR(item.value['title']), style: Theme.of(context).textTheme.headline5!, maxLines: null),
                              )
                          ]
                        )
                      ),
                      if (widget.selectedId == item.key && widget.selectText.isNotEmpty)...[
                        Container(
                          width: widget.itemWidth,
                          alignment: Alignment.bottomCenter,
                          child: Text(widget.selectText, style: widget.selectTextStyle),
                        )
                      ],
                      if (item.value['pic'] != null)
                        Positioned(
                          left: 5,
                          bottom: 0,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: widget.itemWidth * 0.45,
                                  height: widget.itemWidth * 0.45,
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    image: DecorationImage(
                                      image: AssetImage(item.value['pic']),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(60.0)),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                if (item.value['nickName'] != null) ...[
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, bottom: 5),
                                    child: Text(STR(item.value['nickName']), style: Theme.of(context).textTheme.subtitle1, maxLines: 2),
                                  )
                                ],
                                // if (item.value['name'] != null) ...[
                                //   Padding(
                                //     padding: EdgeInsets.only(
                                //         left: 5, bottom: 5),
                                //     child: Text(item.value['name'],
                                //         style: MainTheme.textTheme.headline5,
                                //         maxLines: 2),
                                //   )
                                // ]
                              ]
                          )
                      ),
                      if (widget.isShowMenu)...[
                        if (item.value['linkTarget'] != null)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  item.value['linkType'] == 'goods' ? Icons.card_giftcard : Icons.movie_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                Text(STR(item.value['linkTitle']), style:Theme.of(context).textTheme.bodyText1!, maxLines: 4),
                              ],
                            ),
                          ),
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
                                log("--> selected.index : ${item.key} / ${selected.type}");
                                switch (selected.type) {
                                  case DropdownItemType.historyLink: // history link
                                    AppData.listSelectData = {};
                                    if (STR(item.value['linkType']) == 'history' && item.value['linkTarget'] != null) {
                                      AppData.listSelectData[item.value['linkTarget']] = {'key': item.value['linkTarget']};
                                    }
                                    // Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(HistoryScreen(AppData.userInfo, isSelectable: true, selectMax: 1))).then((value) {
                                    //   log("--> AppData.listSelectData : ${AppData.listSelectData.length}");
                                    //   onSelected(item.key, 0);
                                    // });
                                    break;
                                  case DropdownItemType.goodsLink: // goods link
                                    AppData.listSelectData = {};
                                    if (STR(item.value['linkType']) == 'goods' && item.value['linkTarget'] != null) {
                                      AppData.listSelectData[item.value['linkTarget']] = {'key': item.value['linkTarget']};
                                    }
                                    // Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(GoodsScreen(AppData.userInfo, isSelectable: true, selectMax: 1))).then((value) {
                                    //   log("--> AppData.listSelectData : ${AppData.listSelectData.length}");
                                    //   onSelected(item.key, 1);
                                    // });
                                    break;
                                  default:
                                    onSelected(item.key, 2);
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
                onSelected('', 1);
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
                  Text('Add'.tr, style: ItemTitleStyle(context))
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

class CardDataScrollViewer extends StatefulWidget {
  CardDataScrollViewer(this.itemList,
      {Key? key,
        this.title = '',
        this.textHeight = 30.0,
        this.itemWidth = 125,
        this.itemHeight = 250,
        this.sidePadding = 15,
        this.subOutlineWidth = 2,
        this.backFit = BoxFit.fitHeight,
        this.selectText = '',
        this.selectTextStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        this.onSelect
      }) : super(key: key);

  JSON   itemList;
  String title;
  String selectText;
  double sidePadding;
  double textHeight;
  double itemWidth;
  double itemHeight;
  int    subOutlineWidth;
  BoxFit backFit;

  TextStyle selectTextStyle;

  Function(JSON,JSON,int)? onSelect;

  @override
  CardDataScrollViewerState createState() => CardDataScrollViewerState();
}

class CardDataScrollViewerState extends State<CardDataScrollViewer> {
  final api = Get.find<ApiService>();
  final PageController _controller = PageController(
      viewportFraction: 1, keepPage: true);

  List<Widget> _cardList = [];
  final _titleStyle = TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800);
  var _selectedId = '';

  Future<JSON> getCardData(String id, String userId, String storyId) async {
    JSON cardItem = {};
    cardItem['id']      = id;
    cardItem['user']    = await api.getUserInfoFromId(userId);
    cardItem['history'] = await api.getStoryFromId(storyId);
    return cardItem;
  }

  @override
  void initState() {
    super.initState();
  }

  refresh() {
    setState(() {
      _cardList = widget.itemList.entries.map((item) =>
          Container(
              child: FutureBuilder(
                  future: getCardData(item.key, item.value['userId'], item.value['storyId']),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      var itemKey = snapshot.data['id'];
                      var userInfo = snapshot.data['user'];
                      var historyInfo = snapshot.data['story'];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (widget.onSelect != null) {
                                widget.onSelect!(userInfo, historyInfo, 0);
                              }
                            },
                            child: Container(
                              width: widget.itemWidth,
                              height: widget.itemHeight,
                              margin: EdgeInsets.symmetric(horizontal: 2.5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: showImageFit(historyInfo['urlPic']),
                              ),
                            ),
                          ),
                          if (_selectedId == item.key && widget.selectText.isNotEmpty)...[
                            Container(
                              width: widget.itemWidth,
                              margin: EdgeInsets.all(2.5),
                              alignment: Alignment.bottomCenter,
                              child: Text(widget.selectText, style: widget.selectTextStyle),
                            )
                          ],
                          if (userInfo['pic'] != null)
                            Positioned(
                                left: 5,
                                bottom: 2.5,
                                child: GestureDetector(
                                  onTap: () {
                                    if (widget.onSelect != null) {
                                      widget.onSelect!(userInfo, historyInfo, 1);
                                    }
                                  },
                                  child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff7c94b6),
                                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                      border: Border.all(
                                        color: Colors.purple,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: showImageFit(userInfo['pic']),
                                    ),
                                  ),
                                  if (userInfo['nickName'] != null) ...[
                                    Container(
                                      padding: EdgeInsets.only(left: 5, right: 10),
                                      child: Text(
                                          userInfo['nickName'], style: Theme.of(context).textTheme.subtitle1,
                                          maxLines: 2),
                                    )
                                  ],
                                ]
                              )
                            ),
                          )
                        ]
                      );
                    } else {
                      return Center(
                        child: showLoadingCircleSquare(30),
                      );
                    }
                  }
              ),
          )
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    refresh();
    return Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Column(
          children: [
            if (widget.title.isNotEmpty)
              Container(
                height: widget.textHeight,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(horizontal: widget.sidePadding),
                child: Text(
                    widget.title,
                    style: _titleStyle
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}