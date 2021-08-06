import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ioc_chatbot/Backend/models/postModel.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/postServices.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/Logics/applicationChatBznzLogic.dart';
import 'package:ioc_chatbot/common/appBar.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/horizontal_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'chat_messages_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({Key key}) : super(key: key);

  @override
  _AnnouncementsListScreenState createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {


  PostServices _postServices = PostServices();

  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;
  ReceivePort receivePort = ReceivePort();
  UserModel userModel = UserModel();
  UserModel advModel = UserModel();

  static downloadCallback(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName('downloadingVideo');
    sendPort.send(progress);
  }

  ChatBusinessLogic _advisorChatServices = ChatBusinessLogic();
  UserServices _userServices = UserServices();
  int progress = 0;

  @override
  initState() {
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, "downloadingVideo");
    receivePort.listen((message) {
      setState(() {
        progress = message;
      });
    });
    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(context, text: 'announce', showArrow: false),
        body: FutureBuilder(
            future: storage.ready,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!initialized) {
                var items =
                    storage.getItem(BackEndConfigs.userDetailsLocalStorage);
                var adv =
                    storage.getItem(BackEndConfigs.advisorDetailsLocalStorage);

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
                    subjects: items['subjects'],
                  );
                  if (adv != null)
                    advModel = UserModel(
                      regNo: adv['regNo'],
                      semester: adv['semester'],
                      email: adv['email'],
                      firstName: adv['firstName'],
                      lastName: adv['lastName'],
                      docID: adv['docID'],
                      profilePic: adv['profilePic'],
                      gender: adv['gender'],
                    );
                }

                initialized = true;
              }
              return snapshot.data == null ? LoadingWidget() : _getUI(context);
            }));
  }

  getAdv() {
    try {
      return advModel.docID;
    } catch (e) {
      return null;
    }
  }

  Widget _getUI(BuildContext context) {
    return SafeArea(
        child: getAdv() == null
            ? Container()
            : StreamProvider.value(
                value: _postServices.streamPosts(advModel.docID),
                builder: (context, child) {
                  if (context.watch<List<PostModel>>() != null) {
                    context.watch<List<PostModel>>().map((e) {
                      _postServices.markNotificationAsRead(
                          userModel.docID, e.docID);
                    }).toList();
                  }
                  return context.watch<List<PostModel>>() == null
                      ? LoadingWidget()
                      : ListView.builder(
                          itemCount: context.watch<List<PostModel>>().length,
                          itemBuilder: (context, i) {
                            return StreamProvider.value(
                              value: _userServices.fetchStudentsData(
                                  context.watch<List<PostModel>>()[i].advID),
                              builder: (c, child) {
                                return c.watch<UserModel>() == null
                                    ? LoadingWidget()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          context
                                                      .watch<List<PostModel>>()[
                                                          i]
                                                      .postImageName ==
                                                  ""
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundImage:
                                                              AssetImage(advModel
                                                                  .profilePic),
                                                          radius: 25,
                                                        ),

                                                        HorizontalSpace(15),

                                                        // GestureDetector(
                                                        //   onTap: (){
                                                        //     Navigator.of(context).pushReplacement(
                                                        //         MaterialPageRoute(
                                                        //             builder: (_) => ChatMessagesScreen(
                                                        //               name: announcementList[index].name,
                                                        //               image: announcementList[index].imageUrl,
                                                        //             )
                                                        //         ));
                                                        //   },
                                                        //   child: Container(
                                                        //     height: 40,
                                                        //     width: 100,
                                                        //     child: Center(
                                                        //       child: Text(announcementList[index].name),
                                                        //     ),
                                                        //   )
                                                        // ),

                                                        GestureDetector(
                                                          onTap: () {
                                                            // Navigator.of(context).push(
                                                            //     MaterialPageRoute(
                                                            //         builder: (_) =>
                                                            //             ChatMessageScreen(
                                                            //                 )));
                                                          },
                                                          child:
                                                              DynamicFontSize(
                                                            isUnderline: true,
                                                            label: advModel
                                                                    .firstName +
                                                                " " +
                                                                advModel
                                                                    .lastName,
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    VerticalSpace(20),
                                                    DynamicFontSize(
                                                      label: context
                                                          .watch<
                                                              List<
                                                                  PostModel>>()[
                                                              i]
                                                          .postText,
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    VerticalSpace(10),
                                                    DynamicFontSize(
                                                      label: context
                                                          .watch<
                                                              List<
                                                                  PostModel>>()[
                                                              i]
                                                          .docID,
                                                      fontSize: 16,
                                                      color: FrontEndConfigs
                                                          .greyColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    )
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(advModel
                                                                      .profilePic ??
                                                                  ""),
                                                          radius: 25,
                                                        ),
                                                        HorizontalSpace(15),
                                                        GestureDetector(
                                                          onTap: () {
                                                            UserModel d = c.read<
                                                                UserModel>();
                                                            setState(() {});
                                                            Navigator.of(context).push(MaterialPageRoute(
                                                                builder: (_) => ChatMessageScreen(
                                                                    sendByID:
                                                                        userModel
                                                                            .docID,
                                                                    sendToID:
                                                                        advModel
                                                                            .docID)));
                                                          },
                                                          child:
                                                              DynamicFontSize(
                                                            isUnderline: true,
                                                            label: advModel
                                                                    .firstName +
                                                                " " +
                                                                advModel
                                                                    .lastName,
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    VerticalSpace(20),
                                                    Column(
                                                      children: [
                                                        DynamicFontSize(
                                                          label: context
                                                              .watch<
                                                                  List<
                                                                      PostModel>>()[
                                                                  i]
                                                              .postText,
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ],
                                                    ),
                                                    VerticalSpace(10),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          context
                                                              .watch<
                                                                  List<
                                                                      PostModel>>()[
                                                                  i]
                                                              .postImageName,
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                        HorizontalSpace(10),
                                                        InkWell(
                                                          onTap: () {
                                                            _downloadFile(
                                                                context
                                                                    .read<
                                                                        List<
                                                                            PostModel>>()[
                                                                        i]
                                                                    .postImage,
                                                                context
                                                                    .read<
                                                                        List<
                                                                            PostModel>>()[
                                                                        i]
                                                                    .postImageName);
                                                          },
                                                          child: Icon(
                                                              Icons
                                                                  .download_rounded,
                                                              color: FrontEndConfigs
                                                                  .blueTextColor),
                                                        ),
                                                      ],
                                                    ),
                                                    VerticalSpace(15),
                                                    DynamicFontSize(
                                                      label:
                                                          'Sent at: ${context.read<List<PostModel>>()[i].time}',
                                                      fontSize: 16,
                                                      color: FrontEndConfigs
                                                          .greyColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    Divider()
                                                  ],
                                                )
                                        ],
                                      );
                              },
                            );
                          });
                },
              ));
  }

  _downloadFile(String url, String fileName) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      final id = await FlutterDownloader.enqueue(
        url: url,
        fileName: fileName,
        savedDir: baseStorage.path,
      );
    } else {
      print("No permission");
    }
  }
}
