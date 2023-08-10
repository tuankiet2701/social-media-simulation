import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/components/chat_item.dart';
import 'package:social_media_simulation/models/message.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/view_model/user/user_view_model.dart';

class RecentChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserViewModel viewModel =
        Provider.of<UserViewModel>(context, listen: false);
    viewModel.setUser();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Ionicons.chevron_back),
          ),
          title: const Text(
            "Chats",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: userChatsStream(viewModel.user!.uid ?? ""),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List chatList = snapshot.data!.docs;
              if (chatList.isNotEmpty) {
                return ListView.separated(
                  itemCount: chatList.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot chatListSnapshot = chatList[index];
                    return StreamBuilder<QuerySnapshot>(
                      stream: messageListStream(chatListSnapshot.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List messages = snapshot.data!.docs;
                          Message message =
                              Message.fromJson(messages.first.data());
                          List users = chatListSnapshot.get('users');
                          //remove the current user's id from the Users
                          //list so we can get the second user's id
                          users.remove(viewModel.user!.uid ?? "");
                          String recipient = users[0];
                          return ChatItem(
                            userId: recipient,
                            messageCount: 0,
                            msg: message.content,
                            time: message.time,
                            chatId: chatListSnapshot.id,
                            type: message.type,
                            currentUserId: viewModel.user!.uid ?? "",
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 0.5,
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Divider(),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No Chats'),
                );
              }
            } else {
              return const Center(
                child: Text('No Chats'),
              );
            }
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> userChatsStream(String uid) {
    return chatRef
        .where('users', arrayContains: uid)
        // .orderBy('lastTextTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return chatRef
        .doc(documentId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }
}
