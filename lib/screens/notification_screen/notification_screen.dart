import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_simulation/components/stream_notification_wrapper.dart';
import 'package:social_media_simulation/models/notification.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Notification',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: const Text(
                      'Clear Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'Do you want to clear all notifications?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => deleteAllItems(),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'No',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'CLEAR',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          getNotification(),
        ],
      ),
    );
  }

  getNotification() {
    return ActivityStreamWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      stream: notificationRef
          .doc(currentUserId())
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        NotificationModel notifications =
            NotificationModel.fromJson(snapshot.data() as Map<String, dynamic>);
        return NotificationItem(notifications: notifications);
      },
    );
  }

  deleteAllItems() async {
    //delete all notifications associated with the authenticated user
    QuerySnapshot notificationSnap = await notificationRef
        .doc(firebaseAuth.currentUser!.uid)
        .collection('notifications')
        .get();
    notificationSnap.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }
}
