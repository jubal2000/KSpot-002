import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/view/place/place_detail_screen.dart';
import 'package:kspot_002/view/place/place_edit_screen.dart';
import 'package:kspot_002/widget/google_map_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../models/place_model.dart';
import '../repository/user_repository.dart';
import '../utils/utils.dart';
import '../widget/comment_widget.dart';
import '../widget/content_item_card.dart';
import '../widget/image_scroll_viewer.dart';
import '../widget/like_widget.dart';
import '../widget/share_widget.dart';

class PlaceDetailViewModel extends ChangeNotifier {
  final scrollController = AutoScrollController();
  final userRepo  = UserRepository();

  final topHeight = 50.0;
  final botHeight = 70.0;
  final subTabHeight = 45.0;
  // Future<JSON>? _initData;

  var isManager = false;
  var isOpenStoryList = false;
  var isCanReserve = false;
  var isShowReserveBtn = false;
  var isShowReserveList = false;
  var isShowMap = false;

  PlaceModel? placeInfo;

  setPlaceData(PlaceModel placeItem) {
    placeInfo = placeItem;
    isManager = CheckManager(placeInfo!.toJson());
    LOG('--> setEventData : $isManager / ${placeInfo!.toJson()}');
  }

  moveToEdit() {
    Get.to(() => PlaceEditScreen())!.then((result) {
      if (result != null) {
        placeInfo = result;
        notifyListeners();
      }
    });
  }

  onEventTopMenuAction(selected) {
    LOG("--> selected.index : ${selected.type}");
    switch (selected.type) {
      case DropdownItemType.edit:
        moveToEdit();
        break;
      case DropdownItemType.delete:
        // showAlertYesNoDialog(Get.context!, 'Delete'.tr,
        //     'Are you sure you want to delete it?'.tr, 'Alert) Recovery is not possible'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
        //   if (value == 1) {
        //     if (!AppData.isDevMode) {
        //       showTextInputDialog(Get.context!, 'Delete confirm'.tr,
        //           'Typing \'delete now\''.tr, 'Alert) Recovery is not possible'.tr, 10, null).then((result) {
        //         if (result == 'delete now') {
        //           eventRepo.setEventStatus(placeInfo!.id, 0).then((result) {
        //             if (result) {
        //               placeInfo!.status = 0;
        //               Get.back(result:'deleted');
        //             }
        //           });
        //         }
        //       });
        //     } else {
        //       eventRepo.setEventStatus(placeInfo!.id, 0).then((result) {
        //         if (result) {
        //           placeInfo!.status = 0;
        //           Get.back(result:'deleted');
        //         }
        //       });
        //     }
        //   }
        // });
        break;
      case DropdownItemType.promotion:
      // Navigator.push(Get.context!, MaterialPageRoute(builder: (context) =>
      //     PromotionTabScreen('place', targetInfo: widget.eventInfo)));
    }
  }

  showImage() {
    return showSizedImage(placeInfo!.pic, Get.width);
  }

  showImageList() {
    return ImageScrollViewer(
      placeInfo!.getPicDataList,
      rowHeight: Get.width,
      showArrow: placeInfo!.picData!.length > 1,
      showPage:  placeInfo!.picData!.length > 1,
      autoScroll: false,
    );
  }

