import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_simulation/models/message.dart';
import 'package:social_media_simulation/services/chat_service.dart';
import 'package:social_media_simulation/widgets/showInSnackbar.dart';

class ChatViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  ChatService chatService = ChatService();
  bool uploadingImage = false;
  final picker = ImagePicker();
  File? image;

  sendMessage(String chatId, Message message) {
    chatService.sendMessage(message, chatId);
  }

  Future<String> sendFirstMessage(String recipient, Message message) async {
    String newChatId = await chatService.sendFirstMessage(message, recipient);
    return newChatId;
  }

  // setReadCount(String chatId, var user, int count) {
  //   chatService.setUserRead(chatId, user, count);
  // }

  // setUserTyping(String chatId, var user, bool typing) {
  //   chatService.setUserTyping(chatId, user, typing);
  // }

  pickImage({int? source, BuildContext? context, String? chatId}) async {
    PickedFile? pickedFile = source == 0
        ? await picker.getImage(
            source: ImageSource.camera,
          )
        : await picker.getImage(
            source: ImageSource.gallery,
          );

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop image',
            toolbarColor: Theme.of(context!).appBarTheme.backgroundColor,
            toolbarWidgetColor: Theme.of(context).iconTheme.color,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

      Navigator.of(context).pop();

      if (croppedFile != null) {
        uploadingImage = true;
        image = File(croppedFile.path);
        notifyListeners();
        showInSnackBar("Uploading image...", context);
        String imageUrl = await chatService.uploadImage(image!, chatId!);
        return imageUrl;
      }
    }
  }
}
