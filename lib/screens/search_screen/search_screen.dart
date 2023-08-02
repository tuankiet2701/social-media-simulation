import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/screens/chat_screen/conversation.dart';
import 'package:social_media_simulation/screens/profile_screen/profile_screen.dart';
import 'package:social_media_simulation/utils/constants.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  User? user;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = firebaseAuth;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUser = [];
  bool loading = true;

  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  getUsers() async {
    QuerySnapshot snap = await usersRef.get();
    List<DocumentSnapshot> doc = snap.docs;
    users = doc;
    filteredUser = doc;
    setState(() {
      loading = false;
    });
  }

  search(String query) {
    if (query == "") {
      filteredUser = users;
    } else {
      List userSearch = users.where((userSnap) {
        Map user = userSnap.data() as Map<String, dynamic>;
        String username = user['username'];
        return username.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        filteredUser = userSearch as List<DocumentSnapshot<Object?>>;
      });
    }
  }

  removeFromList(index) {
    filteredUser.removeAt(index);
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          Constants.appName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () => getUsers(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: buildSearch(),
            ),
            buildUser(),
          ],
        ),
      ),
    );
  }

  buildSearch() {
    return Row(
      children: [
        Container(
          height: 30,
          width: MediaQuery.of(context).size.width - 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: TextFormField(
              controller: searchController,
              textAlignVertical: TextAlignVertical.center,
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              textCapitalization: TextCapitalization.sentences,
              onChanged: (query) {
                search(query);
              },
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    searchController.clear();
                  },
                  child: searchController.text.isNotEmpty
                      ? Icon(
                          Ionicons.close_outline,
                          size: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : Icon(
                          Ionicons.search,
                          size: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                ),
                border: InputBorder.none,
                counterText: '',
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        )
      ],
    );
  }

  buildUser() {
    if (!loading) {
      if (searchController.text.isEmpty) {
        return const Center(
          child: Text(''),
        );
      } else {
        if (filteredUser.isEmpty) {
          return const Center(
            child: Text(
              'No User Found',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else {
          return Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: filteredUser.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot doc = filteredUser[index];
                  UserModel user =
                      UserModel.fromJson(doc.data() as Map<String, dynamic>);
                  return ListTile(
                    onTap: () => showProfile(context, profileId: user.id),
                    leading: user.photoUrl!.isEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: Center(
                              child: Text(
                                user.username![0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                CachedNetworkImageProvider('${user.photoUrl}'),
                          ),
                    title: Text(
                      user.username!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(user.email!),
                    trailing: doc.id != currentUserId()
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => StreamBuilder(
                                    stream: chatIdRef
                                        .where(
                                          'users',
                                          isEqualTo: getUser(
                                            firebaseAuth.currentUser!.uid,
                                            doc.id,
                                          ),
                                        )
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: circularProgress(context),
                                        );
                                      } else if (snapshot.hasData) {
                                        var snap = snapshot.data;
                                        List docs = snap!.docs;
                                        print(snapshot.data!.docs.toString());
                                        return docs.isEmpty
                                            ? Conversation(
                                                userId: doc.id,
                                                chatId: 'newChat',
                                              )
                                            : Conversation(
                                                userId: doc.id,
                                                chatId: docs[0]
                                                    .get('chatId')
                                                    .toString(),
                                              );
                                      }
                                      return Conversation(
                                        userId: doc.id,
                                        chatId: 'newChat',
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 30,
                              width: 62,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    'Message',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
          );
        }
      }
    } else {
      return Center(
        child: circularProgress(context),
      );
    }
  }

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => ProfileScreen(profileId: profileId),
      ),
    );
  }

  String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    var chatId = "${list[0]} - ${list[1]}";
    return chatId;
  }

  @override
  bool get wantKeepAlive => true;
}
