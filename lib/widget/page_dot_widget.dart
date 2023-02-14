import 'package:flutter/material.dart';

enum PageDotType {
 dot,
 line,
}

class PageDotWidget extends StatefulWidget {
  PageDotWidget(this.now, this.max, {
    Key? key,
    this.dotType = PageDotType.dot,
    this.width = 280,
    this.height = 30,
    this.circleSize = 8,
    this.space = 2,
    this.activeColor  = Colors.white,
    this.disableColor = Colors.black,
    this.outlineColor = Colors.white,
    this.onPageChanged}) : super(key: key);

  int now;
  int max;
  Function(int)? onPageChanged;

  PageDotType dotType;
  double width;
  double height;
  double circleSize;
  double space;
  Color activeColor;
  Color disableColor;
  Color outlineColor;

  @override
  State<StatefulWidget> createState() => PageDotWidgetState();
}

class PageDotWidgetState extends State<PageDotWidget> {
  List<Widget> itemList = [];

  refreshList(BuildContext context) {
    itemList = [];
    for (var i=0; i<widget.max; i++) {
      if (i > 0) {
        itemList.add(SizedBox(width: widget.space));
      }
      itemList.add(
        Stack(
          children: [
            if (widget.dotType == PageDotType.dot)...[
              Icon(Icons.circle_outlined, size: widget.circleSize+2, color: widget.outlineColor),
              Positioned(
                right: 1,
                top: 1,
                child: Icon(widget.now == i ? Icons.circle : Icons.circle_outlined,
                    size: widget.circleSize, color: widget.now == i ? widget.activeColor : widget.disableColor),
              ),
            ],
            if (widget.dotType == PageDotType.line)...[
              Container(
                width: widget.width / widget.max - widget.space,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.activeColor.withOpacity(i <= widget.now ? 1.0 : 0.2),
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
              )
            ]
          ]
        )
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshList(context);
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: itemList,
      ),
    );
  }
}