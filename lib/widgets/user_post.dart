import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:social_media_simulation/components/custom_card.dart';
import 'package:social_media_simulation/components/custom_image.dart';
import 'package:social_media_simulation/models/post.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/screens/comment_screen/comment_screen.dart';
import 'package:social_media_simulation/screens/profile_screen/profile_screen.dart';
import 'package:social_media_simulation/screens/view_image/view_image.dart';
import 'package:social_media_simulation/services/post_service.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:like_button/like_button.dart';

class UserPost extends StatelessWidget {
  final PostModel? post;
  UserPost({super.key, this.post});

  final DateTime timestamp = DateTime.now();

  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  final PostService service = PostService();

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        child: OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          openBuilder: (BuildContext context, VoidCallback _) {
            return ViewImage(post: post);
          },
          closedElevation: 0,
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          // onClosed: (e) {},
          closedColor: Theme.of(context).cardColor,
          closedBuilder: (BuildContext context, VoidCallback openContainer) {
            return Stack(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                CachedNetworkImageProvider(post!.userDp!),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post!.username!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.more_vert),
                        //   onPressed: () {
                        //     showDialog(
                        //       useRootNavigator: false,
                        //       context: context,
                        //       builder: (context) {
                        //         return Dialog(
                        //           child: ListView(
                        //             shrinkWrap: true,
                        //             padding: const EdgeInsets.symmetric(
                        //                 vertical: 16),
                        //             children: ['Delete']
                        //                 .map(
                        //                   (e) => InkWell(
                        //                     onTap: () async {
                        //                       try {
                        //                         await firestore
                        //                             .collection('posts')
                        //                             .doc(post!.postId)
                        //                             .delete();
                        //                       } catch (e) {
                        //                         print(e);
                        //                       }
                        //                       Navigator.of(context).pop();
                        //                     },
                        //                     child: Container(
                        //                       padding:
                        //                           const EdgeInsets.symmetric(
                        //                         vertical: 12,
                        //                         horizontal: 16,
                        //                       ),
                        //                       child: Text(e),
                        //                     ),
                        //                   ),
                        //                 )
                        //                 .toList(),
                        //           ),
                        //         );
                        //       },
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: CustomImage(
                        imageUrl: post!.mediaUrl ?? '',
                        height: 350,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                buildLikeButton(),
                                const SizedBox(width: 18),
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            CommentScreen(post: post),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    CupertinoIcons.chat_bubble,
                                    size: 25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: StreamBuilder(
                                    stream: likesRef
                                        .where('postId',
                                            isEqualTo: post!.postId)
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot snap = snapshot.data!;
                                        List<DocumentSnapshot> docs = snap.docs;
                                        return buildLikesCount(
                                            context, docs.length);
                                      } else {
                                        return buildLikesCount(context, 0);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              StreamBuilder(
                                stream: commentRef
                                    .doc(post!.postId)
                                    .collection('comments')
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    QuerySnapshot snap = snapshot.data!;
                                    List<DocumentSnapshot> docs = snap.docs;
                                    return buildCommentsCount(
                                        context, docs.length);
                                  } else {
                                    return buildCommentsCount(context, 0);
                                  }
                                },
                              ),
                            ],
                          ),
                          Visibility(
                            visible: post!.description != null &&
                                post!.description.toString().isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, top: 3),
                              child: Text(
                                post!.description ?? '',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .color,
                                  fontSize: 15,
                                ),
                                maxLines: null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: Text(
                              timeago.format(post!.timestamp!.toDate()),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: post!.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs ?? [];
          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              likesRef.add({
                'userId': currentUserId(),
                'postId': post!.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification();
              return !isLiked;
            } else {
              likesRef.doc(docs[0].id).delete();
              service.removeLikeFromNotification(
                  post!.ownerId!, post!.postId!, currentUserId());
              return isLiked;
            }
          }

          return LikeButton(
            onTap: onLikeButtonTapped,
            size: 25,
            circleColor: const CircleColor(
                start: Color(0xFFFFC0CB), end: Color(0xFFFF0000)),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color(0xffFFA500),
              dotSecondaryColor: Color(0xffd8392b),
              dotThirdColor: Color(0xffFF69B4),
              dotLastColor: Color(0xffff8c00),
            ),
            likeBuilder: (bool isLiked) {
              return Icon(
                docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                color: docs.isEmpty
                    ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black
                    : Colors.red,
                size: 25,
              );
            },
          );
        }
        return Container();
      },
    );
  }

  addLikesToNotification() async {
    bool isNotMe = currentUserId() != post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      service.addLikeToNotification(
        'like',
        user!.username!,
        currentUserId(),
        post!.postId!,
        post!.mediaUrl!,
        post!.ownerId!,
        user!.photoUrl!,
      );
    }
  }

  buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7),
      child: Text(
        '$count likes',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.5),
      child: Text(
        ' $count comments',
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  buildUser(BuildContext context) {
    bool isMe = currentUserId() == post!.ownerId;
    return StreamBuilder(
      stream: usersRef.doc(post!.ownerId).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot snap = snapshot.data!;
          UserModel user =
              UserModel.fromJson(snap.data() as Map<String, dynamic>);
          return Visibility(
            visible: !isMe,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => showProfile(context, profileId: user.id!),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        user.photoUrl!.isEmpty
                            ? CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: Center(
                                  child: Text(
                                    user.username![0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 29,
                                backgroundImage:
                                    CachedNetworkImageProvider(user.photoUrl!),
                              ),
                        const SizedBox(width: 5),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post!.username ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              post!.location ?? "",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF4D4D4D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress(context);
        }
        return Container();
      },
    );
  }

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => ProfileScreen(profileId: profileId),
      ),
    );
  }
}