  showPicture() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(color: Theme.of(Get.context!).primaryColor.withOpacity(0.5), width: 3),
      ),
      child: showSizedRoundImage(placeInfo!.pic, 60, 8),
    );
  }

  showTitle() {
    return Text(DESC(placeInfo!.title), style: MainTitleStyle(Get.context!), maxLines: 2);
  }

  showDesc() {
    return Text(DESC(placeInfo!.desc), style: DescBodyStyle(Get.context!));
  }

  showShareBox() {
    return Row(
        children: [
          ShareWidget(Get.context!, 'place', placeInfo!.toJson(), showTitle: true),
          SizedBox(width: 10),
          LikeWidget(Get.context!, 'place', placeInfo!.toJson(), showCount: true),
        ]
    );
  }

  showLocation() {
    return Column(
      children: [
        SubTitle(Get.context!, 'ADDRESS'.tr, height: 40),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(placeInfo!.address.address1, style: Theme
                  .of(Get.context!)
                  .textTheme
                  .bodyText1),
              SizedBox(height: 2),
              Text(placeInfo!.address.address2, style: Theme
                  .of(Get.context!)
                  .textTheme
                  .bodyText1),
              SizedBox(height: 15),
              Row(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Theme.of(Get.context!).cardColor,
                      ),
                      child: Icon(Icons.map_outlined, size: 24),
                    ),
                    onTap: () {
                      showGoogleMap();
                      // isShowMap = !isShowMap;
                      // notifyListeners();
                    },
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      var addr = '${placeInfo!.address.address1} ${placeInfo!.address.address2}';
                      LOG('--> clipboard copy : $addr');
                      Clipboard.setData(ClipboardData(text: addr));
                      ShowToast('copied to clipboard'.tr);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Theme.of(Get.context!).cardColor,
                      ),
                      child: Icon(Icons.copy, size: 24),
                    ),
                  )
                ],
              )
            ]
        ),
        // if (isShowMap)...[
        //   SizedBox(height: 10),
        //   GoogleMapWidget(
        //       [placeInfo!.toJson()],
        //       mapHeight: Get.width,
        //       showDirection: true,
        //       showButtons: true,
        //       showMyLocation: true,
        //       onButtonAction: (action) {
        //         if (action == MapButtonAction.direction) {
        //           var url = Uri.parse(GoogleMapLinkDirectionMake(
        //               placeInfo!.title, placeInfo!.address.lat, placeInfo!.address.lng));
        //           canLaunchUrl(url).then((result) {
        //             if (!result) {
        //               if (Platform.isIOS) {
        //                 url = Uri.parse(
        //                     'https://apps.apple.com/gb/app/google-maps-transit-food/id585027354');
        //               } else {
        //                 url = Uri.parse(
        //                     'https://play.google.com/store/apps/details?id=com.google.android.apps.maps');
        //               }
        //             }
        //             launchUrl(url);
        //           });
        //         } else {
        //           GetCurrentLocation().then((result) {
        //             if (AppData.currentLocation != null) {
        //               var url = Uri.parse(GoogleMapLinkBusLineMake(
        //                   'My Location'.tr, AppData.currentLocation!,
        //                   placeInfo!.title, LATLNG(placeInfo!.address.toJson())));
        //               canLaunchUrl(url).then((result) {
        //                 if (!result) {
        //                   if (Platform.isIOS) {
        //                     url = Uri.parse(
        //                         'https://apps.apple.com/gb/app/google-maps-transit-food/id585027354');
        //                   } else {
        //                     url = Uri.parse(
        //                         'https://play.google.com/store/apps/details?id=com.google.android.apps.maps');
        //                   }
        //                 }
        //                 LOG('--> url : $url');
        //                 launchUrl(url);
        //               });
        //             }
        //           });
        //         }
        //       }),
        // ],
      ],
    );
  }

  showGoogleMap() async {
    return await showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        enableDrag: false,
        builder: (context) {
          return SafeArea(
            child: Container(
              height: Get.height * 0.7,
              child: Stack(
              children: [
                BottomCenterAlign(
                  child: PointerInterceptor(
                    child: GoogleMapWidget(
                      [placeInfo!.toJson()],
                      mapHeight: Get.height * 0.7,
                      showDirection: true,
                      showButtons: true,
                      showMyLocation: true,
                      onButtonAction: (action) {
                        if (action == MapButtonAction.direction) {
                          var url = Uri.parse(GoogleMapLinkDirectionMake(
                              placeInfo!.title, placeInfo!.address.lat, placeInfo!.address.lng));
                          canLaunchUrl(url).then((result) {
                            if (!result) {
                              if (Platform.isIOS) {
                                url = Uri.parse(
                                    'https://apps.apple.com/gb/app/google-maps-transit-food/id585027354');
                              } else {
                                url = Uri.parse(
                                    'https://play.google.com/store/apps/details?id=com.google.android.apps.maps');
                              }
                            }
                            launchUrl(url);
                          });
                        } else {
                          GetCurrentLocation().then((result) {
                            if (AppData.currentLocation != null) {
                              var url = Uri.parse(GoogleMapLinkBusLineMake(
                                  'My Location'.tr, AppData.currentLocation!,
                                  placeInfo!.title, LATLNG(placeInfo!.address.toJson())));
                              canLaunchUrl(url).then((result) {
                                if (!result) {
                                  if (Platform.isIOS) {
                                    url = Uri.parse(
                                        'https://apps.apple.com/gb/app/google-maps-transit-food/id585027354');
                                  } else {
                                    url = Uri.parse(
                                        'https://play.google.com/store/apps/details?id=com.google.android.apps.maps');
                                  }
                                }
                                launchUrl(url);
                              });
                            }
                          });
                        }
                      }
                    )
                  )
                ),
                TopRightAlign(
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close, color: Colors.black),
                  ),
                )
              ],
            )
          )
        );
      }
    );
  }

  showCommentList() {
    return Column(
        children: [
          SubTitleBar(Get.context!, 'COMMENT'.tr, height: subTabHeight, icon: isOpenStoryList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, onActionSelect: (select) {
            isOpenStoryList = !isOpenStoryList;
            notifyListeners();
          }),
          if (isOpenStoryList)...[
            AutoScrollTag(
              key: ValueKey(0),
              controller: scrollController,
              index: 0,
              child: CommentTabWidget(placeInfo!.toJson(), 'place'),
            ),
          ]
        ]
    );
  }
}