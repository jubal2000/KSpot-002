import 'package:flutter/material.dart';

class TopNotifyView extends StatelessWidget  {
  TopNotifyView(this.title, this.desc, this.targetId, {Key? key, this.onAction});

  String title;
  String desc;
  String targetId;
  Function(String)? onAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onAction != null) {
          onAction!(targetId);
        }
      },
      child: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Container(
          padding: const EdgeInsets.only(
            left: 15,
            top: 10,
            bottom: 10,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                spreadRadius: 0,
                color: Color(0x4d000000),
                blurRadius: 15,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                child: const ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                  child: FlutterLogo(
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "wechat",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(
                          0xff333333,
                        ),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "you have a new message",
                      style: TextStyle(
                        color: Color(
                          0xff333333,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
