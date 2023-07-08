import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/services/service.dart';
import 'package:social_media_simulation/utils/firebase.dart';

class UserService extends Service {
  //get the authenticated uid
  String currentUid() {
    return firebaseAuth.currentUser!.uid;
  }

  //tells when the user is online or not and updates the last seen for the messages
  setUserStatus(bool isOnline) {
    var user = firebaseAuth.currentUser;
    if (user != null) {
      usersRef.doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': Timestamp.now(),
      });
    }
  }

  //updates user profile in the edit profile screen
  updateProfile({
    File? image,
    String? username,
    String? bio,
  }) async {
    DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
    var users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    users.username = username;
    users.bio = bio;
    if (image != null) {
      users.photoUrl = await uploadImage(profilePic, image);
    }
    await usersRef.doc(currentUid()).update({
      'username': username,
      'bio': bio,
      'photoUrl': users.photoUrl ?? '',
    });
    return true;
  }
}
