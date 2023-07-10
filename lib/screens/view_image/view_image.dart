import 'package:flutter/material.dart';
import 'package:social_media_simulation/models/post.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/utils/firebase.dart';

class ViewImage extends StatefulWidget {
  final PostModel? post;
  const ViewImage({super.key, this.post});

  @override
  State<ViewImage> createState() => _ViewImageState();
}

final DateTime timestamp = DateTime.now();

currentUserId() {
  return firebaseAuth.currentUser!.uid;
}

UserModel? user;

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
