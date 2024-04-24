import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../utils/utils.dart';

class SearchWidget extends StatefulWidget {
  SearchWidget({ Key? key, this.initialText, this.isShowList = true,
    this.padding = const EdgeInsets.fromLTRB(0,0,0,0),
    this.onEdited,
  }) : super(key: key);

  String? initialText;
  bool isShowList;
  EdgeInsets padding;
  Function(String, int)? onEdited;

  @override
  SearchWidgetState createState() => SearchWidgetState();
}

class SearchWidgetState extends State<SearchWidget> {
  final _scrollController = PageController(viewportFraction: 1, keepPage: true);
  final _searchTextController = TextEditingController();
  final _focusNode1 = FocusNode();
  final _height = 55.0;

  var _searchText = "";
  var _isSearchOn = false;
  var _backColor = Colors.white;
  var _isClearMode = false;

  List<String>? filteredSearchHistory;
  List<String> _newHistoryList = [];

  clearFocus([bool isClearText = true]) {
    var textOrg = _searchText;
    _searchTextController.clear();
    if (!isClearText) {
      _isClearMode = true;
      _searchTextController.text = textOrg;
    }
  }

  setHistoryListShow(status) {
    setState(() {
      _isSearchOn = status;
    });
  }

  @override
  void initState() {
    if (widget.isShowList) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _newHistoryList = AppData.searchHistoryList;
      });
    }
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _searchTextController.text = widget.initialText!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _backColor = Theme.of(context).primaryColor;
    return Container(
      // color: Colors.yellow,
      // height: _height,
        padding: widget.padding,
        alignment: Alignment.center,
        constraints: BoxConstraints(
            minHeight: _height, minWidth: double.infinity, maxHeight: double.infinity
        ),
        // height: _newHistoryList.length * _itemHeight > 300 ? 300 : _newHistoryList.length * _itemHeight < 10 ? 10 : _newHistoryList.length * _itemHeight,
        child: Column(
          children: [
            Stack(
                children: [
                  Container(
                  height: _height * 0.7,
                  // color: Colors.green,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    border: Border.all(width: 2, color: Theme.of(context).hintColor),
                  ),
                  // child: Row(
                  //   children: [
                  //     Image.asset("assets/ui/main_top/Search_Bar_00_L.png", color: _backColor),
                  //     Expanded(
                  //       child: Image.asset(
                  //           "assets/ui/main_top/Search_Bar_00_C.png",
                  //           fit: BoxFit.fill, color: _backColor),
                  //     ),
                  //     Image.asset("assets/ui/main_top/Search_Bar_00_R.png", color: _backColor),
                  //   ],
                  // ),
                ),
                Container(
                    height: _height * 0.7,
                    padding: EdgeInsets.only(left: 8),
                    // color: Colors.yellow,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Opacity(
                              opacity: 0.2,
                              child: Icon(
                                Icons.search,
                                size: 20.0,
                              )
                          ),
                          Expanded(
                            child: Container(
                              // color: Colors.blue.withOpacity(0.5),
                              // alignment: Alignment.center,
                              height: _height * 0.7,
                              padding: EdgeInsets.only(left: 5.0),
                              child: TextField(
                                focusNode: _focusNode1,
                                controller: _searchTextController,
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                scrollPhysics: NeverScrollableScrollPhysics(),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(bottom: 15),
                                  hintText: '검색',
                                  fillColor: Colors.transparent,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(style: BorderStyle.none),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(style: BorderStyle.none),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(style: BorderStyle.none),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(style: BorderStyle.none),
                                  ),
                                ),
                                onChanged: (text) {
                                  debugPrint('--> onChanged : $text / ${_searchTextController.text}');
                                  if (_isClearMode) {
                                    _isClearMode = false;
                                    return;
                                  }
                                  setState(() {
                                    _searchText = text;
                                    if (widget.onEdited != null) widget.onEdited!(text, 0);
                                    if (widget.isShowList) {
                                      _newHistoryList = AppData.searchHistoryList.where((string) =>
                                          string.toLowerCase().contains(_searchText.toLowerCase())).toList();
                                      _isSearchOn = _newHistoryList.isNotEmpty;
                                    }
                                  });
                                },
                                onSubmitted: (text) {
                                  if (widget.onEdited != null) widget.onEdited!(text, 1);
                                },
                                onTap: () {
                                  if (widget.isShowList) {
                                    setState(() {
                                      _newHistoryList =
                                          AppData.searchHistoryList.where((string) => string.toLowerCase().contains(_searchText.toLowerCase()))
                                              .toList();
                                      _isSearchOn = _newHistoryList.isNotEmpty;
                                    });
                                  }
                                },
                              )
                            )
                          ),
                          Container(
                            // color: Colors.green.withOpacity(0.5),
                            child: Opacity(
                                opacity: _searchText.isNotEmpty ? 0.2 : 0,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 20.0,
                                  ), onPressed: () {
                                  setState(() {
                                    _searchTextController.clear();
                                    _searchText = '';
                                    unFocusAll(context);
                                    if (widget.onEdited != null) widget.onEdited!('', -1);
                                  });
                                },
                                )
                            ),
                          ),
                        ]
                    )
                ),
            ],
          ),
          if (widget.isShowList)
            Visibility(
              visible: _isSearchOn,
              child: searchHistoryListView,
            ),
        ]
      )
    );
  }

  Widget get searchHistoryListView {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        constraints: BoxConstraints(
          minHeight: 10, minWidth: double.infinity, maxHeight: 300
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ListView.builder(
          // padding: EdgeInsets.all(10.0),
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: _newHistoryList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        alignment: Alignment.centerLeft,
                        child: Text(_newHistoryList[index], style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      if (index < _newHistoryList.length - 1)
                        showHorizontalDivider(Size(double.infinity, 10)),
                    ]
                  ),
                ),
                onTap: () {
                  setState(() {
                    _searchText = _newHistoryList[index];
                    _searchTextController.text = _searchText;
                    _searchTextController.selection = TextSelection.fromPosition(TextPosition(offset: _searchText.length));
                    _isSearchOn = false;
                  });
                }
              ),
            );
          },
        )
    );
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    // _focusNode1.dispose();
    super.dispose();
  }
}

