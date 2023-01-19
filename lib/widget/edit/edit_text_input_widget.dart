import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/theme_manager.dart';
import '../../utils/utils.dart';

// typedef void ValueCallback(int value);

class TextInputWidget extends StatefulWidget {
  TextInputWidget(this.title, this.value, {Key? key,
    this.headText = '',
    this.tailText = '',
    this.width = 60,
    this.min = 0,
    this.max = 99,
    this.inputType = TextInputType.text,
    this.onChanged}) : super(key: key);

  String title;
  String value;
  String headText;
  String tailText;
  TextInputType inputType;
  double width;
  int min;
  int max;
  Function(String)? onChanged;

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  final _textController = TextEditingController();
  var _numValue = 0;

  @override
  void initState() {
    _textController.text = widget.value;
    _numValue = widget.inputType == TextInputType.number ? int.parse(widget.value) : 0;
    super.initState();
  }

  // final TextE ditingController _textController = TextEditingController.fromValue(TextEditingValue(text: value, selection: TextSelection.collapsed(offset: 0)));
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.title.isNotEmpty)
          SubTitle(context, widget.title, height:60, topPadding: 15),
        Row(
            children: [
              SizedBox(
                  width: widget.width,
                  height: 40,
                  child: TextFormField(
                    controller: _textController,
                    decoration: inputLabel(context, '', ''),
                    keyboardType: widget.inputType,
                    style: DescBodyStyle(context),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (text) {
                      LOG('--> onChanged : $text');
                      _numValue = widget.inputType == TextInputType.number ? int.parse(text) : 0;
                      if (widget.onChanged != null) widget.onChanged!(text);
                    },
                  )
              ),
              if (widget.inputType == TextInputType.number)...[
                SizedBox(width: 5),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (--_numValue < widget.min) _numValue = widget.min;
                          _textController.text = _numValue.toString();
                          if (widget.onChanged != null) widget.onChanged!(_numValue.toString());
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Icon(Icons.remove, color: Theme
                              .of(context)
                              .primaryColor),
                          decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .primaryColor
                                  .withOpacity(0.25),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(8)),
                              border: Border.all(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .secondary,
                                width: 1.0,
                              )
                          ),
                        )
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                        onTap: () {
                          if (++_numValue > widget.max) _numValue = widget.max;
                          _textController.text = _numValue.toString();
                          if (widget.onChanged != null) widget.onChanged!(_numValue.toString());
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Icon(Icons.add, color: Theme
                              .of(context)
                              .primaryColor),
                          decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .primaryColor
                                  .withOpacity(0.25),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(8)),
                              border: Border.all(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .secondary,
                                width: 1.0,
                              )
                          ),
                        )
                    ),
                  ],
                )
              ],
              if (widget.tailText.isNotEmpty)...[
                SizedBox(width: 10),
                Text(widget.tailText, style: DescTitleStyle(context)),
              ]
            ]
        ),
      ],
    );
  }
}

class NumberInputWidget extends StatefulWidget {
  NumberInputWidget(this.now, {Key? key, this.onChanged, this.min = 1, this.max = 99, this.step = 1, this.iconSize = 28}) : super (key: key);

  int now;
  int min;
  int max;
  int step;
  double iconSize;

  void Function(int)? onChanged;

  @override
  _NumberInputWidgetState createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  var _height;
  var _width;

  onChangeValue() {
    if (widget.onChanged != null) widget.onChanged!(widget.now);
  }

  onAdd() {
    setState(() {
      if (++widget.now > widget.max) widget.now = widget.max;
    });
    onChangeValue();
  }

  onSub() {
    setState(() {
      if (--widget.now < widget.min) widget.now = widget.min;
    });
    onChangeValue();
  }

  @override
  void initState() {
    super.initState();
    _height = 40.0;
    _width = _height * 2.5;
  }

  @override
  Widget build(BuildContext context) {
    // log("---> NumberInputWidget - now: ${widget.now} / min: ${widget.min} / max: ${widget.max}");
    return Container(
      width: _width,
      height: _height,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              border: Border.all(color: Colors.grey, width: 1),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: _width * 0.3,
                  child: IconButton(
                    onPressed: onSub,
                    color: Colors.grey,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.remove, size: widget.iconSize),
                  ),
                ),
                Expanded(
                  child: Text("${widget.now}", style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center, maxLines: 1),
                ),
                SizedBox(
                  width: _width * 0.3,
                  child: IconButton(
                    onPressed: onAdd,
                    color: Colors.grey,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.add, size: widget.iconSize),
                  ),
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}