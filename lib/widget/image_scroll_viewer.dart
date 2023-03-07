import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:kspot_002/widget/csc_picker/csc_picker.dart';
import 'package:kspot_002/widget/page_dot_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/style.dart';
import '../utils/utils.dart';
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

class VideoControlData {
  VideoPlayerController? videoController;
  Future<void>? videoInitialize;
  bool isPlaying = false;
  GlobalKey refreshKey = GlobalKey();

  play() {
    if (videoController == null) return;
    videoController!.play();
    isPlaying = true;
  }

  pause() {
    if (videoController == null) return;
    videoController!.pause();
    isPlaying = false;
  }

  toggle() {
    if (videoController == null) return;
    isPlaying ? pause() : play();
    LOG('--> VideoControlData toggle : $isPlaying');
  }

  dispose() {
    if (videoController == null) return;
    videoController!.dispose();
    videoController = null;
  }
}

class ImageScrollViewerState extends State<ImageScrollViewer> {
  final PageController _controller = PageController(viewportFraction: 1, keepPage: true);
  final Map<int, VideoControlData> _videoController = {};

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

  videoLoading() {
    if (!mounted) return;
    for (var index=0; index<widget.itemList.length; index++) {
      LOG('--> videoLoading : $index');
      videoLoadingItem(index);
    }
  }

  videoLoadingItem(index) {
    if (!mounted) return;
    var videoData = VideoControlData();
    if (widget.itemList[index].runtimeType != String && STR(widget.itemList[index]['videoUrl']).isNotEmpty) {
      try {
        if (_videoController[index] == null) {
          _videoController[index] = videoData;
          videoData.videoController = VideoPlayerController.network(widget.itemList[index]['videoUrl']);
        }
        if (videoData.videoController != null) {
          videoData.videoInitialize = videoData.videoController!.initialize();
        }
      } catch (e) {
        LOG('--> _videoController error : $e / ${STR(widget.itemList[index]['videoUrl'])}');
      }
      // LOG('----> videoLoadingItem done : $index');
    } else {
      _videoController[index] = videoData;
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
                        var item = widget.itemList[index];
                        var isFile = item.runtimeType != String && item['extension'] != null && !IS_IMAGE_FILE(item['extension']);
                        LOG('--> widget.itemList[$index] : $isFile / $item');
                        return GestureDetector(
                          child: LayoutBuilder(
                            builder: (context, layout) {
                              if (isFile) {
                                return Container(
                                  width: layout.maxWidth,
                                  height: layout.maxWidth,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: layout.maxWidth * 0.4,
                                          height: layout.maxWidth * 0.6,
                                          child: showImageWidget(item['thumb'], widget.imageFit),
                                        ),
                                        SizedBox(height: 10),
                                        Text(STR(item['name']), style: ItemTitleStyle(context), maxLines: 5),
                                      ],
                                    )
                                  )
                                );
                              } else {
                                return Container(
                                  width: layout.maxWidth,
                                  height: layout.maxWidth,
                                  child: showImageWidget(
                                    item.runtimeType == String ? item :
                                    item['url'] ?? item['pic'], widget.imageFit)
                                );
                              }
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
                              LOG('--> image widget.onSelected [$index] : $item');
                              if (item.runtimeType == String) {
                                widget.onSelected!(item);
                              } else {
                                widget.onSelected!(item['id']);
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
              child: PageDotWidget(widget.currentPage, _pageMax, circleSize: 6),
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




