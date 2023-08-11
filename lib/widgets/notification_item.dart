import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_simulation/models/notification.dart';
import 'package:social_media_simulation/models/post.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/screens/profile_screen/profile_screen.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/indicator.dart';
import 'package:social_media_simulation/widgets/view_notification_details.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItem extends StatefulWidget {
  final NotificationModel? notifications;
  final UserModel? user;
  final PostModel? post;
  const NotificationItem({super.key, this.notifications, this.user, this.post});

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey("${widget.notifications}"),
      background: stackBehindDismiss(),
      direction: DismissDirection.endToStart,
      onDismissed: (v) {
        delete();
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => widget.notifications!.type == "follow"
                  ? ProfileScreen(profileId: widget.notifications!.userId)
                  : ViewNotificationDetails(
                      notifications: widget.notifications),
            ),
          );
        },
        leading: widget.notifications!.userDp!.isEmpty
            ? CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  widget.notifications!.username![0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              )
            : CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                  widget.notifications!.userDp!,
                ),
              ),
        title: RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 14),
            children: [
              TextSpan(
                text: widget.notifications!.username!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              TextSpan(
                text: buildTextConfiguration(),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
        subtitle: Text(
          timeago.format(widget.notifications!.timestamp!.toDate()),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: widget.notifications!.type == "like" ||
                widget.notifications!.type == "comment"
            ? CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(
                  widget.notifications!.mediaUrl!,
                ),
              )
            : null,
      ),
    );
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: Theme.of(context).colorScheme.secondary,
      child: const Icon(
        CupertinoIcons.delete,
        color: Colors.white,
      ),
    );
  }

  delete() {
    notificationRef
        .doc(firebaseAuth.currentUser!.uid)
        .collection('notifications')
        .doc(widget.notifications!.postId)
        .get()
        .then((doc) => {
              if (doc.exists) {doc.reference.delete()}
            });
  }

  previewConfiguration() {
    if (widget.notifications!.type == 'like' ||
        widget.notifications!.type == 'comment') {
      return buildPreviewImage();
    } else {
      return const Text('');
    }
  }

  buildTextConfiguration() {
    if (widget.notifications!.type! == 'like') {
      return ' liked your post';
    } else if (widget.notifications!.type! == 'follow') {
      return ' is following you';
    } else if (widget.notifications!.type! == 'comment') {
      return ' commented ${widget.notifications!.commentData}';
    } else {
      return 'Error: Unknown type ${widget.notifications!.type}';
    }
  }

  buildPreviewImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: CachedNetworkImage(
        imageUrl: widget.notifications!.mediaUrl!,
        placeholder: (context, url) {
          return circularProgress(context);
        },
        errorWidget: (context, url, error) {
          return const Icon(Icons.error);
        },
        height: 40,
        fit: BoxFit.cover,
        width: 40,
      ),
    );
  }
}
