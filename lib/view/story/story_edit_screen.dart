import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/repository/story_repository.dart';
import 'package:kspot_002/view/story/story_edit_event_screen.dart';
import 'package:kspot_002/view/story/story_edit_input_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

import '../../data/theme_manager.dart';
import '../../models/etc_model.dart';
import '../../models/event_model.dart';
import '../../models/story_model.dart';
import '../../utils/utils.dart';
import '../../view_model/story_edit_view_model.dart';
import '../../widget/page_dot_widget.dart';
import '../../widget/title_text_widget.dart';


class StoryEditScreen extends StatefulWidget {
  StoryEditScreen({Key? key, this.storyInfo, this.eventInfo}) : super(key: key);

  StoryModel? storyInfo;
  EventModel? eventInfo;

  @override
  _StoryEditScreenState createState ()=> _StoryEditScreenState();
}

class _StoryEditScreenState extends State<StoryEditScreen> {
  final _viewModel = StoryEditViewModel();

  @override
  void initState () {
    _viewModel.isEditMode = widget.eventInfo != null;
    if (_viewModel.isEditMode) {
      _viewModel.setEditItem(widget.storyInfo!, widget.eventInfo);
    } else {
      _viewModel.setEditItem(StoryModelEx.empty(''), null);
    }
    super.initState ();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoryEditViewModel>.value(
      value: _viewModel,
      child: Consumer<StoryEditViewModel>(
        builder: (context, viewModel, _) {
          return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                title: TopTitleText(context, viewModel.isEditMode ? 'Story Edit'.tr : 'Story Add'.tr),
                titleSpacing: 0,
                toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
              ),
              body: Container(
                  child: Column(
                    children: [
                      if (viewModel.isEditMode)...[
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE_L),
                              child: StoryEditInputScreen(parentViewModel: viewModel)
                          ),
                        ),
                      ],
                      if (!viewModel.isEditMode)...[
                        PageDotWidget(
                          viewModel.stepIndex, viewModel.stepMax,
                          dotType: PageDotType.line,
                          height: 5,
                          frontColor: Theme.of(context).primaryColor,
                          width: Get.width - (UI_HORIZONTAL_SPACE * 2),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_L, UI_TOP_SPACE, UI_HORIZONTAL_SPACE_L, 0),
                            child: IndexedStack(
                              key: ValueKey(viewModel.stepIndex),
                              index: viewModel.stepIndex,
                              children: [
                                showAgreeStep(context, viewModel),
                                StoryEditEventScreen(parentViewModel: viewModel),
                                StoryEditInputScreen(parentViewModel: viewModel),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (!viewModel.isShowOnly)...[
                        SizedBox(height: UI_LIST_TEXT_SPACE_S),
                        BottomCenterAlign(
                            child: GestureDetector(
                                onTap: () {
                                  // if (!viewModel.isNextEnable) return; // disabled for Dev..
                                  viewModel.moveNextStep();
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: UI_BOTTOM_HEIGHT,
                                  color: viewModel.isNextEnable ? Theme.of(context).primaryColor : Colors.black45,
                                  alignment: Alignment.center,
                                  child: Text('Next'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.inversePrimary)),
                                )
                            )
                        ),
                      ]
                    ],
                  )
                )
              // body: Material(
              //   child: Stack(
              //     children: [
              //       Container(
              //         height: double.infinity,
              //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //         child: SingleChildScrollView(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //                 viewModel.showImageSelector(),
              //                 viewModel.showDesc(),
              //                 SizedBox(height: 70),
              //               ],
              //             )
              //           )
              //         ),
              //         Positioned(
              //           left: 0,
              //           bottom: 0,
              //           child: Container(
              //             width: MediaQuery.of(context).size.width,
              //             child: Row(
              //               children: [
              //                 if (widget.isCanDelete)...[
              //                   Expanded(
              //                     child: TextButton(
              //                       child: Text('Delete'.tr),
              //                       onPressed: () {
              //                         showAlertYesNoDialog(context,
              //                             'Delete'.tr,
              //                             'Are you sure you want to delete it?'.tr, '',
              //                             'Cancel'.tr, 'OK'.tr).then((value) {
              //                           if (value == 1) {
              //                             // TODO select..
              //                           }
              //                         });
              //                       },
              //                     ),
              //                   ),
              //                 ],
              //                 Expanded(
              //                   child: ElevatedButton(
              //                     style: ElevatedButton.styleFrom(
              //                         primary: Colors.purple,
              //                         shadowColor: Colors.transparent,
              //                         minimumSize: Size(double.infinity, 50),
              //                         shape: RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.circular(0),
              //                         )
              //                     ),
              //                     onPressed: () {
              //                       if (_imageData.isEmpty) {
              //                         showAlertDialog(context, 'Upload'.tr, 'Please select one or more images'.tr, '', 'OK'.tr);
              //                         return;
              //                       }
              //                       showAlertYesNoDialog(context, 'Upload'.tr, 'Do you want to upload?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((value) {
              //                         if (value == 0) return;
              //                         int upCount = 0;
              //                         showLoadingDialog(context, 'uploading now...'.tr);
              //                         Future.delayed(Duration(milliseconds: 200), () async {
              //                           for (var item in _imageData.entries) {
              //                             String? result1;
              //                             String? result2;
              //                             if (item.value['type'] == 'video' && STR(item.value['video']).isNotEmpty) {
              //                               result1 = await api.uploadImageFile(File(item.value['backPic']), 'placeStory_mov_p', item.key);
              //                               result2 = await api.uploadVideoData(item.value, 'placeStory_mov');
              //                             } else if (item.value['type'] == 'image' && STR(item.value['image']).isNotEmpty) {
              //                               result1 = await api.uploadImageData(item.value, 'placeStory_img');
              //                             }
              //                             if (result1 != null) {
              //                               _imageData[item.key]['backPic'] = result1;
              //                               upCount++;
              //                             }
              //                             if (result2 != null) {
              //                               _imageData[item.key]['videoUrl'] = result2;
              //                             }
              //                           }
              //                           LOG('---> upload upCount : $upCount / $_imageData');
              //                           widget.jsonData['desc'] = _descText;
              //                           widget.jsonData['imageData'] = [];
              //                           for (var item in _imageData.entries) {
              //                             if (item.value['backPic'] != null) {
              //                               widget.jsonData['imageData'].add({
              //                                 'backPic' : STR(item.value['backPic']),
              //                                 'videoUrl': STR(item.value['videoUrl'])
              //                               });
              //                             }
              //                           }
              //                           JSON upResult = await api.addStoryItem(TO_SERVER_DATA(widget.jsonData));
              //                           LOG('---> addStoryItem upResult done : $upResult');
              //                           Navigator.of(dialogContext!).pop();
              //                           Future.delayed(Duration(milliseconds: 200), () async {
              //                             Navigator.pop(context, upResult);
              //                           });
              //                         });
              //                       });
              //                     },
              //                     child: Text('Upload'.tr, style: _titleWStyle),
              //                   )
              //                 )
              //               ],
              //             ),
              //           ),
              //         ),
              //       ]
              //     )
              //   )
              )
            )
          );
        }
      )
    );
  }
}

