import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/app_data.dart';
import '../core/dialogs.dart';
import '../core/style.dart';
import '../core/utils.dart';
import 'card_scroll_viewer.dart';

class ImageScrollViewer extends StatefulWidget {
  ImageScrollViewer(this.itemList, {Key? key,
    this.startIndex = 0,
    this.title = "",
    this.titleStyle = const TextStyle(fontSize: 14, color: Colors.black),
    this.titleHeight = 50.0,
    this.titleBackColor = Colors.white,
    this.titleAlign = Alignment.center,
    this.rowHeight = 200.0,
    this.margin = const EdgeInsets.only(bottom: 0),
    this.backgroundColor = Colors.black,
    this.autoScrollTime = 5,
    this.autoScroll = true,
    this.showArrow = true,
    this.showPage = false,
    this.isOwner  = false,
    this.imageFit = BoxFit.fill,
    this.onPageChanged,
    this.onSelected,
    this.onItemVisible,
  }) : super(key: key);

  final List<dynamic> itemList;
  int         startIndex;
  String      title;
  TextStyle   titleStyle;
  double      titleHeight;
  Color       titleBackColor;
  Alignment   titleAlign;
  double      rowHeight;
  EdgeInsets  margin;
  Color       backgroundColor;
  int         autoScrollTime;
  bool        autoScroll;
  bool        showArrow;
  bool        showPage;
  bool        isOwner;
  BoxFit      imageFit;

  Function(int)? onPageChanged;
  Function(String)? onSelected;
  Function(int, bool)? onItemVisible;

  var currentPage = 0;

  @override
  ImageScrollViewerState createState() => ImageScrollViewerState();
}

class ImageScrollViewerState extends State<ImageScrollViewer> {
  final PageController _controller = PageController(viewportFraction: 1, keepPage: true);

  var _isDragging = false;
  var _startPos = Offset(0, 0);
  var _pageMax = 0;

  final _pageTextStyle0 = TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white,
      shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.black));
  final _pageTextStyle1 = TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.white,
      shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.black));

  Timer? _timer;

  moveBack() {
    try {
      if (mounted) _controller.animateToPage(_controller.page!.toInt()-1, duration: Duration(milliseconds: SCROLL_SPEED), curve: Curves.fastOutSlowIn);
    } catch (e) {
      LOG('--> moveBack error : $e');
    }
  }

  moveNext() {
    try {
      if (mounted) _controller.animateToPage(_controller.page!.toInt()+1, duration: Duration(milliseconds: SCROLL_SPEED), curve: Curves.fastOutSlowIn);
    } catch (e) {
      LOG('--> moveNext error : $e');
    }
  }

  showIndex(int index) {
    try {
      if (mounted) _controller.animateToPage(index, duration: Duration(milliseconds: 1), curve: Curves.linear);
    } catch (e) {
      LOG('--> showIndex error : $e');
    }
  }

  @override
  void initState() {
    if (widget.itemList.length > 1) {
      _pageMax = widget.itemList.length;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showIndex(widget.startIndex);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOwner && widget.itemList.isEmpty) {
      return Container(
        height: widget.rowHeight,
        color: Colors.grey.withOpacity(0.5),
        child: Center(
          child: Text('You can add images'.tr, style: _pageTextStyle1),
        ),
      );
    } else {
      if (widget.autoScroll && _timer == null && widget.itemList.length > 1) {
        _timer = Timer.periodic(Duration(seconds: widget.autoScrollTime), (timer) {
          if (_controller.page!.toInt() + 1 >= widget.itemList.length) {
            _controller.animateToPage(0, duration: Duration(milliseconds: SCROLL_SPEED), curve: Curves.fastOutSlowIn);
          } else {
            moveNext();
          }
        });
      }
      return Stack(
          children: [
            Column(
              children: [
                if (widget.title.isNotEmpty)
                  Container(
                    height: widget.titleHeight,
                    color: widget.titleBackColor,
                    alignment: widget.titleAlign,
                    child: Text(
                        widget.title,
                        style: widget.titleStyle
                    ),
                  ),
                Container(
                  height: widget.rowHeight + 10,
                  color: widget.backgroundColor,
                  margin: widget.margin,
                  child: Stack(
                      children: [
                        PageView.builder(
                          controller: _controller,
                          itemCount: widget.itemList.length,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index) {
                            setState(() {
                              // log("--> onPageChanged : $index");
                              widget.currentPage = index;
                              if (widget.onPageChanged != null) widget.onPageChanged!(index);
                            });
                          },
                          itemBuilder: (context, index) {
                            index = index % widget.itemList.length;
                            LOG('--> widget.itemList[$index] : ${widget.itemList[index]}');
                            return GestureDetector(
                              child: StatefulBuilder(
                                builder: (context, snapshot) {
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.black,
                                    child: showImageWidget(
                                        widget.itemList[index].runtimeType == String ? widget.itemList[index] :
                                        widget.itemList[index]['backPic'] ?? widget.itemList[index]['pic'], widget.imageFit
                                    )
                                  );
                                }
                              ),
                              onHorizontalDragStart: (pos) {
                                if (widget.itemList.length < 2) return;
                                _startPos = pos.localPosition;
                                _isDragging = true;
                              },
                              onHorizontalDragUpdate: (pos) {
                                if (widget.itemList.length < 2) return;
                                if (!_isDragging) return;
                                if (_startPos.dx < pos.localPosition.dx) {
                                  moveBack();
                                } else {
                                  moveNext();
                                }
                                _isDragging = false;
                              },
                              onTap: () {
                                if (widget.onSelected != null) {
                                  if (widget.itemList[index].runtimeType == String) {
                                    widget.onSelected!(widget.itemList[index]);
                                  } else {
                                    widget.onSelected!(widget.itemList[index]['id']);
                                  }
                                }
                              },
                            );
                          },
                        ),
                        if (widget.showArrow)...[
                          SizedBox(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios,
                                        color: widget.currentPage - 1 >= 0 ? Colors.white : Colors.transparent),
                                    onPressed: () {
                                      moveBack();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward_ios,
                                        color: widget.currentPage + 1 < widget.itemList.length ? Colors.white : Colors
                                            .transparent),
                                    onPressed: () {
                                      moveNext();
                                    },
                                  ),
                                ],
                              )
                          ),
                        ]
                      ]
                  ),
                ),
              ],
            ),
            if (widget.showPage && _pageMax > 1)
              BottomCenterAlign(
                heightFactor: 13.7,
                // child: PageDotWidget(widget.currentPage, _pageMax),
              )
            // Positioned(
            //   right: 10,
            //   bottom: 15,
            //   child: Row(
            //     children: [
            //       Text('${widget.currentPage + 1} ', style: _pageTextStyle0),
            //       Text('/ $_pageMax', style: _pageTextStyle1),
            //     ],
            //   ),
            // ),
          ]
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}




