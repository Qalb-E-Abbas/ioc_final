import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Backend/models/chatModel.dart';
import 'package:ioc_chatbot/Backend/models/messagesModel.dart';
import 'package:ioc_chatbot/Backend/services/chatServices.dart';


class ChatBusinessLogic {

  AdvisorChatServices _advisorChatServices = AdvisorChatServices();

  ///Create New Chat
  Future<void> initChat(BuildContext context,
      {String chatID, MessagesModel model}) async {
    _advisorChatServices
        .startChat(
            context,
            ChatModel(lastMessage: model.messageBody, chatID: chatID, users: [
              chatID.split("_")[0],
              chatID.split("_")[1],
            ]))
        .then((value) => _advisorChatServices.startMessage(context,
            model: model, chatID: value.id));
  }
}
