import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_simulation/components/stream_comments_wrapper.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

class ActivityStreamWrapper extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>? stream;
  final ItemBuilder<DocumentSnapshot> itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsets padding;
  const ActivityStreamWrapper({
    super.key,
    this.stream,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2, left: 2),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data!.docs.toList();
          return list.length == 0
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 250),
                    child: Text('No Recent Activities'),
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 0.5,
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: const Divider(),
                      ),
                    );
                  },
                  padding: padding,
                  scrollDirection: scrollDirection,
                  itemCount: list.length,
                  shrinkWrap: shrinkWrap,
                  physics: physics,
                  itemBuilder: (BuildContext context, int index) {
                    return itemBuilder(context, list[index]);
                  },
                );
        } else {
          return circularProgress(context);
        }
      },
    );
  }
}
