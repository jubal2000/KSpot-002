import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class VoteWidget extends StatefulWidget {
  VoteWidget(this.now, {Key? key, this.min = 1, this.max = 5, this.iconSize = 18, this.onChanged}) : super (key: key);

  int now;
  int min;
  int max;
  double iconSize;

  void Function(int)? onChanged;

  @override
  VoteWidgetState createState() => VoteWidgetState();
}

class VoteWidgetState extends State<VoteWidget> {
  var _height = 0.0;
  var _width = 0.0;
  List<Widget> _itemList = [];

  onChangeValue(int now) {
    if (widget.onChanged != null) {
      log('--> onChangeValue : $now');
      widget.now = now + 1;
      widget.onChanged!(widget.now);
      setState(() {
        refreshData();
      });
    }
  }

  refreshData() {
    _height = widget.iconSize;
    _width = _height * widget.max;
    _itemList = [];
    for(var i=0; i<widget.max; i++) {
      var isOn = i < widget.now;
      _itemList.add(GestureDetector(
        onTap: () {
          onChangeValue(i);
        },
        child: Icon(isOn ? Icons.star : Icons.star_border, size: widget.iconSize, color: isOn ? Colors.red : Colors.grey),
      ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: _height,
        // color: Colors.yellow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _itemList
        )
      );
  }
}