import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:social_media_simulation/models/notification.dart';
import 'package:social_media_simulation/screens/profile_screen/profile_screen.dart';
import 'package:social_media_simulation/widgets/indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewNotificationDetails extends StatefulWidget {
  final NotificationModel? notifications;

  const ViewNotificationDetails({this.notifications});

  @override
  _ViewNotificationDetailsState createState() =>
      _ViewNotificationDetailsState();
}

class _ViewNotificationDetailsState extends State<ViewNotificationDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.keyboard_backspace),
        ),
      ),
      body: ListView(
        children: [
          buildImage(context),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => ProfileScreen(
                          profileId: widget.notifications!.userId),
                    ));
              },
              child: CircleAvatar(
                radius: 25.0,
                backgroundImage: NetworkImage(widget.notifications!.userDp!),
              ),
            ),
            title: Text(
              widget.notifications!.username!,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Row(
              children: [
                const Icon(Ionicons.alarm_outline, size: 13.0),
                const SizedBox(width: 3.0),
                Text(
                  timeago.format(widget.notifications!.timestamp!.toDate()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              widget.notifications?.commentData ?? "",
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: CachedNetworkImage(
          imageUrl: widget.notifications!.mediaUrl!,
          placeholder: (context, url) {
            return circularProgress(context);
          },
          errorWidget: (context, url, error) {
            return const Icon(Icons.error);
          },
          height: 400.0,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}
