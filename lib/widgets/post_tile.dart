import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_simulation/models/post.dart';
import 'package:social_media_simulation/screens/view_image/view_image.dart';
import 'package:social_media_simulation/widgets/cached_image.dart';

class PostTile extends StatefulWidget {
  final PostModel? post;
  const PostTile({super.key, this.post});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ViewImage(
              post: widget.post,
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        width: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(3),
            ),
            child: cachedNetworkImage(widget.post!.mediaUrl!),
          ),
        ),
      ),
    );
  }
}
