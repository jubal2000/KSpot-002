import 'package:flutter/cupertino.dart';

class InputDoneView extends StatelessWidget {
  InputDoneView({required this.onDone});
  final VoidCallback onDone;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // color: Color(Const.doneButtonBg),
      color: CupertinoColors.extraLightBackgroundGray,
      child: Align(
        alignment: Alignment.topRight,
        child: CupertinoButton(
          padding: EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            // FocusScope.of(context).unfocus();
          },
          child: Text("Done",
              style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
