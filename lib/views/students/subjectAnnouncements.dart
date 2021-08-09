import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ioc_chatbot/Logics/applicationChatBznzLogic.dart';
import 'package:ioc_chatbot/common/appBar.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/horizontal_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/Backend/models/postModel.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/postServices.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/views/students/chat_messages_screen.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SubjectAnnounce extends StatefulWidget {
  const SubjectAnnounce({Key key}) : super(key: key);

  @override
  _SubjectAnnounceState createState() => _SubjectAnnounceState();
}

class _SubjectAnnounceState extends State<SubjectAnnounce> {
  PostServices _postServices = PostServices();

  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;
  ReceivePort receivePort = ReceivePort();
  UserModel userModel = UserModel();
  UserModel advModel = UserModel();
  ChatBusinessLogic _advisorChatServices = ChatBusinessLogic();
  UserServices _userServices = UserServices();
  int progress = 0;

  static downloadCallback(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName('downloadingVideo');
    sendPort.send(progress);
  }

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
        appBar:
            customAppBar(context, text: 'sub_announcement', showArrow: false),
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
                    section: items['section'],
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

  Widget _getUI(BuildContext context) {
    print(userModel.subjects);
    return SafeArea(
        child: StreamProvider.value(
      value: _postServices.getSubjectPosts(
          advModel.docID,
          userModel.subjects == null ? [-1] : userModel.subjects,
          userModel.section),

      builder: (context, child) {
        if (context.watch<List<PostModel>>() != null) {
          context.watch<List<PostModel>>().map((e) {
            _postServices.markNotificationAsRead(userModel.docID, e.docID);
          }).toList();
        }

        return context.watch<List<PostModel>>() == null
            ? LoadingWidget()
            : ListView.builder(
                itemCount: context.watch<List<PostModel>>().length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        context.watch<List<PostModel>>()[i].postImageName == ""
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            AssetImage(advModel.profilePic),
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
                                      // StreamProvider.value(
                                      //   value: _userServices.streamStudentsData(
                                      //       context
                                      //           .watch<List<PostModel>>()[i]
                                      //           .docID),
                                      //   builder: (context, child) {
                                      //     print(context
                                      //         .watch<List<UserModel>>()[i]);
                                      //     return GestureDetector(
                                      //       onTap: () {
                                      //         // Navigator.of(context).push(
                                      //         //     MaterialPageRoute(
                                      //         //         builder: (_) =>
                                      //         //             ChatMessagesScreen(
                                      //         //               name: announcementList[index]
                                      //         //                   .name,
                                      //         //               image: announcementList[index]
                                      //         //                   .imageUrl,
                                      //         //             )));
                                      //       },
                                      //       child: DynamicFontSize(
                                      //         isUnderline: true,
                                      //         label: context
                                      //                 .watch<List<UserModel>>()[i]
                                      //                 .gender +
                                      //             " " +
                                      //             context
                                      //                 .watch<List<UserModel>>()[i]
                                      //                 .lastName,
                                      //         fontSize: 16,
                                      //         color: Colors.black,
                                      //         fontWeight: FontWeight.w500,
                                      //       ),
                                      //     );
                                      //   },
                                      // ),
                                    ],
                                  ),
                                  VerticalSpace(20),
                                  DynamicFontSize(
                                    label: context
                                        .watch<List<PostModel>>()[i]
                                        .postText,
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  VerticalSpace(10),
                                  DynamicFontSize(
                                    label:
                                        context.watch<List<PostModel>>()[i].docID,
                                    fontSize: 16,
                                    color: AppColors.greyColor,
                                    fontWeight: FontWeight.w500,
                                  )
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            advModel.profilePic ?? ""),
                                        radius: 30,
                                      ),
                                      HorizontalSpace(15),
                                      GestureDetector(
                                        onTap: () {
                                          // Navigator.of(context).push(
                                          //     MaterialPageRoute(
                                          //         builder: (_) =>
                                          //             ChatMessagesScreen(
                                          //               name: announcementList[index]
                                          //                   .name,
                                          //               image: announcementList[index]
                                          //                   .imageUrl,
                                          //             )));
                                        },
                                        child: StreamProvider.value(
                                          value: _userServices.fetchStudentsData(
                                              context
                                                  .watch<List<PostModel>>()[i]
                                                  .advID),
                                          builder: (context, child) {
                                            return context.watch<UserModel>() ==
                                                    null
                                                ? LoadingWidget()
                                                : GestureDetector(
                                                    onTap: () {
                                                      UserModel advModel = context
                                                          .read<UserModel>();
                                                      setState(() {});
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  ChatMessageScreen(
                                                                      sendByID:
                                                                          userModel
                                                                              .docID,
                                                                      sendToID:
                                                                          advModel
                                                                              .docID)));
                                                    },
                                                    child: DynamicFontSize(
                                                      isUnderline: true,
                                                      label: context
                                                              .watch<UserModel>()
                                                              .firstName +
                                                          " " +
                                                          context
                                                              .watch<UserModel>()
                                                              .lastName,
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  VerticalSpace(20),
                                  Column(
                                    children: [
                                      DynamicFontSize(
                                        label: context
                                            .watch<List<PostModel>>()[i]
                                            .postText,
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                  VerticalSpace(10),
                                  Row(
                                    children: [
                                      Text(
                                        context
                                            .watch<List<PostModel>>()[i]
                                            .postImageName,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      HorizontalSpace(10),
                                      IconButton(
                                        onPressed: () {
                                          _downloadFile(
                                              context
                                                  .read<List<PostModel>>()[i]
                                                  .postImage,
                                              context
                                                  .read<List<PostModel>>()[i]
                                                  .postImageName);
                                        },
                                        icon: Icon(Icons.download_rounded,
                                            size:25,
                                            color: AppColors.blueTextColor),
                                      ),
                                    ],
                                  ),
                                  VerticalSpace(15),
                                  DynamicFontSize(
                                    label:
                                        'Sent at: ${context.read<List<PostModel>>()[i].time}',
                                    fontSize: 16,
                                    color: AppColors.greyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  Divider(thickness: 1, color: AppColors.backgroundScreen,)
                                ],
                              )
                      ],
                    ),
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
