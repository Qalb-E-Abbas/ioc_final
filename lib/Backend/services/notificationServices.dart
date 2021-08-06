import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../configurations/back_end_configs.dart';

class NotificationServices {
  ///Push 1-1 Notification
  Future pushOneToOneNotification({
    @required String title,
    @required String body,
    @required String sendTo,
  }) async {
    print("I am sending to : $sendTo");
    return await http
        .post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "key=${BackEndConfigs.serverKey}"
            },
            body: json.encode({
              "notification": {"body": body, "title": title},
              "priority": "high",
              "data": {
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                "id": "1",
                "status": "done"
              },
              "to": sendTo
            }))
        .then((value) => print(value.reasonPhrase));
  }

  //
  Future pushBroadCastNotification({
    @required String title,
    @required String body,
    @required String department,
  }) async {
    String toParams = "/topics/" + department;
    return await http
        .post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "key=${BackEndConfigs.serverKey}"
            },
            body: json.encode({
              "notification": {"body": body, "title": title},
              "priority": "high",
              "data": {
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                "id": "1",
                "status": "done"
              },
              "to": "$toParams"
            }))
        .then((value) => print(value.statusCode));
  }

  ///Get One Specific User Token
  Stream<List> streamSpecificUserToken(String regNo) {
    print("Reg NO : $regNo");
    return FirebaseFirestore.instance
        .collection('deviceTokens')
        .where('regNo',isEqualTo: regNo)
        .snapshots()
        .map((event) {

      return event.docs.map((e) {

        return  e.data()['deviceTokens'];
      }).toList();
    });
  }
}
