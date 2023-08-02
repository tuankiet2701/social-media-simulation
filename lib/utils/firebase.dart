import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;
final Uuid uuid = Uuid();

//collection refs
CollectionReference usersRef = firestore.collection('users');
CollectionReference followersRef = firestore.collection('followers');
CollectionReference followingRef = firestore.collection('following');
CollectionReference postRef = firestore.collection('posts');
CollectionReference notificationRef = firestore.collection('notifications');
CollectionReference commentRef = firestore.collection('comments');
CollectionReference likesRef = firestore.collection('likes');
CollectionReference storyRef = firestore.collection('story');
CollectionReference chatRef = firestore.collection("chats");
CollectionReference chatIdRef = firestore.collection('chatIds');

//storage refs
Reference profilePic = storage.ref().child('profilePic');
Reference posts = storage.ref().child('posts');
Reference status = storage.ref().child('status');
