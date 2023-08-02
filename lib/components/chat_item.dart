import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:social_media_simulation/models/enum/message_type.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final String? userId;
  final Timestamp? time;
  final String? msg;
  final int? messageCount;
  final String? chatId;
  final MessageType? type;
  final String? currentUserId;
  const ChatItem({
    super.key,
    @required this.userId,
    @required this.time,
    @required this.msg,
    @required this.messageCount,
    @required this.chatId,
    @required this.type,
    @required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usersRef.doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress(context);
        } else if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot =
              snapshot.data as DocumentSnapshot<Object?>;
          UserModel user = UserModel.fromJson(
              documentSnapshot.data() as Map<String, dynamic>);
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: Stack(
              children: <Widget>[
                user.photoUrl == null || user.photoUrl!.isEmpty
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
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            CachedNetworkImageProvider('${user.photoUrl}'),
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    height: 11,
                    width: 11,
                  ),
                ),
              ],
            ),
            title: Text(
              '${user.username}',
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              type == MessageType.IMAGE ? 'IMAGE' : '$msg',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const SizedBox(height: 10),
                Text(
                  timeago.format(time!.toDate()),
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                buildCounter(context),
              ],
            ),
            onTap: () {},
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  buildCounter(BuildContext context) {
    return StreamBuilder(
      stream: messageBodyStream(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress(context);
        } else if (snapshot.hasData) {
          DocumentSnapshot snap = snapshot.data;
          final bool hasScore = snapshot.data!.data()!.containsKey('reads');
          Map usersReads = hasScore ? snap.get('reads') ?? {} : {};
          int readCount = usersReads[currentUserId] ?? 0;
          int counter = messageCount! - readCount;
          if (counter == 0) {
            return const SizedBox();
          } else {
            return Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 11,
                minHeight: 11,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 1, left: 5, right: 5),
                child: Text(
                  '$counter',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Stream<DocumentSnapshot> messageBodyStream() {
    return chatRef.doc(chatId).snapshots();
  }
}
