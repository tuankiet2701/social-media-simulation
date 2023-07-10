import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/components/custom_image.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/screens/post_screen/post_view_model/post_view_model.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  @override
  Widget build(BuildContext context) {
    currentUserId() {
      return firebaseAuth.currentUser!.uid;
    }

    PostViewModel viewModel = Provider.of<PostViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        await viewModel.resetPost();
        return true;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Ionicons.close_outline),
              onPressed: () {
                viewModel.resetPost();
                Navigator.pop(context);
              },
            ),
            title: Text('Milo'.toUpperCase()),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                  await viewModel.uploadPosts(context);
                  Navigator.pop(context);
                  viewModel.resetPost();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Post'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 15),
            children: [
              const SizedBox(height: 15),
              StreamBuilder(
                stream: usersRef.doc(currentUserId()).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(
                        snapshot.data!.data() as Map<String, dynamic>);
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(user.photoUrl!),
                      ),
                      title: Text(
                        user.username!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user.email!),
                    );
                  }
                  return Container();
                },
              ),
              InkWell(
                onTap: () => showImageChoice(context, viewModel),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  child: viewModel.imgLink != null
                      ? CustomImage(
                          imageUrl: viewModel.imgLink,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - 30,
                          fit: BoxFit.cover,
                        )
                      : viewModel.mediaUrl == null
                          ? Center(
                              child: Text(
                                'Upload a Photo',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            )
                          : Image.file(
                              viewModel.mediaUrl!,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width - 30,
                              fit: BoxFit.cover,
                            ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Post Caption'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: viewModel.description,
                decoration: const InputDecoration(
                  hintText: 'Eg. This is very beautiful place!',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (value) => viewModel.setDescription(value),
              ),
              const SizedBox(height: 20),
              Text(
                'Location'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Container(
                  width: 250,
                  child: TextFormField(
                    controller: viewModel.locationTEC,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        hintText: 'Ho Chi Minh, Viet Nam!',
                        focusedBorder: UnderlineInputBorder()),
                    maxLines: null,
                    onChanged: (value) => viewModel.setLocation(value),
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Use your current location',
                  icon: const Icon(CupertinoIcons.map_pin_ellipse, size: 25),
                  iconSize: 30,
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () => viewModel.getLocation(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showImageChoice(BuildContext context, PostViewModel viewModel) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: .6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Select Image',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Ionicons.camera_outline),
                  title: Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickImage(camera: true);
                  },
                ),
                ListTile(
                  leading: Icon(Ionicons.image),
                  title: Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickImage();
                  },
                ),
              ],
            ),
          );
        });
  }
}
