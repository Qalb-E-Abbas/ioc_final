// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:ioc_chatbot/application/applicationChatBznzLogic.dart';
// import 'package:ioc_chatbot/common/appBar.dart';
// import 'package:ioc_chatbot/common/heigh_sized_box.dart';
// import 'package:ioc_chatbot/common/loading_widget.dart';
// import 'package:ioc_chatbot/configurations/back_end_configs.dart';
// import 'package:ioc_chatbot/infrastructure/models/messagesModel.dart';
// import 'package:ioc_chatbot/infrastructure/models/userModel.dart';
// import 'package:ioc_chatbot/infrastructure/services/chatServices.dart';
// import 'package:ioc_chatbot/infrastructure/services/user_services.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:provider/provider.dart';
//
// class TeacherChatScreen extends StatefulWidget {
//   final String chatID;
//   final UserModel stdModel;
//   TeacherChatScreen(this.chatID, this.stdModel);
//   @override
//   _TeacherChatScreenState createState() => _TeacherChatScreenState();
// }
//
// class _TeacherChatScreenState extends State<TeacherChatScreen> {
//   ChatBusinessLogic _advisorChatLogin = ChatBusinessLogic();
//   AdvisorChatServices _advisorChatServices = AdvisorChatServices();
//   UserServices _userServices = UserServices();
//   TextEditingController messageController = TextEditingController();
//
//   ScrollController _scrollController = new ScrollController();
//
//   final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
//   UserModel advModel = UserModel();
//   bool initialized = false;
//
//   UserModel stdModel;
//
//   UserModel userModel = UserModel();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffF6F6F6),
//       appBar: customAppBar(context, text: "Messages"),
//       body: FutureBuilder(
//           future: storage.ready,
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (!initialized) {
//               var items =
//                   storage.getItem(BackEndConfigs.userDetailsLocalStorage);
//               var adv =
//                   storage.getItem(BackEndConfigs.advisorDetailsLocalStorage);
//
//               if (items != null) {
//                 print(items);
//                 userModel = UserModel(
//                   regNo: items['regNo'],
//                   semester: items['semester'],
//                   email: items['email'],
//                   firstName: items['firstName'],
//                   lastName: items['lastName'],
//                   docID: items['docID'],
//                   profilePic: items['profilePic'],
//                   gender: items['gender'],
//                 );
//                 advModel = UserModel(
//                   regNo: adv['regNo'],
//                   semester: adv['semester'],
//                   email: adv['email'],
//                   firstName: adv['firstName'],
//                   lastName: adv['lastName'],
//                   docID: adv['docID'],
//                   profilePic: adv['profilePic'],
//                   gender: adv['gender'],
//                 );
//               }
//
//               initialized = true;
//             }
//             return snapshot.data == null ? LoadingWidget() : _getUI(context);
//           }),
//     );
//   }
//
//   Widget _getUI(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           Expanded(
//             child: Container(
//               child: StreamProvider.value(
//                 value: _advisorChatServices.getMessages(context, widget.chatID),
//                 builder: (context, child) {
//                   Timer(
//                       Duration(milliseconds: 300),
//                       () => _scrollController.animateTo(
//                           _scrollController.position.maxScrollExtent,
//                           duration: Duration(milliseconds: 700),
//                           curve: Curves.ease));
//                   return context.watch<List<MessagesModel>>() == null
//                       ? LoadingWidget()
//                       : ListView.builder(
//                           controller: _scrollController,
//                           itemCount:
//                               context.watch<List<MessagesModel>>().length,
//                           itemBuilder: (context, i) {
//                             print(userModel.docID);
//                             return MessageTile(
//                               message: context
//                                   .watch<List<MessagesModel>>()[i]
//                                   .messageBody,
//                               sendByMe: context
//                                       .watch<List<MessagesModel>>()[i]
//                                       .sendID ==
//                                   userModel.docID,
//                               time: "12:00",
//                             );
//                           });
//                 },
//               ),
//             ),
//           ),
//           Container(
//             alignment: Alignment.bottomCenter,
//             width: MediaQuery.of(context).size.width,
//             color: Colors.white,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                       child: TextField(
//                     style: TextStyle(color: Colors.black, fontSize: 13),
//                     controller: messageController,
//                     onChanged: (val) {
//                       setState(() {});
//                     },
//                     decoration: InputDecoration(
//                         hintText: "Type Here...",
//                         hintStyle: TextStyle(
//                           color: Colors.black,
//                           fontSize: 13,
//                         ),
//                         focusedBorder:
//                             OutlineInputBorder(borderSide: BorderSide.none),
//                         border:
//                             OutlineInputBorder(borderSide: BorderSide.none)),
//                   )),
//                   SizedBox(
//                     width: 16,
//                   ),
//                   StreamProvider.value(
//                     value:
//                         _userServices.streamStudentsData(widget.stdModel.docID),
//                     builder: (context, child) {
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         if (stdModel == null) {
//                           stdModel = context.read<UserModel>();
//                           setState(() {});
//                         }
//                         // Add Your Code here.
//                       });
//                       return IconButton(
//                         onPressed: () {
//                           print("I am docID: ${widget.stdModel.docID}");
//
//                           if (messageController.text.isEmpty) {
//                             return;
//                           }
//                           Timer(
//                               Duration(milliseconds: 300),
//                               () => _scrollController.animateTo(
//                                   _scrollController.position.maxScrollExtent,
//                                   duration: Duration(milliseconds: 700),
//                                   curve: Curves.ease));
//                           _advisorChatLogin
//                               .initChat(context,
//                                   sendToID: stdModel,
//                                   sendByID: userModel.docID,
//                                   model: MessagesModel(
//                                       senderName: userModel.firstName +
//                                           " " +
//                                           userModel.lastName,
//                                       sendID: userModel.docID,
//                                       messageBody: messageController.text,
//                                       time: DateTime.now()
//                                           .millisecondsSinceEpoch))
//                               // _logic
//                               //     .sendChatByHOD(
//                               //         userModel,
//                               //         widget.sendToUser,
//                               //         messageController.text,
//                               //         DateFormat.yMEd()
//                               //             .add_jms()
//                               //             .format(DateTime.now()),
//                               //         DateTime.now().millisecondsSinceEpoch)
//                               .then((value) => setState(() {
//                                     messageController.clear();
//                                   }));
//                         },
//                         icon: Icon(
//                           Icons.send,
//                           color: messageController.text.isEmpty
//                               ? Colors.grey
//                               : Colors.black,
//                         ),
//                       );
//                     },
//                   )
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class MessageTile extends StatelessWidget {
//   final String message;
//   final bool sendByMe;
//   final time;
//   final date;
//
//   MessageTile(
//       {@required this.message, @required this.sendByMe, this.time, this.date});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment:
//           sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: EdgeInsets.only(
//               top: 2,
//               bottom: 1,
//               left: sendByMe ? 0 : 14,
//               right: sendByMe ? 14 : 0),
//           alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
//           child: Container(
//             constraints: BoxConstraints(
//                 maxWidth: 0.6 * MediaQuery.of(context).size.width),
//             margin: sendByMe
//                 ? EdgeInsets.only(left: 30)
//                 : EdgeInsets.only(right: 30),
//             padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 10),
//             decoration: BoxDecoration(
//               color: sendByMe ? Colors.white : Color(0xffc8f7c5),
//               borderRadius: sendByMe
//                   ? BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       bottomRight: Radius.circular(10),
//                       bottomLeft: Radius.circular(10))
//                   : BorderRadius.only(
//                       bottomLeft: Radius.circular(10),
//                       topRight: Radius.circular(10),
//                       bottomRight: Radius.circular(10)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(message ?? '',
//                     textAlign: TextAlign.start,
//                     style: TextStyle(
//                         height: 1.3,
//                         color: Colors.black,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w300)),
//                 VerticalSpace(5),
//                 Text(
//                   time,
//                   style: TextStyle(fontSize: 9, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
