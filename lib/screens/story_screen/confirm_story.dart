import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/models/enum/message_type.dart';
import 'package:social_media_simulation/models/story.dart';
import 'package:social_media_simulation/screens/view_image/view_image.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/view_model/story_view_model/story_view_model.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

class ConfirmStory extends StatefulWidget {
  const ConfirmStory({super.key});

  @override
  State<ConfirmStory> createState() => _ConfirmStoryState();
}

class _ConfirmStoryState extends State<ConfirmStory> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: loading,
        progressIndicator: circularProgress(context),
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Image.file(viewModel.mediaUrl!),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        child: Container(
          constraints: BoxConstraints(maxHeight: 100),
          child: Flexible(
            child: TextFormField(
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.headline6!.color,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: 'Type your caption',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.headline6!.color,
                ),
              ),
              onSaved: (val) {
                viewModel.setDescription(val!);
              },
              onChanged: (val) {
                viewModel.setDescription(val);
              },
              maxLines: null,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () async {
          setState(() {
            loading = true;
          });
          //check if user has uploaded a story
          QuerySnapshot snapshot = await storyRef
              .where('userId', isEqualTo: firebaseAuth.currentUser!.uid)
              .get();
          if (snapshot.docs.isNotEmpty) {
            List chatList = snapshot.docs;
            DocumentSnapshot chatListSnapshot = chatList[0];
            String url = await uploadMedia(viewModel.mediaUrl!);
            StoryModel message = StoryModel(
              url: url,
              caption: viewModel.description ?? '',
              type: MessageType.IMAGE,
              time: Timestamp.now(),
              storyId: uuid.v1(),
              viewers: [],
            );
            await viewModel.sendStory(chatListSnapshot.id, message);
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
          } else {
            String url = await uploadMedia(viewModel.mediaUrl!);
            StoryModel message = StoryModel(
              url: url,
              caption: viewModel.description ?? '',
              type: MessageType.IMAGE,
              time: Timestamp.now(),
              storyId: uuid.v1(),
              viewers: [],
            );
            String id = await viewModel.sendFirstStory(message);
            await viewModel.sendStory(id, message);
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<String> uploadMedia(File image) async {
    Reference storageReference =
        storage.ref().child("story").child(uuid.v1()).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }
}
