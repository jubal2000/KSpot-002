
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../utils/utils.dart';

// ignore: non_constant_identifier_names
ShowPageControlWidget(BuildContext context, int now, int max, Function(int)? onPageChanged, [EdgeInsets padding = EdgeInsets.zero]) {
  LOG('--> ShowPageControlWidget : $now / $max');
  const _height = 40.0;
  final _controller = AutoScrollController();
  final _btnActiveColor   = Theme.of(context).canvasColor;
  final _btnDisableColor  = Theme.of(context).canvasColor.withOpacity(0.2);
  final _textActiveColor  = Theme.of(context).colorScheme.secondary;
  final _textDisableColor = Theme.of(context).colorScheme.secondary.withOpacity(0.2);

  Future.delayed(Duration(milliseconds: 200), () {
    _controller.scrollToIndex(now, preferPosition: AutoScrollPosition.begin);
  });

  return Container(
      height: _height,
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: _height, height: _height - 10,
            child: ElevatedButton(
              onPressed: () {
                if (onPageChanged != null) onPageChanged(0);
              },
              child: Icon(Icons.first_page, size: 24, color: now - 1 >= 0 ? _textActiveColor : _textDisableColor),
              style: ElevatedButton.styleFrom(
                  backgroundColor: now - 1 >= 0 ? _btnActiveColor : _btnDisableColor,
                  minimumSize: Size.zero, // Set this
                  padding: EdgeInsets.zero, // and this
                  shadowColor: Colors.transparent,
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: now - 1 >= 0 ? _textActiveColor : _textDisableColor, width: 1)
                  )
              ),
            ),
          ),
          SizedBox(width: 5),
          SizedBox(width: _height, height: _height - 10,
            child: ElevatedButton(
              onPressed: () {
                var newPage = now - 1;
                if (onPageChanged != null && newPage >= 0) onPageChanged(newPage);
              },
              child: Icon(Icons.chevron_left, size: 24, color: now - 1 >= 0 ? _textActiveColor : _textDisableColor),
              style: ElevatedButton.styleFrom(
                  backgroundColor: now - 1 >= 0 ? _btnActiveColor : _btnDisableColor,
                  minimumSize: Size.zero, // Set this
                  padding: EdgeInsets.zero, // and this
                  shadowColor: Colors.transparent,
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: now - 1 >= 0 ? _textActiveColor : _textDisableColor, width: 1)
                  )
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
              child: Center(
                  child: SingleChildScrollView(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i=0; i<max; i++)...[
                            AutoScrollTag(
                                key: ValueKey(i),
                                controller: _controller,
                                index: i,
                                child: GestureDetector(
                                    onTap: () {
                                      if (onPageChanged != null) onPageChanged(i);
                                    },
                                    child: Container(
                                      width: _height * 0.6,
                                      height: _height,
                                      color: Colors.transparent,
                                      child: Center(
                                          child: Text(i == now ? '[$i]' : '$i',
                                              style: TextStyle(fontSize: 14,
                                                  color: i == now ? _textActiveColor : _textActiveColor.withOpacity(0.5),
                                                  fontWeight: i == now ? FontWeight.w800 : FontWeight.w400))
                                      ),
                                    )
                                )
                            )
                          ]
                        ],
                      )
                  )
              )
          ),
          SizedBox(width: 14),
          SizedBox(width: _height, height: _height - 10,
            child: ElevatedButton(
              onPressed: () {
                var newPage = now + 1;
                if (onPageChanged != null && newPage < max) onPageChanged(newPage);
              },
              child: Icon(Icons.chevron_right, size: 24, color: now + 1 < max ? _textActiveColor : _textDisableColor),
              style: ElevatedButton.styleFrom(
                  backgroundColor: now + 1 < max ? _btnActiveColor : _btnDisableColor,
                  minimumSize: Size.zero, // Set this
                  padding: EdgeInsets.zero, // and this
                  shadowColor: Colors.transparent,
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: now + 1 < max ? _textActiveColor : _textDisableColor, width: 1)
                  )
              ),
            ),
          ),
          SizedBox(width: 5),
          SizedBox(width: _height, height: _height - 10,
            child: ElevatedButton(
              onPressed: () {
                if (onPageChanged != null) onPageChanged(max-1);
              },
              child: Icon(Icons.last_page, size: 24, color: now + 1 < max ? _textActiveColor : _textDisableColor),
              style: ElevatedButton.styleFrom(
                  backgroundColor: now + 1 < max ? _btnActiveColor : _btnDisableColor,
                  minimumSize: Size.zero, // Set this
                  padding: EdgeInsets.zero, // and this
                  shadowColor: Colors.transparent,
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: now + 1 < max ? _textActiveColor : _textDisableColor, width: 1)
                  )
              ),
            ),
          ),
        ],
      )
  );
}
