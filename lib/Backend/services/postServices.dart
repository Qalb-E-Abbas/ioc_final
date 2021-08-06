import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Backend/models/postModel.dart';
import 'package:ioc_chatbot/Logics/app_state.dart';

import 'package:provider/provider.dart';

class PostServices {
  CollectionReference _postCollection =
      FirebaseFirestore.instance.collection('postCollection');

  ///Create Post
  Future<void> createPost(BuildContext context, {PostModel model}) async {
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsBusy);
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('postCollection').doc();
    await docRef.set(model.toJson(docRef.id));
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsFree);
  }

  ///Get Post
  Stream<List<PostModel>> streamSubjectPosts(
      String teacherID, List subject, String section) {
    print("HI ${section}");
    return _postCollection
        .where('subject', whereIn: subject)
        .where('section', isEqualTo: section)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => PostModel.fromJson(e.data())).toList());
  }

  ///Get Post
  Stream<List<PostModel>> streamPosts(String advID) {
    print("Adv ID : ${advID}");
    return _postCollection
        .where('advID', isEqualTo: advID)
        .where('section', isEqualTo: "-1")
        .orderBy('sortTime', descending: true)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => PostModel.fromJson(e.data())).toList());
  }

  Stream<List<PostModel>> getAdvNotificationCounter(String uid, String advID) {
    return _postCollection
        .where('advID', isEqualTo: advID)
        .where('section', isEqualTo: "-1")
        .where('users', arrayContains: uid)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => PostModel.fromJson(e.data())).toList());
  }

  Stream<List<PostModel>> getSubjectNotificationCounter(
      String uid, List subject, String section) {
    print("Subject ID : $subject");
    return _postCollection
        .where('subject', whereIn: subject)
        .where('users', arrayContains: uid)
        .where('section', isEqualTo: section)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => PostModel.fromJson(e.data())).toList());
  }

  ///Update Post
  Future<void> updatePost(BuildContext context,
      {String postID,
      String postText,
      String postImage,
      String postImageName}) async {
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsBusy);
    await _postCollection.doc(postID).update({
      'postText': postText,
      'postImage': postImage,
      'postImageName': postImageName
    });
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsFree);
  }

  ///Delete Post
  Future<void> deletePost(BuildContext context, {String postID}) async {
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsBusy);
    await _postCollection.doc(postID).delete();
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsFree);
  }

  ///Mark Notification as Read
  Future<void> markNotificationAsRead(String uid, String notifiID) async {
    return FirebaseFirestore.instance
        .collection('postCollection')
        .doc(notifiID)
        .update({
      'users': FieldValue.arrayUnion([uid])
    });
  }
}
