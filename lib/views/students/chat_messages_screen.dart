import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/animation.dart';
import 'package:ioc_chatbot/Logics/applicationChatBznzLogic.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/horizontal_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';
import 'package:ioc_chatbot/Backend/models/messagesModel.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/chatServices.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/views/video.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChatMessageScreen extends StatefulWidget {
  final String sendToID;
  final String sendByID;
  final String chatID;
  final List<MessagesModel> messages;
  final String userID;

  ChatMessageScreen(
      {this.sendByID, this.sendToID, this.chatID, this.messages, this.userID});

  @override
  _ChatMessageScreenState createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  ChatBusinessLogic _advisorChatLogin = ChatBusinessLogic();
  AdvisorChatServices _advisorChatServices = AdvisorChatServices();

  TextEditingController messageController = TextEditingController();

  ScrollController _scrollController = new ScrollController();
  final _channelController = TextEditingController();
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;

  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
  UserModel advModel = UserModel();
  bool initialized = false;

  UserModel userModel = UserModel();
  DialogFlowtter dialogFlowtter;
  UserServices _userServices = UserServices();

  @override
  void dispose() {
    _channelController.dispose();
    // TODO: implement dispose
    // if (markReadMsjContext.watch<
    //         List<MessagesModel>>() !=
    //     null) if (markReadMsjContext.watch<List<MessagesModel>>().isNotEmpty)
    //   markReadMsjContext
    //       .watch<
    //           List<MessagesModel>>()
    //       .map((e) =>
    //           // print(e.messageBody)
    //           _advisorChatServices.markMessageAsRead(
    //               context,
    //               getChatID(),
    //               UserModel(
    //                   docID: widget
    //                       .userID),
    //               markReadMsjContext
    //                   .watch<
    //                       List<
    //                           MessagesModel>>()[
    //                       markReadMsjContext
    //                           .watch<
    //                               List<
    //                                   MessagesModel>>()
    //                           .indexOf(
    //                               e)]
    //                   .docID))
    //       .toList();

    if (widget.messages != null)
      widget.messages.map((e) {
        _advisorChatServices.markMessageAsRead(
            context, getChatID(), UserModel(docID: widget.userID), e.docID);
      }).toList();
    _userServices.changeOnlineStatus(
        userModel: UserModel(docID: getMyID()), isOnline: false);
    _userServices.updateLastSeen(
        userModel: UserModel(docID: getMyID()),
        time: "${DateTime.now().hour} : ${DateTime.now().minute}");
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.messages != null)
      widget.messages.map((e) {
        _advisorChatServices.markMessageAsRead(
            context, getChatID(), UserModel(docID: widget.userID), e.docID);
      }).toList();
    DialogFlowtter.fromFile(path: 'assets/services.json').then((instance) {
      dialogFlowtter = instance;
      print("Project ID: ${instance.credentials.projectId}");
      setState(() {});
    });
  }

  bool isTyping = false;

  @override
  Widget build(BuildContext context) {
    print("Chat ID : ${getChatID()}");

    _userServices.changeOnlineStatus(
        userModel: UserModel(docID: widget.userID), isOnline: true);
    return Scaffold(
      backgroundColor: Color(0xffF6F6F6),
      body: FutureBuilder(
          future: storage.ready,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!initialized) {
              var items =
                  storage.getItem(BackEndConfigs.userDetailsLocalStorage);
              var adv =
                  storage.getItem(BackEndConfigs.advisorDetailsLocalStorage);
              if (adv != null) {
                advModel = UserModel(
                  regNo: adv['regNo'],
                  semester: adv['semester'],
                  email: adv['email'],
                  firstName: adv['firstName'],
                  lastName: adv['lastName'],
                  docID: adv['docID'],
                  profilePic: adv['profilePic'],
                  gender: adv['gender'],
                  isOnline: adv['isOnline'],
                  role: adv['role'],
                );
              }
              if (items != null) {
                print(items);
                userModel = UserModel(
                  regNo: items['regNo'],
                  semester: items['semester'],
                  email: items['email'],
                  firstName: items['firstName'],
                  lastName: items['lastName'],
                  docID: items['docID'],
                  profilePic: items['profilePic'],
                  gender: items['gender'],
                );
              }

              initialized = true;
            }
            return snapshot.data == null ? LoadingWidget() : _getUI(context);
          }),
    );
  }

  Widget _getUI(BuildContext context) {
    return StreamProvider.value(
      value: _userServices.fetchStudentsData(getMyID()),
      builder: (ctxt, child) {
        return (ctxt.watch<UserModel>() == null
            ? LoadingWidget()
            : SafeArea(
                child: Scaffold(
                  body: Container(
                    child: Column(
                      children: [
                        Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            width: MediaQuery.of(context).size.width,
                            color: FrontEndConfigs.blueTextColor,
                            child: Center(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Image.asset(
                                          'assets/images/back.png',
                                          height: 26,
                                          width: 26,
                                        ),
                                      ),
                                      HorizontalSpace(15),
                                      GestureDetector(
                                        onTap: () {
                                          // Navigator.of(context).push(
                                          //     MaterialPageRoute(
                                          //         builder: (_) => TeacherProfileView(widget.image)
                                          //     ));
                                        },
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(ctxt
                                                  .watch<UserModel>()
                                                  .profilePic ??
                                              ""),
                                        ),
                                      ),
                                      HorizontalSpace(10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            DynamicFontSize(
                                              label: ctxt
                                                      .watch<UserModel>()
                                                      .firstName +
                                                  " " +
                                                  ctxt
                                                      .watch<UserModel>()
                                                      .lastName,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            VerticalSpace(2),
                                            DynamicFontSize(
                                              label: ctxt
                                                      .watch<UserModel>()
                                                      .isOnline
                                                  ? "Online"
                                                  : ctxt
                                                      .watch<UserModel>()
                                                      .lastSeen,
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: onJoin,
                                        child: Icon(
                                          Icons.call,
                                          color: Colors.black,
                                          size: 24,
                                        ),
                                      )
                                    ],
                                  ),
                                ]))),
                        Expanded(
                          child: Container(
                            child: StreamProvider.value(
                              value: _advisorChatServices.getMessages(
                                  context, getChatID()),
                              builder: (msjContext, child) {
                                return StreamProvider.value(
                                  value: _advisorChatServices.getMsjsToRead(
                                      context,
                                      getChatID(),
                                      UserModel(docID: getMyID())),
                                  builder: (markReadMsjContext, child) {
                                    Timer(
                                        Duration(milliseconds: 300),
                                        () => _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(milliseconds: 700),
                                            curve: Curves.ease));
                                    return msjContext
                                                .watch<List<MessagesModel>>() ==
                                            null
                                        ? LoadingWidget()
                                        : ListView.builder(
                                            controller: _scrollController,
                                            itemCount: msjContext
                                                .watch<List<MessagesModel>>()
                                                .length,
                                            itemBuilder: (context, i) {
                                              return MessageTile(
                                                message: msjContext
                                                    .watch<
                                                        List<
                                                            MessagesModel>>()[i]
                                                    .messageBody,
                                                sendByMe: msjContext
                                                        .watch<
                                                            List<
                                                                MessagesModel>>()[
                                                            i]
                                                        .sendID ==
                                                    userModel.docID,
                                                time: "12:00",
                                              );
                                            });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        TypingIndicator(
                          showIndicator: isTyping,
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 13),
                                  controller: messageController,
                                  onChanged: (val) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                      hintText: "Type Here...",
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none)),
                                )),
                                SizedBox(
                                  width: 16,
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (messageController.text.isEmpty) {
                                      return;
                                    }
                                    print(ctxt.read<UserModel>().role);
                                    Timer(
                                        Duration(milliseconds: 300),
                                        () => _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(milliseconds: 700),
                                            curve: Curves.ease));
                                    _advisorChatLogin
                                        .initChat(context,
                                            chatID: getChatID(),
                                            model: MessagesModel(
                                                senderName:
                                                    userModel.firstName +
                                                        " " +
                                                        userModel.lastName,
                                                isRead: false,
                                                sendID: userModel.docID,
                                                messageBody:
                                                    messageController.text,
                                                time: DateTime.now()
                                                    .millisecondsSinceEpoch))
                                        .then((value) async {
                                      {
                                        print("Called");
                                        if (ctxt.read<UserModel>().isOnline ==
                                                false &&
                                            ctxt.read<UserModel>().role ==
                                                "T") {
                                          isTyping = true;
                                          setState(() {});
                                          if (messageController.text.contains(
                                                  ctxt
                                                      .read<UserModel>()
                                                      .firstName) ||
                                              messageController.text.contains(
                                                  ctxt
                                                      .read<UserModel>()
                                                      .lastName)) {
                                            DetectIntentResponse response =
                                                await dialogFlowtter
                                                    .detectIntent(
                                              queryInput: QueryInput(
                                                  text: TextInput(
                                                      text: messageController
                                                          .text)),
                                            );
                                            messageController.clear();
                                            _advisorChatLogin.initChat(context,
                                                chatID: getChatID(),
                                                model: MessagesModel(
                                                    senderName:
                                                        userModel.firstName +
                                                            " " +
                                                            userModel.lastName,
                                                    sendID: getMyID(),
                                                    isRead: true,
                                                    messageBody: response
                                                        .message.text.text[0],
                                                    time: DateTime.now()
                                                        .millisecondsSinceEpoch));
                                          } else {
                                            messageController.clear();
                                            _advisorChatLogin.initChat(context,
                                                chatID: getChatID(),
                                                model: MessagesModel(
                                                    senderName:
                                                        userModel.firstName +
                                                            " " +
                                                            userModel.lastName,
                                                    sendID: getMyID(),
                                                    isRead: true,
                                                    messageBody:
                                                        "Kindly ask relevant question",
                                                    time: DateTime.now()
                                                        .millisecondsSinceEpoch));
                                          }
                                          _scrollController
                                              .animateTo(
                                                  _scrollController
                                                      .position.maxScrollExtent,
                                                  duration: Duration(
                                                      milliseconds: 700),
                                                  curve: Curves.ease)
                                              .then((value) {
                                            isTyping = false;
                                            setState(() {});
                                          });
                                        } else {
                                          messageController.clear();
                                        }
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    Icons.send,
                                    color: messageController.text.isEmpty
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ));
      },
    );
  }

  getChatID() {
    if (widget.sendByID != null) {
      return widget.sendByID + "_" + widget.sendToID;
    } else {
      return widget.chatID;
    }
  }

  getAlternate() {
    if (widget.sendByID != null) {
      return widget.sendToID + "_" + widget.sendByID;
    } else {
      return widget.chatID;
    }
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });

    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCall(
          channelName: "IOC_CHAT_BOT",
          role: _role,
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  getMyID() {
    if (widget.sendByID != null) {
      return widget.sendToID;
    } else {
      return widget.chatID.replaceAll("_", "").replaceAll(userModel.docID, "");
    }
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final time;
  final date;

  MessageTile(
      {@required this.message, @required this.sendByMe, this.time, this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
              top: 2,
              bottom: 1,
              left: sendByMe ? 0 : 14,
              right: sendByMe ? 14 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: 0.6 * MediaQuery.of(context).size.width),
            margin: sendByMe
                ? EdgeInsets.only(left: 30)
                : EdgeInsets.only(right: 30),
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 10),
            decoration: BoxDecoration(
              color: sendByMe ? Colors.white : Color(0xffc8f7c5),
              borderRadius: sendByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(message ?? '',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        height: 1.3,
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w300)),
                VerticalSpace(5),
                Text(
                  time,
                  style: TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
