import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/screens/create_post_screen/create_post.dart';
import 'package:social_media_simulation/view_model/story_view_model/story_view_model.dart';

class FabContainer extends StatelessWidget {
  final Widget? page;
  final IconData icon;
  final bool mini;
  const FabContainer(
      {super.key, this.page, required this.icon, this.mini = false});

  @override
  Widget build(BuildContext context) {
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return page!;
      },
      closedElevation: 4,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(56 / 2),
        ),
      ),
      closedColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            chooseUpload(context, viewModel);
          },
          mini: mini,
        );
      },
    );
  }

  chooseUpload(BuildContext context, StoryViewModel viewModel) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: .4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      'Choose Upload',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.camera_on_rectangle,
                    size: 25,
                  ),
                  title: Text('Make a Post'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => CreatePost(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.camera_on_rectangle,
                    size: 25,
                  ),
                  title: Text('Add to Story'),
                  onTap: () async {
                    await viewModel.pickImage(context: context);
                  },
                )
              ],
            ),
          );
        });
  }
}
