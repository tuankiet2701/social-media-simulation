import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_simulation/models/enum/message_type.dart';

class StoryModel {
  String? caption;
  String? url;
  String? story;
  String? storyId;
  MessageType? type;
  List<dynamic>? viewers;
  Timestamp? time;

  StoryModel({
    this.caption,
    this.url,
    this.storyId,
    this.time,
    this.type,
    this.viewers,
  });

  StoryModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    caption = json['caption'];
    storyId = json['storyId'];
    viewers = json['viewers'];
    if (json['type'] == 'text') {
      type = MessageType.TEXT;
    } else {
      type = MessageType.IMAGE;
    }
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['caption'] = this.caption;
    data['storyId'] = this.storyId;
    data['viewers'] = this.viewers;
    data['url'] = this.url;
    if (this.type == MessageType.TEXT) {
      data['type'] = 'text';
    } else {
      data['type'] = 'image';
    }
    data['time'] = this.time;
    return data;
  }
}
