
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/theme_manager.dart';

import '../utils/utils.dart';

class DropDownMenuWidget extends StatefulWidget {
  DropDownMenuWidget(this.itemList, {Key? key, this.selectKey = '', this.title = '', this.enabled = true, this.onSelected}) : super(key: key);

  List<JSON> itemList;
  String selectKey;
  String title;
  bool enabled;

  Function(String)? onSelected;

  @override
  State<StatefulWidget> createState() => DropDownMenuState();
}

class DropDownMenuState extends State<DropDownMenuWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectKey.isEmpty && widget.itemList.isNotEmpty) widget.selectKey = widget.itemList.first['key'];
    return Container(
      height: widget.title.isNotEmpty ? 60 : 40,
      // height: kMinInteractiveDimension,
      // padding: EdgeInsets.symmetric(hor
      // izontal: 10),
      // decoration: BoxDecoration(
      //   color: Colors.transparent,
      //     border: Border.all(color: Colors.grey, width: 1.0),
      //     borderRadius: BorderRadius.all(Radius.circular(8))
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty)...[
            SizedBox(
              height: 20,
              child: SubTitle(context, widget.title)
            ),
            SizedBox(height: 5),
          ],
          SizedBox(
            height: 30,
            child: DropdownButton<String>(
              isDense: true,
              iconEnabledColor: Theme.of(context).primaryColor,
              value: widget.selectKey.tr,
              enableFeedback: widget.enabled,
              icon: Icon(Icons.arrow_drop_down),
              menuMaxHeight: MediaQuery.of(context).size.height / 3,
              underline: Container(
                height: 1,
                color: Theme.of(context).primaryColor,
              ),
              items: widget.itemList.map((item) => DropdownMenuItem<String>(
                  value: item['key'],
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(STR(item['title']).toString().tr, style: ItemTitleStyle(context))
                  ),
              )).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  widget.selectKey = newValue!;
                  if (widget.onSelected != null) widget.onSelected!(newValue);
                });
              },
            ),
          )
        ]
      )
      // child: CustomDropdownButtonHideUnderline(
      //   child: CustomDropdownButton<String>(
      //     menuMaxHeight: MediaQuery.of(context).size.height / 3,
      //     menuDirection: DropdownMenuDirection.down,
      //     iconEnabledColor: Colors.grey,
      //     items: widget.itemList.map((item) => CustomDropdownMenuItem<String>(
      //       value: item['key'],
      //       child: Text(item['title'], style: _titleStyle),
      //     )).toList(),
      //     value: widget.selectKey,
      //     onChanged: (String? changed) {
      //       if (changed != null) {
      //         setState(() {
      //           widget.selectKey = changed;
      //         });
      //       }
      //     },
      //   ),
      // )
    );
  }
}