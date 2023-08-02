import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_simulation/models/story.dart';
import 'package:social_media_simulation/services/user_service.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:uuid/uuid.dart';

class StoryService {
  String statusId = const Uuid().v1();
  UserService userService = UserService();

  sendStory(StoryModel story, String chatId) async {
    //will send message to chats collection with the userId
    await storyRef
        .doc(chatId)
        .collection("stories")
        .doc(story.storyId)
        .set(story.toJson());
    //will update "lastTextTime" to the last time a text was sent
    await storyRef.doc(chatId).update(
      {"userId": firebaseAuth.currentUser!.uid},
    );
  }

  Future<String> sendFirstStory(StoryModel story) async {
    List<String> ids = [];
    await usersRef.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        ids.add(documentSnapshot.get('id'));
      });
    });
    // User? user = firebaseAuth.currentUser;
    DocumentReference ref = await storyRef.add({
      'whoCanSee': ids,
    });
    await sendStory(story, ref.id);
    return ref.id;
  }

  Future<String> uploadImage(File image) async {
    Reference storageReference =
        storage.ref().child(uuid.v1()).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }
}
