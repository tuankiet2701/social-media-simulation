import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_simulation/models/post.dart';
import 'package:social_media_simulation/screens/main_screen/main_screen.dart';
import 'package:social_media_simulation/services/post_service.dart';
import 'package:social_media_simulation/services/user_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:social_media_simulation/utils/constants.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/showInSnackbar.dart';

class PostViewModel extends ChangeNotifier {
  //services
  UserService userService = UserService();
  PostService postService = PostService();

  //Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();

  //variables
  bool loading = false;
  String? username;
  File? mediaUrl;
  final picker = ImagePicker();
  String? location;
  Position? position;
  Placemark? placemark;
  String? bio;
  String? description;
  String? email;
  String? commentData;
  String? ownerId;
  String? userId;
  String? type;
  File? userDp;
  String? imgLink;
  bool edit = false;
  String? id;

  //controllers
  TextEditingController locationTEC = TextEditingController();

  //setters
  setEdit(bool val) {
    edit = val;
    notifyListeners();
  }

  setPost(PostModel post) {
    if (post != null) {
      description = post.description ?? '';
      imgLink = post.mediaUrl;
      // location = post.location;
      edit = false;
      notifyListeners();
    } else {
      edit = false;
      notifyListeners();
    }
  }

  setUsername(String val) {
    username = val;
    notifyListeners();
  }

  setDescription(String val) {
    description = val;
    notifyListeners();
  }

  setLocation(String val) {
    location = val;
    notifyListeners();
  }

  setBio(String val) {
    bio = val;
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
      CroppedFile? croppedFile = await ImageCropper()
          .cropImage(sourcePath: pickedFile!.path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ], uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Constants.lightAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ]);
      mediaUrl = File(croppedFile!.path);
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
    }
  }

  getLocation() async {
    loading = true;
    notifyListeners();
    LocationPermission permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      LocationPermission rPermission = await Geolocator.requestPermission();
      print(rPermission);
      await getLocation();
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);
      placemark = placemarks[0];
      location = "${placemark!.country}";
      locationTEC.text = location!;
      print(location);
    }
    loading = false;
    notifyListeners();
  }

  uploadPosts(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();
      // await postService.uploadPost(mediaUrl!, location!, description!.trim());
      await postService.uploadPost(mediaUrl!, description?.trim() ?? '');
      showInSnackBar('Uploaded Successfully!', context);
      loading = false;
      resetPost();
      notifyListeners();
    } catch (e) {
      print(e);
      loading = false;
      resetPost();
      showInSnackBar('Upload Failed!', context);
      notifyListeners();
    }
  }

  uploadProfilePicture(BuildContext context) async {
    if (mediaUrl == null) {
      showInSnackBar('Please Select an Image', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        await postService.uploadProfilePicture(
          mediaUrl!,
          firebaseAuth.currentUser!,
        );
        loading = false;
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => MainScreen(),
          ),
        );
        notifyListeners();
      } catch (e) {
        print(e);
        loading = false;
        showInSnackBar('Uploaded Successfully!', context);
        notifyListeners();
      }
    }
  }

  resetPost() {
    mediaUrl = null;
    description = null;
    location = null;
    edit = false;
    notifyListeners();
  }
}
