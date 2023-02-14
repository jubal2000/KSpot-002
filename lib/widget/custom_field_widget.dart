import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/widget/user_card_widget.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../view/profile/target_profile.dart';

Widget ShowCustomField(BuildContext context, JSON customList) {
  final api = Get.find<ApiService>();
  var _height = 0.0;
  var _faceSize = FACE_CIRCLE_SIZE_M;
  var _title = '';
  var _rowAlignment = CrossAxisAlignment.center;
  var _titleStyle = ItemTitleExStyle(context);
  List<Widget> _fieldList = [];

  for (var item in customList.entries) {
    var customInfo = AppData.INFO_CUSTOMFIELD[item.value['customId']];
    if (customInfo != null) {
      Widget? descItem;
      // LOG('--> customInfo item : $item');
      switch(STR(customInfo['type'])) {
        case 'user':
          _height = _faceSize + 10;
          List<Widget> userList = [];
          if (JSON_NOT_EMPTY(item.value['userData'])) {
            for (var user in item.value['userData']) {
              // LOG('--> customInfo : $user');
              userList.add(Container(
                  height: _height,
                  child: Row(
                    children: [
                      UserCardWidget(
                          user,
                          faceSize: _faceSize,
                          padding: EdgeInsets.all(5),
                          onProfileChanged: (result) {
                            LOG('--> UserCardWidget onProfileChanged : $result');
                            user['userName'] = result['userName'];
                            user['userPic' ] = result['userPic' ];
                            api.setStoryItemUserInfo(user['id'], result);
                          },
                          onSelected: (String targetId) async {
                            var userInfo = await api.getUserInfoFromId(user['userId']);
                            if (JSON_NOT_EMPTY(userInfo)) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                  TargetProfileScreen(UserModel.fromJson(userInfo!)))).then((value) {});
                            } else {
                              showUserAlertDialog(context, '${user['userId']}');
                            }
                          }
                      ),
                    ],
                  )
              ));
            }
          }
          descItem = Column(
            children: userList,
          );
          _title = STR(customInfo['title']);
          break;
        case 'image':
          _height = 120.0;
          _title = STR(customInfo['title']);
          _rowAlignment = CrossAxisAlignment.start;
          descItem = GestureDetector(
              onTap: () {
                showImageDialog(context, item.value['url']);
              },
              child: showImage(item.value['url'], Size(_height,_height))
          );
          break;
        default:
          _height = 20.0;
          _title = STR(customInfo['title']);
          switch(customInfo['inputType']) {
            case '2text':
              _title = STR(item.value['title']);
              _titleStyle = ItemTitleStyle(context);
              _rowAlignment = CrossAxisAlignment.start;
              break;
          }
      }
      _fieldList.add(
          Container(
            constraints: BoxConstraints(
                minHeight: _height
            ),
            child: Column(
                crossAxisAlignment: _rowAlignment,
                children: [
                  // Container(
                  //   constraints: BoxConstraints(
                  //     maxWidth: 100,
                  //   ),
                  //   child: Text('$_title : ', style: _titleStyle),
                  // ),
                  SizedBox(height: 5),
                  SubTitle(context, _title),
                  SizedBox(height: 5),
                  if (descItem != null)
                    descItem,
                  if (descItem == null)
                    SizedBox(
                      width: double.infinity,
                      child: Text(DESC(item.value['desc']), style: DescBodyStyle(context)),
                    )
                ]
            ),
          )
      );
    }
  }
  return Container(
      child: Column(
        children: _fieldList,
      )
  );
}