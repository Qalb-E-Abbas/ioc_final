
import 'package:flutter/cupertino.dart';
import 'package:ioc_chatbot/Backend/services/notificationServices.dart';

class NotificationHandler {
  NotificationServices _services = NotificationServices();

  ///Push 1-1 Notification
  oneToOneNotificationHelper(
      {@required String regNo, @required String body, @required String title}) {

    _services.streamSpecificUserToken(regNo).first.then((value) {
      print(value[0]);
      _services.pushOneToOneNotification(
        sendTo: value[0],
        title: title,
        body: body,
      );
    });
  }
}
