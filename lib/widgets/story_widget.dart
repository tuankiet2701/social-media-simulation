import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_simulation/models/story.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/screens/story_screen/story_screen.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: StreamBuilder<QuerySnapshot>(
          stream: userChatsStream(firebaseAuth.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List chatList = snapshot.data!.docs;
              if (chatList.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  itemCount: chatList.length,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot storyListSnapshot = chatList[index];
                    return StreamBuilder<QuerySnapshot>(
                      stream: messageListStream(storyListSnapshot.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List stories = snapshot.data!.docs;
                          StoryModel story = StoryModel.fromJson(
                            stories.first.data(),
                          );
                          List users = storyListSnapshot.get('whoCanSee');
                          // remove the current user's id from the Users
                          // list so we can get the rest of the user's id
                          users.remove(firebaseAuth.currentUser!.uid);
                          return _buildstoryAvatar(
                            storyListSnapshot.get('userId'),
                            storyListSnapshot.id,
                            story.storyId!,
                            index,
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No Story'),
                );
              }
            } else {
              return circularProgress(context);
            }
          },
        ),
      ),
    );
  }

  _buildstoryAvatar(String userId, String chatId, String messageId, int index) {
    return StreamBuilder(
      stream: usersRef.doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot =
              snapshot.data as DocumentSnapshot<Object?>;
          UserModel user = UserModel.fromJson(
              documentSnapshot.data() as Map<String, dynamic>);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => StoryScreen(
                          initPage: index,
                          userId: userId,
                          storyId: chatId,
                          statusId: messageId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl!),
                      ),
                    ),
                  ),
                ),
                Text(
                  user.username!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Stream<QuerySnapshot> userChatsStream(String uid) {
    return storyRef.where('whoCanSee', arrayContains: uid).snapshots();
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return storyRef.doc(documentId).collection('stories').snapshots();
  }
}
