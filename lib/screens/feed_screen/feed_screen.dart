import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:social_media_simulation/models/post.dart';
import 'package:social_media_simulation/utils/constants.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/widgets/indicator.dart';
import 'package:social_media_simulation/widgets/story_widget.dart';
import 'package:social_media_simulation/widgets/user_post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  int page = 5;
  bool loadingMore = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          page = page + 5;
          loadingMore = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          Constants.appName,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Ionicons.chatbubble_ellipses,
              size: 30,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 20)
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () =>
            postRef.orderBy('timestamp', descending: true).limit(page).get(),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StoryWidget(),
              Container(
                height: MediaQuery.of(context).size.height - 220,
                child: StreamBuilder(
                  stream: firestore
                      .collection('posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: circularProgress(context),
                      );
                    } else if (snapshot.hasData) {
                      var snap = snapshot.data;
                      List docs = snap!.docs;
                      return ListView.builder(
                        itemCount: docs.length,
                        // controller: scrollController,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          PostModel posts =
                              PostModel.fromJson(docs[index].data());
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: UserPost(post: posts),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No Feeds',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
