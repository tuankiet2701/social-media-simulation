import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_simulation/models/story.dart';
import 'package:social_media_simulation/screens/story_screen/confirm_story.dart';
import 'package:social_media_simulation/services/post_service.dart';
import 'package:social_media_simulation/services/story_service.dart';
import 'package:social_media_simulation/services/user_service.dart';
import 'package:social_media_simulation/utils/constants.dart';
import 'package:social_media_simulation/widgets/showInSnackbar.dart';

class StoryViewModel extends ChangeNotifier {
  //services
  UserService userService = UserService();
  PostService postService = PostService();
  StoryService storyService = StoryService();

  //keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();

  //variables
  bool loading = false;
  String? username;
  File? mediaUrl;
  final picker = ImagePicker();
  String? description;
  String? email;
  String? userDp;
  String? userId;
  String? imgLink;
  bool edit = false;
  String? id;
  int pageIndex = 0;

  setDescription(String val) {
    description = val;
    notifyListeners();
  }

  //functions
  pickImage({bool camera = false, BuildContext? context}) async {
    loading = true;
    notifyListeners();
    try {
      PickedFile? pickedFile = await picker.getImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Constants.lightAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );
      mediaUrl = File(croppedFile!.path);
      loading = false;
      Navigator.of(context!).push(
        CupertinoPageRoute(
          builder: (_) => ConfirmStory(),
        ),
      );
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar('Cancelled', context);
    }
  }

  //send message
  sendStory(String chatId, StoryModel story) {
    storyService.sendStory(story, chatId);
  }

  //send the first message
  Future<String> sendFirstStory(StoryModel message) async {
    String newChatId = await storyService.sendFirstStory(message);
    return newChatId;
  }

  //reset post
  resetPost() {
    mediaUrl = null;
    description = null;
    edit = false;
    notifyListeners();
  }
}
