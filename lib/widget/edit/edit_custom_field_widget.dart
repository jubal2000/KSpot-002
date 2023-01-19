import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class EditCustomFieldWidget extends StatefulWidget {
  EditCustomFieldWidget(this.itemList, {Key? key, this.title = '', this.onSelected}) : super(key: key);

  JSON itemList;
  String title;
  Function(String)? onSelected;

  @override
  State<StatefulWidget> createState() => _EditCustomFieldState();
}

class _EditCustomFieldState extends State<EditCustomFieldWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}
