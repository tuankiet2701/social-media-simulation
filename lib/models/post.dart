import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id;
  String? postId;
  String? ownerId;
  String? userDp;
  String? username;
  String? location;
  String? description;
  String? mediaUrl;
  Timestamp? timestamp;

  PostModel({
    this.id,
    this.postId,
    this.ownerId,
    this.userDp,
    this.location,
    this.description,
    this.mediaUrl,
    this.username,
    this.timestamp,
  });
  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    ownerId = json['ownerId'];
    location = json['location'];
    username = json['username'];
    description = json['description'];
    mediaUrl = json['mediaUrl'];
    userDp = json['userDp'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['postId'] = this.postId;
    data['ownerId'] = this.ownerId;
    data['location'] = this.location;
    data['description'] = this.description;
    data['mediaUrl'] = this.mediaUrl;
    data['userDp'] = this.userDp;
    data['timestamp'] = this.timestamp;
    data['username'] = this.username;
    return data;
  }
}
