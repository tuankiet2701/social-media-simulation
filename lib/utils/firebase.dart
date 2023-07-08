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
CollectionReference storyRef = firestore.collection('posts');

//storage refs
Reference profilePic = storage.ref().child('profilePic');
