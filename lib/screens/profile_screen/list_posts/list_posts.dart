import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:social_media_simulation/models/post.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/indicator.dart';
import 'package:social_media_simulation/widgets/user_post.dart';

class ListPosts extends StatefulWidget {
  final userId;
  final username;

  const ListPosts({super.key, required this.userId, required this.username});

  @override
  State<ListPosts> createState() => _ListPostsState();
}

class _ListPostsState extends State<ListPosts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Ionicons.chevron_back),
        ),
        title: Column(
          children: [
            Text(
              widget.username.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey),
            ),
            const Text(
              'Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: postRef
              .where('ownerId', isEqualTo: widget.userId)
              .orderBy('timestamp', descending: true)
              .get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var snap = snapshot.data;
              List docs = snap!.docs;
              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  PostModel posts = PostModel.fromJson(docs[index].data());
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: UserPost(post: posts),
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress(context);
            } else {
              return const Center(
                child: Text(
                  'No Feeds',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
