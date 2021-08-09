import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/auth_state.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/Backend/models/postModel.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/postServices.dart';
import 'package:ioc_chatbot/views/elements/navigation_dialog.dart';
import 'package:ioc_chatbot/views/students/announcements_list_screen.dart';
import 'package:ioc_chatbot/views/students/my_profile_screen.dart';
import 'package:ioc_chatbot/views/students/subjectAnnouncements.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'teacher_chat_list.dart';

class StudentsHomeView extends StatefulWidget {
  const StudentsHomeView({Key key}) : super(key: key);

  @override
  _StudentsHomeViewState createState() => _StudentsHomeViewState();
}

class _StudentsHomeViewState extends State<StudentsHomeView> {
  int currentPage = 0;
  PageController _pageController;

  List pages = [];
  PostServices _postServices = PostServices();
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;
  UserModel userModel = UserModel();
  UserModel advModel = UserModel();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  initState() {
    UserLoginStateHandler.saveUserLoggedInSharedPreference(true);
    super.initState();
  }

  Future<void> _initFcm(String docID, String regNo) async {
    print("Firebase Token");

    _firebaseMessaging.getToken().then((token) {
      FirebaseFirestore.instance.collection('deviceTokens').doc(docID).set(
        {'deviceTokens': token, 'regNo': regNo},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return showNavigationDialog(context,
              message: "Do you really want to exit?",
              buttonText: "Yes", navigation: () {
            return exit(0);
          }, secondButtonText: "No", showSecondButton: true);
        },
        child: FutureBuilder(
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
                    section: items['section'],
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
                _initFcm(userModel.docID, userModel.regNo);
                initialized = true;
              }
              return snapshot.data == null
                  ? LoadingWidget()
                  : _getUI(context, advModel);
            }));
  }

  Widget _getUI(BuildContext context, UserModel _advModel) {
    var user = Provider.of<User>(context);
    return Scaffold(
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: currentPage,
        showElevation: false,
        backgroundColor: AppColors.backgroundScreen,
        itemCornerRadius: 24,
        curve: Curves.easeInOutCubic,
        onItemSelected: (index) => setState(() => currentPage = index),
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(Icons.message_outlined),
            title: Text('chats').tr(),
            activeColor: AppColors.blackColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: userModel == null
                ? Container()
                : StreamProvider.value(
                    value: _postServices.getAdvNotificationCounter(
                        userModel.docID, _advModel.docID),
                    builder: (context, i) {
                      return StreamProvider.value(
                        value: _postServices.getAdvPosts(_advModel.docID),
                        builder: (ct, child) {
                          return FittedBox(
                            child: Stack(
                              children: [
                                FittedBox(
                                  child: Icon(
                                    Icons.notifications_active,
                                  ),
                                ),
                                if (ct.watch<List<PostModel>>() != null ||
                                    context.watch<List<PostModel>>() != null)

                                  ct.watch<List<PostModel>>().length -
                                              context
                                                  .watch<List<PostModel>>()
                                                  .length ==
                                          0
                                      ? Container(
                                          height: 1,
                                          width: 1,
                                        )
                                      : Positioned(
                                          left: 12,
                                          bottom: 11,
                                          child: new Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: new BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 12,
                                              minHeight: 12,
                                            ),
                                            child: ct.watch<
                                                            List<
                                                                PostModel>>() ==
                                                        null ||
                                                    context.watch<
                                                            List<
                                                                PostModel>>() ==
                                                        null
                                                ? Text(
                                                    "0",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )
                                                : Text(
                                                    getAdv() == null
                                                        ? "0"
                                                        : "${ct.watch<List<PostModel>>().length - context.watch<List<PostModel>>().length}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ).tr(),
                                          ),
                                        )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
            title: Text('advisor').tr(),
            activeColor: AppColors.blackColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: userModel == null
                ? Container()
                : StreamProvider.value(
                    value: _postServices.getSubjectNotificationCounter(

                        userModel.docID,
                        userModel.subjects == null ? [-1] : userModel.subjects,
                        userModel.section),
                    builder: (context, i) {
                      return StreamProvider.value(
                        value: _postServices.getSubjectPosts(advModel.docID,
                            userModel.subjects, userModel.section),
                        builder: (ct, child) {
                          return FittedBox(
                            child: Stack(
                              children: [
                                FittedBox(
                                  child: Icon(
                                    Icons.notification_important,
                                  ),
                                ),
                                if (ct.watch<List<PostModel>>() != null ||
                                    context.watch<List<PostModel>>() != null)
                                  ct.watch<List<PostModel>>().length -
                                              context
                                                  .watch<List<PostModel>>()
                                                  .length ==
                                          0
                                      ? Container()
                                      : Positioned(
                                          left: 12,
                                          bottom: 11,
                                          child: new Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: new BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 12,
                                              minHeight: 12,
                                            ),
                                            child: ct.watch<
                                                            List<
                                                                PostModel>>() ==
                                                        null ||
                                                    context.watch<
                                                            List<
                                                                PostModel>>() ==
                                                        null
                                                ? Text(
                                                    "0",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ).tr()
                                                : Text(
                                                    userModel.subjects == null
                                                        ? "0"
                                                        : "${ct.watch<List<PostModel>>().length -
                                                        context.watch<List<PostModel>>().length}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ).tr(),
                                          ),
                                        )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
            title: Text('subject').tr(),
            activeColor: AppColors.blackColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.person),
            title: Text(
              'my_profile',
            ).tr(),
            activeColor: AppColors.blackColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      body: getPages(context, currentPage),
    );
  }

  Widget getPages(BuildContext context, int currentPage) {
    if (currentPage == 0) {
      return userModel == null ? LoadingWidget() : ChatList(userModel.docID);
    } else if (currentPage == 1) {
      return AnnouncementsListScreen();
    } else if (currentPage == 2) {
      return SubjectAnnounce();
    } else if (currentPage == 3) {
      return MyProfileScreen();
    }
  }

  getAdv() {
    try {
      return advModel.docID;
    } catch (e) {
      return null;
    }
  }
}
