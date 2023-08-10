import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/components/chat_bubble.dart';
import 'package:social_media_simulation/models/enum/message_type.dart';
import 'package:social_media_simulation/models/message.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/screens/profile_screen/profile_screen.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/view_model/chat_view_model/chat_view_model.dart';
import 'package:social_media_simulation/view_model/user/user_view_model.dart';
import 'package:social_media_simulation/widgets/indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class Conversation extends StatefulWidget {
  final String userId;
  final String chatId;
  const Conversation({super.key, required this.userId, required this.chatId});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  bool isFirst = false;
  String? chatId;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      focusNode.unfocus();
    });
    if (widget.chatId == 'newChat') {
      isFirst = true;
    }
    chatId = widget.chatId;

    // messageController.addListener(
    //   () {
    //     if (focusNode.hasFocus && messageController.text.isNotEmpty) {
    //       setTyping(true);
    //     } else if (!focusNode.hasFocus ||
    //         (focusNode.hasFocus && messageController.text.isEmpty)) {
    //       setTyping(false);
    //     }
    //   },
    // );
  }

  // setTyping(typing) {
  //   UserViewModel viewmodel =
  //       Provider.of<UserViewModel>(context, listen: false);
  //   viewmodel.setUser();
  //   var user = Provider.of<UserViewModel>(context, listen: false).user;
  //   Provider.of<ChatViewModel>(context, listen: false)
  //       .setUserTyping(widget.chatId, user, typing);
  // }

  @override
  Widget build(BuildContext context) {
    UserViewModel viewModel = Provider.of<UserViewModel>(context);
    viewModel.setUser();
    var user = Provider.of<UserViewModel>(context, listen: true).user;
    return SafeArea(
      child: Consumer<ChatViewModel>(
        builder: (BuildContext context, viewModel, Widget? child) {
          return Scaffold(
            key: viewModel.scaffoldKey,
            appBar: AppBar(
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Ionicons.chevron_back),
              ),
              elevation: 0,
              titleSpacing: 0,
              title: buildUserName(),
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: messageListStream(widget.chatId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: circularProgress(context),
                          );
                        } else if (snapshot.hasData) {
                          List messages = snapshot.data!.docs;
                          // viewModel.setReadCount(
                          //     widget.chatId, user, messages.length);
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: messages.length,
                            reverse: true,
                            itemBuilder: (BuildContext context, int index) {
                              Message message = Message.fromJson(
                                  messages.reversed.toList()[index].data());
                              return ChatBubbleWidget(
                                message: message.content,
                                time: message.time!,
                                isMe: message.senderUid == user!.uid,
                                type: message.type!,
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: circularProgress(context),
                          );
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BottomAppBar(
                      elevation: 10,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(CupertinoIcons.photo_on_rectangle),
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: () =>
                                  showPhotoOptions(viewModel, user),
                            ),
                            Flexible(
                              child: TextField(
                                controller: messageController,
                                focusNode: focusNode,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .color,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  enabledBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  hintText: 'Type your message',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .color,
                                  ),
                                ),
                                maxLines: null,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Ionicons.send,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                if (messageController.text.isNotEmpty) {
                                  sendMessage(viewModel, user);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _buildOnlineText(var user, bool isTyping) {
    if (user.isOnline) {
      if (isTyping) {
        return 'typing...';
      } else {
        return 'online';
      }
    } else {
      return 'last seen ${timeago.format(user.lastSeen.toDate())}';
    }
  }

  buildUserName() {
    return StreamBuilder(
      stream: usersRef.doc(widget.userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot =
              snapshot.data as DocumentSnapshot<Object?>;
          UserModel user = UserModel.fromJson(
              documentSnapshot.data() as Map<String, dynamic>);
          return InkWell(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Hero(
                    tag: user.email!,
                    child: user.photoUrl!.isEmpty
                        ? CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: Center(
                              child: Text(
                                user.username![0],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 25,
                            backgroundImage: CachedNetworkImageProvider(
                              '${user.photoUrl}',
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.username!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(user.email!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ))
                      // StreamBuilder(
                      //   stream: chatRef.doc(widget.chatId).snapshots(),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState ==
                      //         ConnectionState.waiting) {
                      //       return Center(
                      //         child: circularProgress(context),
                      //       );
                      //     } else if (snapshot.hasData) {
                      //       DocumentSnapshot? snap =
                      //           snapshot.data as DocumentSnapshot<Object?>;
                      //       Map? data = snap.data() as Map<String, dynamic>?;
                      //       Map? usersTyping = data?['typing'] ?? {};
                      //       // return Text(
                      //       //   _buildOnlineText(
                      //       //       user, usersTyping![widget.userId] ?? false),
                      //       //   style: const TextStyle(
                      //       //     fontWeight: FontWeight.w400,
                      //       //     fontSize: 11,
                      //       //   ),
                      //       // );
                      //       return Text('123');
                      //     } else {
                      //       return const SizedBox();
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => ProfileScreen(profileId: user.id),
                ),
              );
            },
          );
        } else {
          return Center(
            child: circularProgress(context),
          );
        }
      },
    );
  }

  showPhotoOptions(ChatViewModel viewModel, var user) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Camera'),
                onTap: () {
                  sendMessage(viewModel, user, imageType: 0, isImage: true);
                },
              ),
              ListTile(
                title: Text('Gallery'),
                onTap: () {
                  sendMessage(viewModel, user, imageType: 1, isImage: true);
                },
              ),
            ],
          );
        });
  }

  sendMessage(
    ChatViewModel viewModel,
    var user, {
    bool isImage = false,
    int? imageType,
  }) async {
    String msg;
    if (isImage) {
      msg = await viewModel.pickImage(
        source: imageType!,
        context: context,
        chatId: widget.chatId,
      );
    } else {
      msg = messageController.text.trim();
      messageController.clear();
    }

    Message message = Message(
      content: msg,
      senderUid: user?.uid,
      type: isImage ? MessageType.IMAGE : MessageType.TEXT,
      time: Timestamp.now(),
    );

    if (msg.isNotEmpty) {
      if (isFirst) {
        String id = await viewModel.sendFirstMessage(widget.userId, message);
        setState(() {
          isFirst = false;
          chatId = id;
          //add the IDs of the two users to the chatID reference
          //the users map will be concatenation of the two users
          //involved in the chat
          chatIdRef.add({
            'users': getUser(firebaseAuth.currentUser!.uid, widget.userId),
            'chatId': id,
          });
          viewModel.sendMessage(widget.chatId, message);
        });
        //update the reads to an empty map in other to avoid null value bug
        chatRef.doc(chatId).update({'reads': {}});
        //update the typing to an empty map in other to avoid null value bug
        chatRef.doc(chatId).update({'typing': {}});
      } else {
        viewModel.sendMessage(
          widget.chatId,
          message,
        );
      }
    }
  }

  //this will concatenate the two users involved in the chat
  //and return a unique id, because firebase doesn't perform
  //some complex queries
  String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    var chatId = '${list[0]}-${list[1]}';
    return chatId;
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return chatRef
        .doc(documentId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }
}
