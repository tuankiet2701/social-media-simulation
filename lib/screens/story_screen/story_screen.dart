import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/models/story.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/view_model/story_view_model/story_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:social_media_simulation/widgets/indicator.dart';
import 'package:story/story.dart';

class StoryScreen extends StatefulWidget {
  final initPage;
  final statusId;
  final storyId;
  final userId;
  const StoryScreen({
    super.key,
    required this.initPage,
    required this.statusId,
    required this.storyId,
    required this.userId,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (value) {
          Navigator.pop(context);
        },
        child: FutureBuilder<QuerySnapshot>(
          future: storyRef.doc(widget.storyId).collection('stories').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: circularProgress(context),
              );
            } else if (snapshot.hasData) {
              List story = snapshot.data!.docs;
              return StoryPageView(
                indicatorPadding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                indicatorHeight: 1,
                initialPage: 0,
                onPageLimitReached: () {
                  Navigator.pop(context);
                },
                indicatorVisitedColor: Theme.of(context).colorScheme.secondary,
                indicatorDuration: const Duration(seconds: 30),
                itemBuilder: (context, pageIndex, storyIndex) {
                  StoryModel stories =
                      StoryModel.fromJson(story.toList()[storyIndex].data());
                  //we will get the list of all viewers for each story
                  //then add our id to the list if it does not exist
                  List<dynamic>? allViewers = stories.viewers;
                  if (allViewers!.contains(firebaseAuth.currentUser!.uid)) {
                    print('ID ALREADY EXIST');
                  } else {
                    allViewers.add(firebaseAuth.currentUser!.uid);
                    //update the viewCount for each status
                    storyRef
                        .doc(widget.storyId)
                        .collection('stories')
                        .doc(stories.storyId)
                        .update({'viewers': allViewers});
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: getImage(stories.url!),
                        ),
                        Positioned(
                          top: 65,
                          left: 10,
                          child: FutureBuilder(
                            future: usersRef.doc(widget.userId).get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                DocumentSnapshot documentSnapshot =
                                    snapshot.data as DocumentSnapshot<Object?>;
                                UserModel user = UserModel.fromJson(
                                    documentSnapshot.data()
                                        as Map<String, dynamic>);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.transparent),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  offset: const Offset(0, 0),
                                                  blurRadius: 2,
                                                  spreadRadius: 0),
                                            ]),
                                        child: Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.grey,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              user.photoUrl!,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        children: [
                                          Text(
                                            user.username!,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            timeago
                                                .format(stories.time!.toDate()),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                        Positioned(
                          bottom: widget.userId == firebaseAuth.currentUser!.uid
                              ? 10
                              : 30,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                color: Colors.grey.withOpacity(0.2),
                                width: MediaQuery.of(context).size.width,
                                constraints:
                                    const BoxConstraints(maxHeight: 50),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          stories.caption ?? '',
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              widget.userId == firebaseAuth.currentUser!.uid
                                  ? TextButton.icon(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 20,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      label: Text(
                                        stories.viewers!.length.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                storyLength: (int pageIndex) {
                  return story.length;
                },
                pageLength: 1,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  getImage(String url) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Image.network(url),
    );
  }
}
