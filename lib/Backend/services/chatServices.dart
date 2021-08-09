import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Backend/models/chatModel.dart';
import 'package:ioc_chatbot/Backend/models/messagesModel.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';


class AdvisorChatServices {


  ///Start Chat
  Future<DocumentReference> startChat(
      BuildContext context, ChatModel model) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('advisorChat').doc(model.chatID);
    await docRef.set(model.toJson());
    return docRef;
  }


  ///Start Messages
  Future<void> startMessage(BuildContext context,
      {MessagesModel model, String chatID}) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('advisorChat')
        .doc(chatID)
        .collection('messages')
        .doc();
    return await docRef.set(model.toJson(docRef.id));
  }



  ///Get Chats List, where chat bond is made between send to and sent by (MY SIDE)
  Stream<List<ChatModel>> getChatLis(BuildContext context, {String docID}) {
    return FirebaseFirestore.instance
        .collection('advisorChat')
        .where('users', arrayContains: docID)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => ChatModel.fromJson(e.data())).toList());
  }



  ///Get Messages in Message Screen
  Stream<List<MessagesModel>> getMessages(BuildContext context, String chatID) {
    return FirebaseFirestore.instance
        .collection('advisorChat')
        .doc(chatID)
        .collection('messages')
        .orderBy('time')
        .snapshots()
        .map((event) =>
            event.docs.map((e) => MessagesModel.fromJson(e.data())).toList());
  }


  /// Get Unread Messages to Read OF A SPECIFIC USER in message Screen
  Stream<List<MessagesModel>> getMessagesToRead(
      BuildContext context, String chatID, UserModel model) {
    print("MY ID: ${model.docID}");
    return FirebaseFirestore.instance
        .collection('advisorChat')
        .doc(chatID)
        .collection('messages')
    // .where('isRead', isEqualTo: false)

    ///sendTo_sendBy chatId
        .where('sendID', isEqualTo: model.docID)
        .snapshots()
        .map((event) =>
        event.docs.map((e) => MessagesModel.fromJson(e.data())).toList());
  }



  ///Get Unread Messages Count
  Stream<List<MessagesModel>> getUnreadMessagesCount(
      BuildContext context, String chatID, UserModel model) {
    print("HI ${model.docID}");
    return FirebaseFirestore.instance
        .collection('advisorChat')
        .doc(chatID)
        .collection('messages')
        .where('isRead', isEqualTo: false)

        .where('sendID', isNotEqualTo: model.docID)

        .snapshots()
        .map((event) =>
            event.docs.map((e) => MessagesModel.fromJson(e.data())).toList());
  }




  ///Mark Message as Read
  Future<void> markMessageAsRead(BuildContext context, String chatID,
      UserModel model, String docID) async {
    print("Advisor : $docID");
    return await FirebaseFirestore.instance
        .collection('advisorChat')
        .doc(chatID)
        .collection('messages')
        .doc(docID)
        .update({'isRead': true});
  }


}
